# 🐳 Docker Setup Guide

Этот проект настроен для работы с Docker и Laravel Sail с PHP 8.4.

## 🚀 Быстрый старт

### Полная настройка одной командой:

```bash
make setup
```

Эта команда:

- Проверит и установит Laravel Sail (если нужно)
- Скопирует `.env.example` в `.env`
- Запустит Docker контейнеры
- Установит PHP зависимости
- Сгенерирует ключ приложения
- Выполнит миграции и seeders

### Ежедневное использование:

```bash
# Запустить контейнеры
make up

# Остановить контейнеры
make down

# Войти в shell контейнера
make shell

# Запустить тесты
make test
```

## 📋 Доступные команды

### 🐳 Управление контейнерами

```bash
make up           # Запустить контейнеры
make down         # Остановить контейнеры
make build        # Пересобрать контейнеры
make shell        # Войти в shell контейнера
make sail-logs    # Посмотреть логи
```

### 🧪 Тестирование

```bash
make test         # Все тесты
make test-unit    # Unit тесты
make test-feature # Feature тесты
make test-coverage # Тесты с покрытием
make test-parallel # Параллельные тесты
```

### 🛠️ Разработка

```bash
make migrate      # Миграции
make migrate-fresh # Пересоздать БД
make seed         # Seeders
make clean        # Очистить кеш
```

### 📦 Зависимости

```bash
make install      # PHP зависимости
make npm-install  # npm зависимости
make npm-dev      # Vite dev server
make npm-build    # Сборка фронтенда
```

## 🔧 Прямые команды Sail

Если нужно выполнить команды напрямую:

```bash
# Artisan команды
vendor/bin/sail artisan migrate
vendor/bin/sail artisan tinker

# Composer команды
vendor/bin/sail composer require package/name
vendor/bin/sail composer update

# npm команды
vendor/bin/sail npm install
vendor/bin/sail npm run dev

# Тесты
vendor/bin/sail pest
vendor/bin/sail pest --coverage
```

## 🗂️ Структура сервисов

Docker Compose включает следующие сервисы:

- **Laravel App** (PHP 8.4) - основное приложение
- **PostgreSQL** - база данных
- **Redis** - кеширование и очереди
- **Mailpit** - тестирование email
- **Meilisearch** - полнотекстовый поиск
- **MinIO** - S3-совместимое хранилище
- **Selenium** - браузерные тесты

## 🌐 Доступные URL

После запуска `make up`:

- **Приложение**: http://localhost
- **Mailpit**: http://localhost:8025
- **MinIO**: http://localhost:9000
- **Meilisearch**: http://localhost:7700

## 🔍 Отладка

### Просмотр логов

```bash
make sail-logs
# или для конкретного сервиса
vendor/bin/sail logs laravel.test
```

### Выполнение команд в контейнере

```bash
# Войти в shell
make shell

# Выполнить команду
vendor/bin/sail exec laravel.test bash
```

### Проверка статуса контейнеров

```bash
docker ps
```

## 🛠️ Troubleshooting

### Контейнеры не запускаются

```bash
# Пересобрать контейнеры
make build

# Проверить логи
make sail-logs
```

### Проблемы с правами доступа

```bash
# Исправить права на файлы
sudo chown -R $USER:$USER .
```

### Очистка Docker

```bash
# Остановить все контейнеры
make down

# Удалить неиспользуемые образы
docker system prune -f
```

## 📚 Дополнительная информация

- [Laravel Sail Documentation](https://laravel.com/docs/sail)
- [Docker Documentation](https://docs.docker.com/)
- [Тестирование с Pest](TESTING.md)
