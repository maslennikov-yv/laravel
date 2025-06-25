#!/bin/bash

set -e

echo "🧹 Cleaning up Laravel Dev Environment from Kubernetes..."

# Удаляем временный deployment файл, если он существует
if [ -f "k8s/dev-deployment-temp.yaml" ]; then
    echo "🗑️  Removing temporary deployment file..."
    rm k8s/dev-deployment-temp.yaml
fi

# Удаляем все ресурсы dev-окружения
echo "🗑️  Deleting dev deployment..."
kubectl delete -f k8s/dev-deployment.yaml --ignore-not-found=true

echo "🗑️  Deleting dev service..."
kubectl delete -f k8s/dev-service.yaml --ignore-not-found=true

echo "🗑️  Deleting nginx ConfigMap..."
kubectl delete -f k8s/dev-configmap.yaml --ignore-not-found=true

# Удаляем образ
echo "🗑️  Removing dev image..."
docker rmi laravel-dev:latest --force 2>/dev/null || true

echo "✅ Laravel Dev Environment cleaned up successfully!" 