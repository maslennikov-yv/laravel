# Laravel Docker для Kubernetes

Эта директория содержит Docker конфигурацию для запуска Laravel приложения в Kubernetes с PHP 8.4.

## 📁 Файлы

- `Dockerfile` - Multi-stage Dockerfile для production и development
- `php.ini` - Настройки PHP для production
- `php-dev.ini` - Настройки PHP для development с Xdebug
- `php-fpm.conf` - Конфигурация PHP-FPM
- `nginx.conf` - Основная конфигурация Nginx
- `default.conf` - Server блок Nginx для Laravel
- `supervisord.conf` - Supervisor для управления процессами
- `build-and-push.sh` - Скрипт сборки и загрузки в Microk8s registry
- `.dockerignore` - Исключения для Docker build context

## 🚀 Быстрый старт

### 1. Собрать и загрузить образ

```bash
# Production образ
make docker-push-k8s

# Development образ
make docker-build-k8s-dev

# Или напрямую скриптом
./docker/k8s/build-and-push.sh production
./docker/k8s/build-and-push.sh development
```

### 2. Развернуть в Kubernetes

```bash
# Обновить Helm релиз с новым образом
helm upgrade laravel-app helm/laravel-app \
  --namespace laravel-app-dev \
  --values helm/laravel-app/values-dev.yaml \
  --set image.registry="localhost:32000" \
  --set image.repository="laravel-app" \
  --set image.tag="latest"
```

## 🏗️ Архитектура

### Multi-stage Build

Dockerfile использует multi-stage подход:

1. **Build stage** - Установка зависимостей и сборка ассетов
2. **Production stage** - Минимальный runtime образ
3. **Development stage** - Образ с Xdebug и dev инструментами

### Сервисы в контейнере

- **Nginx** - Веб-сервер на порту 8000
- **PHP-FPM** - PHP обработчик
- **Supervisor** - Управление процессами

### Health Checks

- `/health` - Простая проверка Nginx
- `/health.php` - PHP проверка с подключением к БД
- `/fpm-ping` - Проверка PHP-FPM
- `/fpm-status` - Статус PHP-FPM

## ⚙️ Конфигурация

### PHP настройки

**Production (`php.ini`):**
- OPcache включен с оптимизацией
- Безопасность: отключены опасные функции
- Оптимизированы лимиты памяти и времени выполнения

**Development (`php-dev.ini`):**
- Xdebug включен
- Показ ошибок включен
- Увеличены лимиты для разработки

### Nginx настройки

- Оптимизирован для Laravel
- Gzip сжатие
- Кеширование статических файлов
- Безопасные заголовки
- PHP-FPM backend

### Supervisor

Управляет двумя процессами:
- Nginx (приоритет 10)
- PHP-FPM (приоритет 5)

## 🔧 Использование скрипта

### Основные команды

```bash
# Показать справку
./docker/k8s/build-and-push.sh --help

# Production образ с latest тегом
./docker/k8s/build-and-push.sh production

# Development образ с dev тегом
./docker/k8s/build-and-push.sh development

# Кастомный тег
./docker/k8s/build-and-push.sh production v1.0.0
./docker/k8s/build-and-push.sh dev feature-auth
```

### Что делает скрипт

1. ✅ Проверяет и включает Microk8s registry
2. 🔨 Собирает Docker образ с BuildKit
3. 🧪 Тестирует образ на запуск
4. 📤 Загружает в Microk8s registry
5. 📋 Показывает информацию об образе

## 🎯 Оптимизации

### Build оптимизации

- Multi-stage для уменьшения размера
- BuildKit для параллельной сборки
- Кеширование слоев Docker
- Оптимизированный .dockerignore

### Runtime оптимизации

- Alpine Linux для минимального размера
- OPcache для ускорения PHP
- Nginx оптимизирован для Laravel
- Правильные права доступа

### Security

- Non-root пользователь (www-data)
- Отключены опасные PHP функции
- Безопасные заголовки Nginx
- Ограничен доступ к sensitive файлам

## 🐛 Отладка

### Локальный запуск

```bash
# Запустить контейнер локально
docker run -d -p 8000:8000 localhost:32000/laravel-app:latest

# Зайти в контейнер
docker exec -it <container_id> /bin/bash

# Посмотреть логи
docker logs <container_id>
```

### В Kubernetes

```bash
# Логи приложения
kubectl logs -n laravel-app-dev -l app.kubernetes.io/name=laravel-app

# Подключиться к контейнеру
kubectl exec -n laravel-app-dev -it deployment/laravel-app -- /bin/bash

# Проброс портов
kubectl port-forward -n laravel-app-dev svc/laravel-app 8080:80
```

### Проверка health endpoints

```bash
# Простая проверка
curl http://localhost:8000/health

# PHP проверка
curl http://localhost:8000/health.php

# Статус PHP-FPM (внутри контейнера)
curl http://127.0.0.1:8000/fpm-status
```

## 📝 Примеры использования

### CI/CD Pipeline

```yaml
# .github/workflows/deploy.yml
- name: Build and push to Microk8s
  run: |
    ./docker/k8s/build-and-push.sh production ${{ github.sha }}
    
- name: Deploy to Kubernetes
  run: |
    helm upgrade laravel-app helm/laravel-app \
      --set image.tag="${{ github.sha }}" \
      --namespace laravel-app-prod
```

### Development workflow

```bash
# 1. Внести изменения в код
# 2. Собрать dev образ
make docker-build-k8s-dev

# 3. Обновить deployment
kubectl patch deployment laravel-app -n laravel-app-dev \
  -p '{"spec":{"template":{"metadata":{"annotations":{"date":"'$(date +'%s')'"}}}}}'

# 4. Проверить результат
kubectl port-forward -n laravel-app-dev svc/laravel-app 8080:80
```

## 🔗 Связанные файлы

- `helm/laravel-app/values-dev.yaml` - Helm values для development
- `k8s/fix-image-pull.sh` - Решение проблем с образами
- `Makefile` - Make команды для сборки
- `KUBERNETES.md` - Общая K8s документация 