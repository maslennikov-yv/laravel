# 🚀 Kubernetes Deployment с Helm

Этот документ описывает развертывание Laravel приложения в Kubernetes с использованием Helm chart и управление зависимостями.

## 📋 Содержание

- [Обзор](#обзор)
- [Архитектура](#архитектура)
- [Предварительные требования](#предварительные-требования)
- [Быстрый старт](#быстрый-старт)
- [Конфигурация окружений](#конфигурация-окружений)
- [Управление зависимостями](#управление-зависимостями)
- [Деплой и управление](#деплой-и-управление)
- [Мониторинг](#мониторинг)
- [Безопасность](#безопасность)
- [Kubernetes Dashboard](#kubernetes-dashboard)
- [Troubleshooting](#troubleshooting)

## 🎯 Обзор

Helm chart предоставляет:

- **Гибкое управление зависимостями**: PostgreSQL, Redis, MinIO, Mailpit
- **Поддержку множественных окружений**: dev, staging, production
- **Автоматическое масштабирование**: HPA для production
- **Безопасность**: Network policies, security contexts, secrets
- **Мониторинг**: Health checks, metrics
- **CI/CD готовность**: Hooks для миграций

## 🏗️ Архитектура

```
┌─────────────────────────────────────────────────────────────┐
│                    Kubernetes Cluster                       │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐ │
│  │   Ingress       │  │  Load Balancer  │  │  Cert-Mgr    │ │
│  │   Controller    │  │                 │  │              │ │
│  └─────────────────┘  └─────────────────┘  └──────────────┘ │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                Laravel Application                      │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐ │ │
│  │  │ Deployment  │  │   Service   │  │       HPA       │ │ │
│  │  │ (1-N pods)  │  │             │  │                 │ │ │
│  │  └─────────────┘  └─────────────┘  └─────────────────┘ │ │
│  └─────────────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                  Dependencies                           │ │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────────┐ │ │
│  │  │PostgreSQL│ │  Redis   │ │  MinIO   │ │   Mailpit    │ │ │
│  │  │          │ │          │ │          │ │              │ │ │
│  │  └──────────┘ └──────────┘ └──────────┘ └──────────────┘ │ │
│  └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## 📋 Предварительные требования

### Обязательные компоненты

- **Kubernetes**: 1.19+
- **Helm**: 3.8+
- **kubectl**: настроенный для подключения к кластеру

### Рекомендуемые компоненты

- **Ingress Controller**: nginx, traefik
- **Cert-Manager**: для автоматического управления TLS сертификатами
- **Metrics Server**: для автомасштабирования
- **Prometheus/Grafana**: для мониторинга

### Проверка готовности

```bash
# Проверка Kubernetes
kubectl cluster-info

# Проверка Helm
helm version

# Проверка ingress controller
kubectl get pods -n ingress-nginx

# Проверка cert-manager (если используется)
kubectl get pods -n cert-manager
```

## 🚀 Быстрый старт

### 1. Подготовка

```bash
# Клонирование репозитория
git clone <repository-url>
cd laravel-app

# Добавление Helm репозиториев
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Установка зависимостей
make helm-deps
```

### 2. Development деплой

```bash
# Быстрый деплой для разработки
make helm-deploy-dev

# Или с использованием скрипта
./helm/deploy.sh dev
```

### 3. Проверка статуса

```bash
# Статус деплоя
make helm-status

# Логи приложения
make k8s-logs

# Проброс портов для локального доступа
make k8s-port-forward
```

## 🌍 Конфигурация окружений

### Development

**Файл**: `helm/laravel-app/values-dev.yaml`

**Особенности**:

- Все зависимости включены
- Debug режим включен
- Минимальные ресурсы
- Ingress без TLS

```yaml
app:
  env: local
  debug: true

# Все зависимости включены
redis:
  enabled: true
postgresql:
  enabled: true
minio:
  enabled: true
mailpit:
  enabled: true

# Минимальные ресурсы
resources:
  limits:
    cpu: 200m
    memory: 256Mi
```

**Деплой**:

```bash
make helm-deploy-dev
```

### Staging

**Файл**: `helm/laravel-app/values-staging.yaml`

**Особенности**:

- Смешанный подход к зависимостям
- TLS включен
- Ограниченное автомасштабирование

```yaml
app:
  env: staging
  debug: false

# Смешанные зависимости
redis:
  enabled: true
postgresql:
  enabled: false # Внешняя БД
minio:
  enabled: true
mailpit:
  enabled: true

# Средние ресурсы
resources:
  limits:
    cpu: 500m
    memory: 512Mi

# Автомасштабирование
autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 5
```

**Деплой**:

```bash
make helm-deploy-staging
```

### Production

**Файл**: `helm/laravel-app/values-prod.yaml`

**Особенности**:

- Все зависимости внешние
- Высокие ресурсы
- Полное автомасштабирование
- Network policies

```yaml
app:
  env: production
  debug: false

# Все зависимости внешние
redis:
  enabled: false
postgresql:
  enabled: false
minio:
  enabled: false
mailpit:
  enabled: false

# Внешние сервисы
externalServices:
  postgresql:
    host: 'prod-db.amazonaws.com'
  redis:
    host: 'prod-cache.amazonaws.com'
  s3:
    endpoint: 'https://s3.amazonaws.com'

# Высокие ресурсы
resources:
  limits:
    cpu: 1000m
    memory: 1Gi

# Автомасштабирование
autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 20
```

**Деплой**:

```bash
make helm-deploy-prod
```

## 🔧 Управление зависимостями

### Включение внутренних сервисов

```yaml
# values.yaml
redis:
  enabled: true
  master:
    persistence:
      size: 8Gi
    resources:
      limits:
        cpu: 250m
        memory: 256Mi

postgresql:
  enabled: true
  auth:
    database: laravel
    username: laravel
    password: 'secure-password'
  primary:
    persistence:
      size: 8Gi

minio:
  enabled: true
  auth:
    rootUser: minioadmin
    rootPassword: 'minio-password'
  defaultBuckets: 'laravel'

mailpit:
  enabled: true
  service:
    ports:
      smtp: 1025
      http: 8025
```

### Использование внешних сервисов

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

# Настраиваем внешние
externalServices:
  postgresql:
    host: 'your-rds.amazonaws.com'
    port: 5432
    database: 'laravel_prod'
    username: 'laravel'
    password: 'secure-password'
    # Или используем существующий secret
    # existingSecret: "postgres-credentials"
    # existingSecretPasswordKey: "password"

  redis:
    host: 'your-elasticache.amazonaws.com'
    port: 6379
    password: 'redis-password'

  s3:
    endpoint: 'https://s3.amazonaws.com'
    region: 'us-east-1'
    bucket: 'your-bucket'
    accessKey: 'your-access-key'
    secretKey: 'your-secret-key'

  smtp:
    host: 'smtp.sendgrid.net'
    port: 587
    username: 'apikey'
    password: 'your-api-key'
```

## 🚀 Деплой и управление

### Команды Make

```bash
# Helm команды
make helm-lint              # Проверка chart
make helm-template          # Генерация манифестов
make helm-deps              # Установка зависимостей

# Деплой
make helm-deploy-dev        # Development
make helm-deploy-staging    # Staging
make helm-deploy-prod       # Production

# Управление
make helm-status            # Статус релиза
make helm-uninstall         # Удаление релиза

# Kubernetes
make k8s-logs              # Логи приложения
make k8s-shell             # Shell контейнера
make k8s-port-forward      # Проброс портов
```

### Скрипт деплоя

```bash
# Использование скрипта
./helm/deploy.sh [environment] [release-name] [namespace]

# Примеры
./helm/deploy.sh dev
./helm/deploy.sh staging laravel-staging laravel-staging
./helm/deploy.sh prod laravel-prod laravel-production
```

### Ручной деплой

```bash
# Development
helm install laravel-app helm/laravel-app \
  --namespace laravel-app-dev \
  --create-namespace \
  --values helm/laravel-app/values-dev.yaml

# Staging
helm install laravel-app helm/laravel-app \
  --namespace laravel-app-staging \
  --create-namespace \
  --values helm/laravel-app/values-staging.yaml

# Production
helm install laravel-app helm/laravel-app \
  --namespace laravel-app-prod \
  --create-namespace \
  --values helm/laravel-app/values-prod.yaml \
  --set externalServices.postgresql.host="your-rds.amazonaws.com" \
  --set externalServices.redis.host="your-elasticache.amazonaws.com"
```

### Обновление

```bash
# Обновление с новой версией образа
helm upgrade laravel-app helm/laravel-app \
  --namespace laravel-app-prod \
  --set image.tag="1.1.0" \
  --reuse-values

# Обновление конфигурации
helm upgrade laravel-app helm/laravel-app \
  --namespace laravel-app-prod \
  --values helm/laravel-app/values-prod.yaml
```

## 📊 Мониторинг

### Health Checks

Приложение должно предоставлять endpoint `/health`:

```php
// routes/web.php
Route::get('/health', function () {
    return response()->json([
        'status' => 'ok',
        'timestamp' => now(),
        'checks' => [
            'database' => DB::connection()->getPdo() ? 'ok' : 'fail',
            'redis' => Redis::ping() === 'PONG' ? 'ok' : 'fail',
        ]
    ]);
});
```

### Логи

```bash
# Логи приложения
kubectl logs -n laravel-app-prod -l app.kubernetes.io/name=laravel-app -f

# Логи конкретного пода
kubectl logs -n laravel-app-prod laravel-app-xxxx-yyyy

# Логи с временными метками
kubectl logs -n laravel-app-prod -l app.kubernetes.io/name=laravel-app --timestamps
```

### Метрики

```bash
# Использование ресурсов
kubectl top pods -n laravel-app-prod

# Статус HPA
kubectl get hpa -n laravel-app-prod

# События
kubectl get events -n laravel-app-prod --sort-by='.lastTimestamp'
```

## 🔒 Безопасность

### Secrets Management

```bash
# Создание secret для БД
kubectl create secret generic postgres-credentials \
  --from-literal=password=your-secure-password \
  -n laravel-app-prod

# Использование в values
externalServices:
  postgresql:
    existingSecret: "postgres-credentials"
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
      ports:
        - protocol: TCP
          port: 8000
  egress:
    - to: []
      ports:
        - protocol: TCP
          port: 443 # HTTPS
        - protocol: TCP
          port: 5432 # PostgreSQL
        - protocol: TCP
          port: 6379 # Redis
```

### Security Context

```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  runAsGroup: 1000
  capabilities:
    drop:
      - ALL
  readOnlyRootFilesystem: true
  allowPrivilegeEscalation: false
```

## 📊 Kubernetes Dashboard

### Установка Dashboard

Для мониторинга и управления кластером через веб-интерфейс можно установить Kubernetes Dashboard.

#### Быстрая установка

```bash
# Установить Dashboard
make k8s-dashboard-install

# Создать токен доступа
make k8s-dashboard-token

# Запустить доступ к Dashboard
make k8s-dashboard-access
```

#### Использование скрипта

```bash
# Полная установка
./k8s/setup-dashboard.sh install

# Создать новый токен
./k8s/setup-dashboard.sh token

# Запустить доступ
./k8s/setup-dashboard.sh access

# Проверить статус
./k8s/setup-dashboard.sh status

# Удалить Dashboard
./k8s/setup-dashboard.sh remove
```

### Доступ к Dashboard

1. **Запустите прокси**: `make k8s-dashboard-access`
2. **Откройте браузер**: http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
3. **Выберите "Token"** для входа
4. **Введите токен** полученный командой `make k8s-dashboard-token`

### Функции Dashboard

- 📊 Мониторинг ресурсов кластера
- 🚀 Управление deployments, services, pods
- 📝 Просмотр логов приложений
- ⚙️ Редактирование конфигураций
- 📈 Метрики использования ресурсов
- 🔍 Отладка проблем

### Безопасность Dashboard

Dashboard создает административного пользователя с полными правами (`cluster-admin`). В продакшене рекомендуется:

- Создать пользователей с ограниченными правами
- Использовать RBAC для контроля доступа
- Настроить TLS сертификаты
- Ограничить сетевой доступ

## 🛠️ Troubleshooting

### Документация по решению проблем

- [Certificate Issues](k8s/troubleshooting-certificates.md) - TLS и проблемы подключения kubelet
- [ImagePullBackOff](k8s/fix-image-pull.md) - Проблемы загрузки Docker образов
- [Service Endpoints](k8s/fix-service-endpoints.md) - Конфликты маршрутизации сервисов

### Общие проблемы

#### 1. Под не запускается

```bash
# Проверка статуса
kubectl get pods -n laravel-app-dev

# Детали пода
kubectl describe pod laravel-app-xxxx -n laravel-app-dev

# Логи
kubectl logs laravel-app-xxxx -n laravel-app-dev
```

#### 2. Проблемы с базой данных

```bash
# Проверка подключения к БД
kubectl exec -it deployment/laravel-app -n laravel-app-dev -- \
  php artisan tinker --execute="DB::connection()->getPdo()"

# Проверка миграций
kubectl get jobs -n laravel-app-dev -l app.kubernetes.io/component=migrate
```

#### 3. Проблемы с Redis

```bash
# Проверка Redis
kubectl exec -it deployment/laravel-app -n laravel-app-dev -- \
  php artisan tinker --execute="Redis::ping()"
```

#### 4. Проблемы с Ingress

```bash
# Статус ingress
kubectl get ingress -n laravel-app-dev

# Логи ingress controller
kubectl logs -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx
```

### Полезные команды

```bash
# Полная информация о релизе
helm get all laravel-app -n laravel-app-dev

# Откат к предыдущей версии
helm rollback laravel-app 1 -n laravel-app-dev

# Тестирование подключения
kubectl run test-pod --image=busybox --rm -it -- /bin/sh

# Проверка DNS
kubectl exec -it test-pod -- nslookup laravel-app.laravel-app-dev.svc.cluster.local
```

## 📚 Дополнительные ресурсы

- [Helm Documentation](https://helm.sh/docs/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Laravel Documentation](https://laravel.com/docs)
- [Bitnami Helm Charts](https://github.com/bitnami/charts)

## 🤝 Поддержка

Для вопросов и проблем:

1. Проверьте [Troubleshooting](#troubleshooting)
2. Создайте issue в репозитории
3. Обратитесь к команде DevOps
