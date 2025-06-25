#!/bin/bash

set -e

echo "🚀 Universal Laravel Dev Environment Deployer"
echo "=============================================="

# Проверяем, что мы в правильной директории
if [ ! -f "artisan" ]; then
    echo "❌ Error: artisan file not found. Make sure you're in the Laravel project root."
    echo "   Current directory: $(pwd)"
    echo "   Expected files: artisan, composer.json, app/, resources/"
    exit 1
fi

# Получаем абсолютный путь к проекту
PROJECT_PATH=$(pwd)
echo "📁 Project path: $PROJECT_PATH"

# Проверяем, что путь не содержит пробелы или специальные символы
if [[ "$PROJECT_PATH" =~ [[:space:]] ]]; then
    echo "❌ Error: Project path contains spaces. This may cause issues with Kubernetes."
    echo "   Please move the project to a path without spaces."
    exit 1
fi

# Проверяем права доступа к директории
if [ ! -r "$PROJECT_PATH" ] || [ ! -w "$PROJECT_PATH" ]; then
    echo "❌ Error: Insufficient permissions for project directory."
    echo "   Please ensure you have read/write access to: $PROJECT_PATH"
    exit 1
fi

# Проверяем, что Docker доступен
if ! command -v docker &> /dev/null; then
    echo "❌ Error: Docker is not installed or not in PATH."
    exit 1
fi

# Проверяем, что kubectl доступен
if ! command -v kubectl &> /dev/null; then
    echo "❌ Error: kubectl is not installed or not in PATH."
    exit 1
fi

# Проверяем подключение к Kubernetes
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Error: Cannot connect to Kubernetes cluster."
    echo "   Please ensure your cluster is running and kubectl is configured."
    exit 1
fi

echo "✅ All prerequisites checked successfully!"

# Билдим dev образ
echo ""
echo "📦 Building Laravel dev image..."
docker build -f docker/8.4/Dockerfile --target development -t laravel-dev:latest .

# Создаем временный deployment файл с правильным путем
echo "⚙️  Creating deployment with project path..."
cat > k8s/dev-deployment-temp.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: laravel-dev
  labels:
    app: laravel-dev
spec:
  replicas: 1
  selector:
    matchLabels:
      app: laravel-dev
  template:
    metadata:
      labels:
        app: laravel-dev
    spec:
      containers:
      - name: php-fpm
        image: laravel-dev:latest
        imagePullPolicy: Never
        ports:
        - containerPort: 9000
        volumeMounts:
        - name: app-code
          mountPath: /var/www/html
        - name: php-logs
          mountPath: /var/log
        env:
        - name: APP_ENV
          value: "local"
        - name: APP_DEBUG
          value: "true"
        - name: PROJECT_PATH
          value: "$PROJECT_PATH"
        resources:
          requests:
            memory: "256Mi"
            cpu: "100m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          exec:
            command:
            - php
            - /var/www/html/public/health.php
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          exec:
            command:
            - php
            - /var/www/html/public/health.php
          initialDelaySeconds: 5
          periodSeconds: 5

      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
        volumeMounts:
        - name: app-code
          mountPath: /var/www/html
        - name: nginx-config
          mountPath: /etc/nginx/conf.d/default.conf
          subPath: nginx.conf
        - name: nginx-logs
          mountPath: /var/log/nginx
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "200m"
        livenessProbe:
          httpGet:
            path: /health.php
            port: 80
          initialDelaySeconds: 10
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health.php
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5

      volumes:
      - name: app-code
        hostPath:
          path: $PROJECT_PATH
          type: Directory
      - name: nginx-config
        configMap:
          name: nginx-dev-config
      - name: php-logs
        emptyDir: {}
      - name: nginx-logs
        emptyDir: {}
EOF

# Применяем ConfigMap
echo "⚙️  Applying nginx ConfigMap..."
kubectl apply -f k8s/dev-configmap.yaml

# Применяем Deployment с правильным путем
echo "🚀 Applying dev deployment..."
kubectl apply -f k8s/dev-deployment-temp.yaml

# Применяем Service
echo "🔗 Applying dev service..."
kubectl apply -f k8s/dev-service.yaml

# Удаляем временный файл
rm k8s/dev-deployment-temp.yaml

# Ждем готовности pod
echo "⏳ Waiting for pod to be ready..."
kubectl wait --for=condition=ready pod -l app=laravel-dev --timeout=120s

# Показываем статус
echo ""
echo "📊 Deployment status:"
kubectl get pods -l app=laravel-dev
kubectl get svc laravel-dev-service

echo ""
echo "✅ Laravel Dev Environment deployed successfully!"
echo ""
echo "🌐 Access your application:"
echo "   Local: http://localhost:30080"
echo "   Health: http://localhost:30080/health.php"
echo ""
echo "📝 Useful commands:"
echo "   kubectl logs -f deployment/laravel-dev -c php-fpm"
echo "   kubectl logs -f deployment/laravel-dev -c nginx"
echo "   kubectl exec -it deployment/laravel-dev -c php-fpm -- bash"
echo "   ./k8s/dev-cleanup.sh"
echo ""
echo "🔧 Project info:"
echo "   Path: $PROJECT_PATH"
echo "   NodePort: 30080"
echo "   Namespace: $(kubectl config view --minify -o jsonpath='{..namespace}' 2>/dev/null || echo 'default')" 