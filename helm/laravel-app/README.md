# Laravel Application Helm Chart

Этот Helm chart предназначен для развертывания Laravel приложений в Kubernetes с поддержкой зависимостей (PostgreSQL, Redis, MinIO, Mailpit) и возможностью их отключения для использования внешних сервисов.

## 🚀 Возможности

- **Гибкое управление зависимостями**: Включение/отключение PostgreSQL, Redis, MinIO, Mailpit
- **Поддержка внешних сервисов**: Настройка для использования AWS RDS, ElastiCache, S3, и других
- **Автомасштабирование**: HorizontalPodAutoscaler для production
- **Безопасность**: Security contexts, network policies, TLS
- **Мониторинг**: Health checks, probes
- **Миграции**: Автоматический запуск миграций при деплое

## 📋 Предварительные требования

- Kubernetes 1.19+
- Helm 3.8+
- Ingress Controller (nginx, traefik, etc.) для внешнего доступа
- Cert-Manager (опционально, для TLS)

## 🔧 Установка

### Добавление репозитория зависимостей

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```

### Установка зависимостей

```bash
cd helm/laravel-app
helm dependency build
```

### Быстрая установка (development)

```bash
# Создание namespace
kubectl create namespace laravel-app

# Установка с настройками для разработки
helm install laravel-app . \
  --namespace laravel-app \
  --values values-dev.yaml
```

### Установка для production

```bash
# Установка с внешними сервисами
helm install laravel-app . \
  --namespace laravel-app \
  --values values-prod.yaml \
  --set app.url="https://your-domain.com" \
  --set image.tag="1.0.0" \
  --set externalServices.postgresql.host="your-rds-endpoint" \
  --set externalServices.redis.host="your-elasticache-endpoint"
```

## 🔧 Конфигурация

### Основные параметры

| Параметр | Описание | Значение по умолчанию |
|----------|----------|----------------------|
| `app.env` | Окружение Laravel | `production` |
| `app.debug` | Режим отладки | `false` |
| `app.url` | URL приложения | `http://localhost` |
| `image.repository` | Docker образ | `your-org/laravel-app` |
| `image.tag` | Тег образа | `latest` |
| `replicaCount` | Количество реплик | `1` |

### Управление зависимостями

#### Включение внутренних сервисов (development/staging)

```yaml
redis:
  enabled: true

postgresql:
  enabled: true

minio:
  enabled: true

mailpit:
  enabled: true
```

#### Отключение для использования внешних сервисов (production)

```yaml
# Отключаем внутренние сервисы
redis:
  enabled: false

postgresql:
  enabled: false

minio:
  enabled: false

mailpit:
  enabled: false

# Настраиваем внешние сервисы
externalServices:
  postgresql:
    host: "your-rds-endpoint.amazonaws.com"
    port: 5432
    database: "laravel_prod"
    username: "laravel"
    password: "secure-password"

  redis:
    host: "your-elasticache.cache.amazonaws.com"
    port: 6379
    password: "redis-password"

  s3:
    endpoint: "https://s3.amazonaws.com"
    region: "us-east-1"
    bucket: "your-bucket"
    accessKey: "your-access-key"
    secretKey: "your-secret-key"

  smtp:
    host: "smtp.sendgrid.net"
    port: 587
    username: "apikey"
    password: "your-sendgrid-key"
```

## 🌍 Окружения

### Development

```bash
helm install laravel-app . \
  --namespace laravel-app-dev \
  --values values-dev.yaml
```

**Особенности:**
- Все зависимости включены
- Debug режим включен
- Меньшие ресурсы
- Ingress без TLS

### Staging

```bash
helm install laravel-app . \
  --namespace laravel-app-staging \
  --values values-staging.yaml
```

**Особенности:**
- Смешанный подход (некоторые внутренние, некоторые внешние)
- TLS включен
- Автомасштабирование с ограничениями

### Production

```bash
helm install laravel-app . \
  --namespace laravel-app-prod \
  --values values-prod.yaml \
  --set externalServices.postgresql.host="prod-db.amazonaws.com" \
  --set externalServices.redis.host="prod-cache.amazonaws.com"
```

**Особенности:**
- Все зависимости внешние
- Множественные реплики
- Полное автомасштабирование
- Network policies
- Высокие ресурсы

## 🔒 Безопасность

### Secrets

Chart автоматически создает Secret с:
- `APP_KEY` - ключ Laravel приложения
- `DB_PASSWORD` - пароль базы данных
- `REDIS_PASSWORD` - пароль Redis
- `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` - AWS credentials

### Использование существующих Secrets

```yaml
externalServices:
  postgresql:
    existingSecret: "postgres-credentials"
    existingSecretPasswordKey: "password"
    
  redis:
    existingSecret: "redis-credentials" 
    existingSecretPasswordKey: "password"
```

### Network Policies

```yaml
networkPolicy:
  enabled: true
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              name: ingress-nginx
  egress:
    - to: []
      ports:
        - protocol: TCP
          port: 443
        - protocol: TCP
          port: 5432
```

## 📊 Мониторинг

### Health Checks

Chart включает настроенные probes:

```yaml
livenessProbe:
  enabled: true
  httpGet:
    path: /health
    port: http

readinessProbe:
  enabled: true
  httpGet:
    path: /health
    port: http

startupProbe:
  enabled: true
  httpGet:
    path: /health
    port: http
```

### Автомасштабирование

```yaml
autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 20
  targetCPUUtilizationPercentage: 70
  targetMemoryUtilizationPercentage: 80
```

## 🗄️ Хранилище

### Persistent Storage

```yaml
persistence:
  enabled: true
  size: 8Gi
  storageClass: "gp3"
  mountPath: /var/www/html/storage
```

### S3 Storage

```yaml
env:
  FILESYSTEM_DISK: s3
  AWS_BUCKET: "your-bucket"
  AWS_ENDPOINT: "https://s3.amazonaws.com"
```

## 🔄 Миграции

Chart автоматически запускает миграции через Helm hooks:

```yaml
jobs:
  migrate:
    enabled: true
    restartPolicy: OnFailure
    backoffLimit: 3
```

Миграции выполняются:
- После установки (`post-install`)
- После обновления (`post-upgrade`)

## 📧 Email Testing

### Mailpit (Development/Staging)

```yaml
mailpit:
  enabled: true
  service:
    ports:
      smtp: 1025
      http: 8025
```

Доступ к веб-интерфейсу:
```bash
kubectl port-forward svc/laravel-app-mailpit 8025:8025
```

## 🚀 Примеры использования

### Простая установка для разработки

```bash
helm install my-laravel . \
  --set app.debug=true \
  --set app.env=local \
  --set image.tag=dev
```

### Production с AWS сервисами

```bash
helm install my-laravel . \
  --values values-prod.yaml \
  --set externalServices.postgresql.host="myapp.cluster-xyz.us-east-1.rds.amazonaws.com" \
  --set externalServices.redis.host="myapp.cache.amazonaws.com" \
  --set externalServices.s3.bucket="myapp-production-storage" \
  --set ingress.hosts[0].host="myapp.com" \
  --set ingress.tls[0].hosts[0]="myapp.com"
```

### Обновление приложения

```bash
helm upgrade my-laravel . \
  --set image.tag=1.1.0 \
  --reuse-values
```

## 🛠️ Troubleshooting

### Проверка статуса

```bash
# Статус релиза
helm status laravel-app

# Логи приложения
kubectl logs -l app.kubernetes.io/name=laravel-app -f

# Статус миграций
kubectl get jobs -l app.kubernetes.io/component=migrate
```

### Отладка проблем

```bash
# Проверка переменных окружения
kubectl exec deployment/laravel-app -- env | grep -E "(DB_|REDIS_|AWS_)"

# Проверка подключения к БД
kubectl exec deployment/laravel-app -- php artisan tinker --execute="DB::connection()->getPdo()"

# Проверка Redis
kubectl exec deployment/laravel-app -- php artisan tinker --execute="Redis::ping()"
```

## 📚 Дополнительная документация

- [Laravel Documentation](https://laravel.com/docs)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Helm Documentation](https://helm.sh/docs/)
- [Bitnami Charts](https://github.com/bitnami/charts)

## 🤝 Поддержка

Для вопросов и проблем создавайте issues в репозитории проекта. 