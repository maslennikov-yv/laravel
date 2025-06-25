# GitHub Actions CI/CD

Этот проект использует GitHub Actions для автоматизации CI/CD процессов.

## Workflows

### 1. CI (`ci.yml`)

**Триггеры:** Push в `main`/`develop`, Pull Request
**Задачи:**

- Тестирование с PostgreSQL и Redis
- Линтинг кода (PHP CS Fixer, PHPStan)
- Проверка безопасности
- Сборка Docker образов

### 2. CD - Development (`cd-dev.yml`)

**Триггеры:** Push в `develop`, ручной запуск
**Задачи:**

- Сборка и публикация Docker образов в GitHub Container Registry
- Автоматический деплой в development окружение
- Проверка здоровья приложения

### 3. CD - Production (`cd-prod.yml`)

**Триггеры:** Push тегов `v*`, ручной запуск
**Задачи:**

- Сборка и публикация Docker образов
- Деплой в production окружение (с подтверждением)
- Создание GitHub Release

### 4. Security Scan (`security.yml`)

**Триггеры:** Еженедельно, push, pull request
**Задачи:**

- Сканирование зависимостей
- Анализ кода на уязвимости
- Сканирование Docker образов
- CodeQL анализ

## Настройка Secrets

### Обязательные Secrets

1. **KUBE_CONFIG_DEV** - Base64-encoded kubeconfig для development кластера

   ```bash
   cat ~/.kube/config | base64 -w 0
   ```

2. **KUBE_CONFIG_PROD** - Base64-encoded kubeconfig для production кластера
   ```bash
   cat ~/.kube/config | base64 -w 0
   ```

### Опциональные Secrets

3. **SNYK_TOKEN** - Токен для Snyk security scanning
4. **DOCKER_USERNAME** - Docker Hub username (если используете Docker Hub)
5. **DOCKER_PASSWORD** - Docker Hub password

## Настройка Environments

### Development Environment

1. Перейдите в Settings → Environments
2. Создайте environment `development`
3. Добавьте protection rules если нужно
4. Добавьте secret `KUBE_CONFIG_DEV`

### Production Environment

1. Создайте environment `production`
2. Включите required reviewers
3. Добавьте secret `KUBE_CONFIG_PROD`

## Настройка Branch Protection

Рекомендуемые правила для `main` и `develop`:

- Require status checks to pass before merging
- Require branches to be up to date before merging
- Require pull request reviews before merging
- Require conversation resolution before merging

## Использование

### Автоматический деплой

- Push в `develop` → автоматический деплой в development
- Push тег `v1.0.0` → автоматический деплой в production

### Ручной деплой

1. Перейдите в Actions
2. Выберите нужный workflow
3. Нажмите "Run workflow"
4. Выберите branch и параметры

### Мониторинг

- Все результаты доступны в Actions tab
- Security alerts в Security tab
- Coverage reports в Codecov (если настроен)

## Troubleshooting

### Проблемы с Docker

- Проверьте Dockerfile на корректность
- Убедитесь, что все зависимости установлены

### Проблемы с Kubernetes

- Проверьте kubeconfig на корректность
- Убедитесь, что namespace существует
- Проверьте права доступа к кластеру

### Проблемы с Helm

- Проверьте values файлы
- Убедитесь, что Helm chart корректный
- Проверьте версии Helm и Kubernetes

## Локальная разработка

Для локальной разработки используйте команды из Makefile:

```bash
# Тестирование
make test

# Линтинг
make lint

# Сборка Docker
make docker-build-k8s

# Деплой в локальный кластер
make helm-deploy-dev
```
