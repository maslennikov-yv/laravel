.PHONY: test test-unit test-feature test-coverage test-parallel test-watch help help-quick help-k8s sail-up sail-down sail-build install-sail setup helm-lint helm-template helm-deps helm-deploy-dev helm-deploy-staging helm-deploy-prod helm-status helm-uninstall helm-test k8s-logs k8s-shell k8s-port-forward k8s-dashboard-install k8s-dashboard-token k8s-dashboard-access k8s-dashboard-remove k8s-fix-certs k8s-fix-image-pull docker-build-k8s docker-build-k8s-dev docker-push-k8s

# По умолчанию показать основные команды
.DEFAULT_GOAL := help-quick

# Цвета для вывода
GREEN := \033[32m
YELLOW := \033[33m
RED := \033[31m
BLUE := \033[34m
CYAN := \033[36m
RESET := \033[0m

# =============================================================================
# Kubernetes K8S Config (namespace + shell)
# =============================================================================

# Формат файла .k8s:
# NAMESPACE=laravel-app-dev
# SHELL=/bin/sh

# 1. Переменные окружения: K8S_NAMESPACE, K8S_SHELL
# 2. Файл .k8s (ключ=значение)
# 3. Дефолты: laravel-app-dev, /bin/sh

K8S_CONFIG_FILE := .k8s

# Получить namespace
ifeq ($(origin K8S_NAMESPACE), environment)
    K8S_DEFAULT_NS := $(K8S_NAMESPACE)
else
    ifneq (,$(wildcard $(K8S_CONFIG_FILE)))
        K8S_DEFAULT_NS := $(shell grep '^NAMESPACE=' $(K8S_CONFIG_FILE) | cut -d'=' -f2)
        ifeq ($(K8S_DEFAULT_NS),)
            K8S_DEFAULT_NS := laravel-app-dev
        endif
    else
        K8S_DEFAULT_NS := laravel-app-dev
    endif
endif

# Получить shell
ifeq ($(origin K8S_SHELL), environment)
    K8S_DEFAULT_SHELL := $(K8S_SHELL)
else
    ifneq (,$(wildcard $(K8S_CONFIG_FILE)))
        K8S_DEFAULT_SHELL := $(shell grep '^SHELL=' $(K8S_CONFIG_FILE) | cut -d'=' -f2)
        ifeq ($(K8S_DEFAULT_SHELL),)
            K8S_DEFAULT_SHELL := /bin/sh
        endif
    else
        K8S_DEFAULT_SHELL := /bin/sh
    endif
endif

# Команды для управления k8s config
k8s-config-set: ## Установить дефолтный namespace и shell для k8s команд
	@echo "$(BLUE)Установка дефолтного namespace и shell для k8s команд...$(RESET)"
	@read -p "Enter namespace (default: $(K8S_DEFAULT_NS)): " namespace; \
	namespace=$${namespace:-$(K8S_DEFAULT_NS)}; \
	read -p "Enter shell path (default: $(K8S_DEFAULT_SHELL)): " shell; \
	shell=$${shell:-$(K8S_DEFAULT_SHELL)}; \
	echo "NAMESPACE=$$namespace" > .k8s; \
	echo "SHELL=$$shell" >> .k8s; \
	echo "$(GREEN)Конфиг .k8s обновлён: NAMESPACE=$$namespace, SHELL=$$shell$(RESET)";

k8s-config-show: ## Показать текущий дефолтный namespace и shell
	@echo "$(BLUE)Текущий k8s config:$(RESET)"
	@echo "  Namespace: $(GREEN)$(K8S_DEFAULT_NS)$(RESET)"
	@echo "  Shell:     $(GREEN)$(K8S_DEFAULT_SHELL)$(RESET)"
	@if [ -f .k8s ]; then \
		echo "$(CYAN)Источник: файл .k8s$(RESET)"; \
	elif [ -n "$(K8S_NAMESPACE)" ] || [ -n "$(K8S_SHELL)" ]; then \
		echo "$(CYAN)Источник: переменные окружения$(RESET)"; \
	else \
		echo "$(CYAN)Источник: дефолтные значения$(RESET)"; \
	fi

k8s-config-reset: ## Сбросить дефолтный namespace и shell к значениям по умолчанию
	@echo "$(BLUE)Сброс k8s config...$(RESET)"
	@rm -f .k8s; \
	echo "$(GREEN)Конфиг .k8s сброшен к значениям по умолчанию$(RESET)"

k8s-config-env: ## Показать команды для установки через переменные окружения
	@echo "$(BLUE)Команды для установки через переменные окружения:$(RESET)"
	@echo "$(YELLOW)export K8S_NAMESPACE=laravel-app-dev$(RESET)"
	@echo "$(YELLOW)export K8S_SHELL=/bin/sh$(RESET)"
	@echo "$(YELLOW)export K8S_SHELL=/bin/bash$(RESET)"
	@echo ""
	@echo "$(CYAN)Для постоянной установки добавьте в ~/.bashrc или ~/.zshrc:$(RESET)"
	@echo "$(YELLOW)echo 'export K8S_NAMESPACE=laravel-app-dev' >> ~/.bashrc$(RESET)"
	@echo "$(YELLOW)echo 'export K8S_SHELL=/bin/bash' >> ~/.bashrc$(RESET)"

# Алиасы
k8s-cfg: k8s-config-show
k8s-cfg-set: k8s-config-set
k8s-cfg-reset: k8s-config-reset
k8s-cfg-env: k8s-config-env

# Docker/Sail команды
SAIL := vendor/bin/sail
PEST := $(SAIL) pest

help: ## Показать справку
	@echo "$(BLUE)📚 Laravel Example App - Доступные команды:$(RESET)"
	@echo ""
	@echo "$(GREEN)🚀 Быстрый старт:$(RESET)"
	@echo "  $(YELLOW)setup$(RESET)                          Настроить проект в Docker (первый запуск)"
	@echo "  $(YELLOW)sail-up$(RESET)                        Запустить Docker контейнеры"
	@echo "  $(YELLOW)sail-down$(RESET)                      Остановить Docker контейнеры"
	@echo ""
	@echo "$(GREEN)🧪 Тестирование:$(RESET)"
	@grep -E '^test[a-zA-Z_-]*:.*## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*## "}; {printf "  $(YELLOW)%-30s$(RESET) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(GREEN)🔧 Разработка:$(RESET)"
	@echo "  $(YELLOW)install$(RESET)                        Установить зависимости в Docker"
	@echo "  $(YELLOW)update$(RESET)                         Обновить зависимости в Docker"
	@echo "  $(YELLOW)clean$(RESET)                          Очистить кеш и временные файлы в Docker"
	@echo "  $(YELLOW)migrate$(RESET)                        Запустить миграции в Docker"
	@echo "  $(YELLOW)migrate-fresh$(RESET)                  Пересоздать базу данных и запустить миграции"
	@echo "  $(YELLOW)seed$(RESET)                           Запустить seeders в Docker"
	@echo ""
	@echo "$(GREEN)🎨 Frontend:$(RESET)"
	@echo "  $(YELLOW)npm-install$(RESET)                    Установить npm зависимости в Docker"
	@echo "  $(YELLOW)npm-dev$(RESET)                        Запустить npm dev в Docker"
	@echo "  $(YELLOW)npm-build$(RESET)                      Собрать фронтенд в Docker"
	@echo ""
	@echo "$(GREEN)🔍 Линтинг и исправление кода:$(RESET)"
	@echo "  $(YELLOW)lint$(RESET)                           Запустить все линтеры в Docker"
	@echo "  $(YELLOW)lint-fix$(RESET)                       Исправить все ошибки линтеров в Docker"
	@echo "  $(YELLOW)eslint$(RESET)                         Запустить ESLint для JS/TS в Docker"
	@echo "  $(YELLOW)eslint-fix$(RESET)                     Исправить JS/TS с ESLint в Docker"
	@echo "  $(YELLOW)stylelint$(RESET)                      Запустить Stylelint для CSS/SCSS в Docker"
	@echo "  $(YELLOW)stylelint-fix$(RESET)                  Исправить CSS/SCSS с Stylelint в Docker"
	@echo "  $(YELLOW)prettier$(RESET)                       Запустить Prettier для форматирования в Docker"
	@echo "  $(YELLOW)prettier-fix$(RESET)                   Исправить форматирование с Prettier в Docker"
	@echo ""
	@echo "$(GREEN)🐳 Docker/Sail:$(RESET)"
	@grep -E '^sail-[a-zA-Z_-]+:.*## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*## "}; {printf "  $(YELLOW)%-30s$(RESET) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(GREEN)🔨 Утилиты:$(RESET)"
	@echo "  $(YELLOW)artisan$(RESET)                        Выполнить artisan команду (make artisan CMD=\"route:list\")"
	@echo "  $(YELLOW)composer$(RESET)                       Выполнить composer команду (make composer CMD=\"require package\")"
	@echo "  $(YELLOW)install-sail$(RESET)                   Установить Laravel Sail (если не установлен)"
	@echo ""
	@echo "$(GREEN)🏠 Локальные команды (без Docker):$(RESET)"
	@echo "  $(YELLOW)test-local$(RESET)                     Запустить тесты локально (без Docker)"
	@echo "  $(YELLOW)install-local$(RESET)                  Установить зависимости локально"
	@echo ""
	@echo "$(GREEN)☸️  Kubernetes:$(RESET)"
	@echo "  $(YELLOW)k8s-logs$(RESET)                       Логи приложения"
	@echo "  $(YELLOW)k8s-shell$(RESET)                      Shell в pod"
	@echo "  $(YELLOW)k8s-status$(RESET)                     Статус ресурсов"
	@echo "  $(YELLOW)k8s-port-forward$(RESET)               Проброс портов"
	@echo "  $(YELLOW)k8s-artisan$(RESET)                    Artisan команда"
	@echo "  $(YELLOW)k8s-scale$(RESET)                      Масштабировать"
	@echo ""
	@echo "$(BLUE)💡 Справка:$(RESET)"
	@echo "  $(YELLOW)help$(RESET)                           Показать эту справку (все команды)"
	@echo "  $(YELLOW)help-quick$(RESET)                     Показать только основные команды"
	@echo "  $(YELLOW)help-k8s$(RESET)                       Показать все Kubernetes/Helm команды"
	@echo ""
	@echo "$(CYAN)📖 Документация:$(RESET)"
	@echo "  README.md           - Основная документация проекта"
	@echo "  KUBERNETES.md       - Документация по Kubernetes"
	@echo "  DOCKER.md           - Документация по Docker"
	@echo "  TESTING.md          - Документация по тестированию"
	@echo "  docker/k8s/README.md - Docker для Kubernetes"

help-quick: ## Показать только основные команды
	@echo "$(BLUE)⚡ Основные команды Laravel Example App:$(RESET)"
	@echo ""
	@echo "$(GREEN)🚀 Быстрый старт:$(RESET)"
	@echo "  $(YELLOW)make setup$(RESET)          - Настроить проект (первый запуск)"
	@echo "  $(YELLOW)make up$(RESET)             - Запустить контейнеры"
	@echo "  $(YELLOW)make down$(RESET)           - Остановить контейнеры"
	@echo ""
	@echo "$(GREEN)🧪 Тестирование:$(RESET)"
	@echo "  $(YELLOW)make t$(RESET)              - Запустить все тесты"
	@echo "  $(YELLOW)make tc$(RESET)             - Тесты с покрытием кода"
	@echo "  $(YELLOW)make tw$(RESET)             - Тесты в режиме наблюдения"
	@echo ""
	@echo "$(GREEN)🔧 Разработка:$(RESET)"
	@echo "  $(YELLOW)make migrate$(RESET)        - Запустить миграции"
	@echo "  $(YELLOW)make clean$(RESET)          - Очистить кеш"
	@echo "  $(YELLOW)make shell$(RESET)          - Войти в контейнер"
	@echo ""
	@echo "$(GREEN)🔍 Линтинг:$(RESET)"
	@echo "  $(YELLOW)make lint$(RESET)           - Запустить все линтеры"
	@echo "  $(YELLOW)make lint-fix$(RESET)       - Исправить все ошибки"
	@echo "  $(YELLOW)make eslint-fix$(RESET)     - Исправить JS/TS ошибки"
	@echo ""
	@echo "$(GREEN)☸️  Kubernetes:$(RESET)"
	@echo "  $(YELLOW)make k8s-logs$(RESET)        - Логи приложения"
	@echo "  $(YELLOW)make k8s-shell$(RESET)       - Shell в pod"
	@echo "  $(YELLOW)make k8s-status$(RESET)      - Статус ресурсов"
	@echo "  $(YELLOW)make k8s-port-forward$(RESET) - Проброс портов"
	@echo "  $(YELLOW)make k8s-artisan$(RESET)     - Artisan команда"
	@echo "  $(YELLOW)make k8s-scale$(RESET)       - Масштабировать"
	@echo ""
	@echo "$(CYAN)Полный список команд: $(YELLOW)make help$(RESET) или $(YELLOW)make help-k8s$(RESET)"

help-k8s: ## Показать Kubernetes/Helm команды
	@echo "$(BLUE)Kubernetes и Helm команды:$(RESET)"
	@echo "$(GREEN)Управление Namespace:$(RESET)"
	@echo "  $(YELLOW)k8s-namespace-set$(RESET)        Установить дефолтный namespace для k8s команд"
	@echo "  $(YELLOW)k8s-namespace-show$(RESET)       Показать текущий дефолтный namespace"
	@echo "  $(YELLOW)k8s-namespace-reset$(RESET)      Сбросить дефолтный namespace"
	@echo "  $(YELLOW)k8s-namespace-env$(RESET)        Показать команды для установки через переменную"
	@echo "  $(YELLOW)k8s-ns$(RESET)                   Алиас для k8s-namespace-show"
	@echo "  $(YELLOW)k8s-ns-set$(RESET)               Алиас для k8s-namespace-set"
	@echo "  $(YELLOW)k8s-ns-reset$(RESET)             Алиас для k8s-namespace-reset"
	@echo ""
	@echo "$(GREEN)Управление Shell:$(RESET)"
	@echo "  $(YELLOW)k8s-shell-set$(RESET)            Установить дефолтный shell для k8s команд"
	@echo "  $(YELLOW)k8s-shell-show$(RESET)           Показать текущий дефолтный shell"
	@echo "  $(YELLOW)k8s-shell-reset$(RESET)          Сбросить дефолтный shell"
	@echo "  $(YELLOW)k8s-shell-env$(RESET)            Показать команды для установки через переменную"
	@echo "  $(YELLOW)k8s-sh$(RESET)                   Алиас для k8s-shell-show"
	@echo "  $(YELLOW)k8s-sh-set$(RESET)               Алиас для k8s-shell-set"
	@echo "  $(YELLOW)k8s-sh-reset$(RESET)             Алиас для k8s-shell-reset"
	@echo ""
	@echo "$(GREEN)Docker для Kubernetes:$(RESET)"
	@echo "  $(YELLOW)docker-build-k8s$(RESET)           Собрать Docker образ для Kubernetes (production)"
	@echo "  $(YELLOW)docker-build-k8s-dev$(RESET)       Собрать Docker образ для Kubernetes (development)"
	@echo "  $(YELLOW)docker-push-k8s$(RESET)            Собрать и загрузить образ в Microk8s registry"
	@echo ""
	@echo "$(GREEN)Helm команды:$(RESET)"
	@grep -E '^helm-[a-zA-Z_-]+:.*## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*## "}; {printf "  $(YELLOW)%-30s$(RESET) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(GREEN)Kubernetes команды:$(RESET)"
	@grep -E '^k8s-[a-zA-Z_-]+:.*## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*## "}; {printf "  $(YELLOW)%-30s$(RESET) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(GREEN)🚀 Быстрые команды Kubernetes (алиасы):$(RESET)"
	@echo "  $(YELLOW)k8s-l$(RESET)   → k8s-logs                    $(YELLOW)k8s-s$(RESET)   → k8s-shell"
	@echo "  $(YELLOW)k8s-lp$(RESET)  → k8s-logs-php                $(YELLOW)k8s-sp$(RESET)  → k8s-shell-php"
	@echo "  $(YELLOW)k8s-ln$(RESET)  → k8s-logs-nginx              $(YELLOW)k8s-sn$(RESET)  → k8s-shell-nginx"
	@echo "  $(YELLOW)k8s-lq$(RESET)  → k8s-logs-queue              $(YELLOW)k8s-sq$(RESET)  → k8s-shell-queue"
	@echo "  $(YELLOW)k8s-sf$(RESET)  → k8s-shell-first             $(YELLOW)k8s-pf$(RESET)  → k8s-port-forward"
	@echo "  $(YELLOW)k8s-st$(RESET)  → k8s-status                  $(YELLOW)k8s-d$(RESET)   → k8s-describe"
	@echo "  $(YELLOW)k8s-sc$(RESET)  → k8s-scale                   $(YELLOW)k8s-sch$(RESET) → k8s-scale-helm"
	@echo "  $(YELLOW)k8s-a$(RESET)   → k8s-artisan                 $(YELLOW)k8s-m$(RESET)   → k8s-migrate"
	@echo "  $(YELLOW)k8s-mf$(RESET)  → k8s-migrate-fresh           $(YELLOW)k8s-se$(RESET)  → k8s-seed"
	@echo "  $(YELLOW)k8s-cc$(RESET)  → k8s-cache-clear             $(YELLOW)k8s-cac$(RESET) → k8s-config-cache"
	@echo "  $(YELLOW)k8s-qw$(RESET)  → k8s-queue-work              $(YELLOW)k8s-qf$(RESET)  → k8s-queue-failed"
	@echo "  $(YELLOW)k8s-qr$(RESET)  → k8s-queue-retry             $(YELLOW)k8s-qfl$(RESET) → k8s-queue-flush"
	@echo "  $(YELLOW)k8s-r$(RESET)   → k8s-restart                 $(YELLOW)k8s-rb$(RESET)  → k8s-rollback"
	@echo "  $(YELLOW)k8s-rbt$(RESET) → k8s-rollback-to            $(YELLOW)k8s-rs$(RESET)  → k8s-rollout-status"
	@echo "  $(YELLOW)k8s-rh$(RESET)  → k8s-rollout-history         $(YELLOW)k8s-t$(RESET)   → k8s-top"
	@echo "  $(YELLOW)k8s-e$(RESET)   → k8s-events                  $(YELLOW)k8s-i$(RESET)   → k8s-ingress-status"
	@echo "  $(YELLOW)k8s-pvc$(RESET) → k8s-pvc-status              $(YELLOW)k8s-sv$(RESET)  → k8s-secret-view"
	@echo "  $(YELLOW)k8s-cmv$(RESET) → k8s-configmap-view          $(YELLOW)k8s-ea$(RESET)  → k8s-exec-all"

# =============================================================================
# Docker/Sail команды
# =============================================================================

sail-up: ## Запустить Docker контейнеры
	@echo "$(BLUE)Запуск Docker контейнеров...$(RESET)"
	$(SAIL) up -d

sail-down: ## Остановить Docker контейнеры
	@echo "$(BLUE)Остановка Docker контейнеров...$(RESET)"
	$(SAIL) down

sail-build: ## Пересобрать Docker контейнеры
	@echo "$(BLUE)Пересборка Docker контейнеров...$(RESET)"
	$(SAIL) build --no-cache

sail-logs: ## Показать логи контейнеров
	@echo "$(BLUE)Показ логов контейнеров...$(RESET)"
	$(SAIL) logs -f

sail-shell: ## Войти в shell контейнера приложения
	@echo "$(BLUE)Вход в shell контейнера...$(RESET)"
	$(SAIL) shell

# =============================================================================
# Тестирование
# =============================================================================

test: ## Запустить все тесты в Docker
	@echo "$(GREEN)Запуск всех тестов в Docker...$(RESET)"
	$(PEST)

test-unit: ## Запустить только Unit тесты в Docker
	@echo "$(GREEN)Запуск Unit тестов в Docker...$(RESET)"
	$(PEST) tests/Unit

test-feature: ## Запустить только Feature тесты в Docker
	@echo "$(GREEN)Запуск Feature тестов в Docker...$(RESET)"
	$(PEST) tests/Feature

test-coverage: ## Запустить тесты с покрытием кода в Docker
	@echo "$(GREEN)Запуск тестов с покрытием кода в Docker...$(RESET)"
	$(PEST) --coverage

test-coverage-html: ## Создать HTML отчет о покрытии в Docker
	@echo "$(GREEN)Создание HTML отчета о покрытии в Docker...$(RESET)"
	$(PEST) --coverage-html=coverage-report

test-parallel: ## Запустить тесты параллельно в Docker
	@echo "$(GREEN)Запуск тестов параллельно в Docker...$(RESET)"
	$(PEST) --parallel

test-watch: ## Запустить тесты в режиме наблюдения в Docker
	@echo "$(GREEN)Запуск тестов в режиме наблюдения в Docker...$(RESET)"
	$(PEST) --watch

test-group: ## Запустить тесты определенной группы (make test-group GROUP=auth)
	@echo "$(GREEN)Запуск тестов группы $(GROUP) в Docker...$(RESET)"
	$(PEST) --group=$(GROUP)

test-filter: ## Запустить тесты с фильтром (make test-filter FILTER="User Model")
	@echo "$(GREEN)Запуск тестов с фильтром '$(FILTER)' в Docker...$(RESET)"
	$(PEST) --filter="$(FILTER)"

test-debug: ## Запустить тесты с отладочной информацией в Docker
	@echo "$(GREEN)Запуск тестов с отладкой в Docker...$(RESET)"
	$(PEST) --debug

test-verbose: ## Запустить тесты с подробным выводом в Docker
	@echo "$(GREEN)Запуск тестов с подробным выводом в Docker...$(RESET)"
	$(PEST) --verbose

# =============================================================================
# Разработка
# =============================================================================

install: ## Установить зависимости в Docker
	@echo "$(GREEN)Установка зависимостей в Docker...$(RESET)"
	$(SAIL) composer install

update: ## Обновить зависимости в Docker
	@echo "$(GREEN)Обновление зависимостей в Docker...$(RESET)"
	$(SAIL) composer update

clean: ## Очистить кеш и временные файлы в Docker
	@echo "$(GREEN)Очистка кеша в Docker...$(RESET)"
	$(SAIL) artisan cache:clear
	$(SAIL) artisan config:clear
	$(SAIL) artisan route:clear
	$(SAIL) artisan view:clear
	rm -rf coverage-report/

migrate: ## Запустить миграции в Docker
	@echo "$(GREEN)Запуск миграций в Docker...$(RESET)"
	$(SAIL) artisan migrate

migrate-fresh: ## Пересоздать базу данных и запустить миграции
	@echo "$(GREEN)Пересоздание базы данных в Docker...$(RESET)"
	$(SAIL) artisan migrate:fresh --seed

seed: ## Запустить seeders в Docker
	@echo "$(GREEN)Запуск seeders в Docker...$(RESET)"
	$(SAIL) artisan db:seed

install-sail: ## Установить Laravel Sail (если не установлен)
	@echo "$(BLUE)Проверка и установка Laravel Sail...$(RESET)"
	@if [ ! -f "vendor/bin/sail" ]; then \
		echo "$(YELLOW)Установка зависимостей через Docker...$(RESET)"; \
		docker run --rm -u "$$(id -u):$$(id -g)" -v "$$(pwd):/var/www/html" -w /var/www/html laravelsail/php84-composer:latest composer install --ignore-platform-reqs; \
	else \
		echo "$(GREEN)✅ Laravel Sail уже установлен$(RESET)"; \
	fi

setup: install-sail ## Настроить проект в Docker
	@echo "$(GREEN)Настройка проекта в Docker...$(RESET)"
	@if [ ! -f .env ]; then cp .env.example .env; fi
	$(SAIL) up -d
	$(SAIL) composer install
	$(SAIL) artisan key:generate
	$(SAIL) artisan migrate:fresh --seed
	@echo "$(GREEN)Проект настроен! Доступен по адресу: http://localhost$(RESET)"

# =============================================================================
# Утилиты
# =============================================================================

npm-install: ## Установить npm зависимости в Docker
	@echo "$(GREEN)Установка npm зависимостей в Docker...$(RESET)"
	$(SAIL) npm install

npm-dev: ## Запустить npm dev в Docker
	@echo "$(GREEN)Запуск npm dev в Docker...$(RESET)"
	$(SAIL) npm run dev

npm-build: ## Собрать фронтенд в Docker
	@echo "$(GREEN)Сборка фронтенда в Docker...$(RESET)"
	$(SAIL) npm run build

artisan: ## Выполнить artisan команду (make artisan CMD="route:list")
	@echo "$(GREEN)Выполнение artisan $(CMD) в Docker...$(RESET)"
	$(SAIL) artisan $(CMD)

composer: ## Выполнить composer команду (make composer CMD="require package")
	@echo "$(GREEN)Выполнение composer $(CMD) в Docker...$(RESET)"
	$(SAIL) composer $(CMD)

# =============================================================================
# Локальные команды (без Docker)
# =============================================================================

test-local: ## Запустить тесты локально (без Docker)
	@echo "$(YELLOW)Запуск тестов локально...$(RESET)"
	./vendor/bin/pest

install-local: ## Установить зависимости локально
	@echo "$(YELLOW)Установка зависимостей локально...$(RESET)"
	composer install

# =============================================================================
# Helm/Kubernetes команды
# =============================================================================

helm-lint: ## Проверить Helm chart
	@echo "$(BLUE)Проверка Helm chart...$(RESET)"
	helm lint helm/laravel-app

helm-template: ## Показать сгенерированные Kubernetes манифесты
	@echo "$(BLUE)Генерация Kubernetes манифестов...$(RESET)"
	helm template laravel-app helm/laravel-app --values helm/laravel-app/values-dev.yaml

helm-deps: ## Установить зависимости Helm chart
	@echo "$(BLUE)Установка зависимостей Helm chart...$(RESET)"
	cd helm/laravel-app && helm dependency build

helm-deploy-dev: ## Развернуть в development окружении
	@echo "$(BLUE)Развертывание в development...$(RESET)"
	./helm/deploy.sh dev

helm-deploy-staging: ## Развернуть в staging окружении
	@echo "$(BLUE)Развертывание в staging...$(RESET)"
	./helm/deploy.sh staging

helm-deploy-prod: ## Развернуть в production окружении
	@echo "$(BLUE)Развертывание в production...$(RESET)"
	./helm/deploy.sh prod

helm-status: ## Показать статус Helm релиза
	@echo "$(BLUE)Статус Helm релиза...$(RESET)"
	@read -p "Enter release name (default: laravel-app): " release; \
	release=$${release:-laravel-app}; \
	read -p "Enter namespace (default: laravel-app-dev): " namespace; \
	namespace=$${namespace:-laravel-app-dev}; \
	helm status $$release -n $$namespace

helm-uninstall: ## Удалить Helm релиз
	@echo "$(RED)Удаление Helm релиза...$(RESET)"
	@read -p "Enter release name (default: laravel-app): " release; \
	release=$${release:-laravel-app}; \
	read -p "Enter namespace (default: laravel-app-dev): " namespace; \
	namespace=$${namespace:-laravel-app-dev}; \
	echo "$(RED)WARNING: This will delete the release $$release in namespace $$namespace$(RESET)"; \
	read -p "Are you sure? (yes/no): " confirm; \
	if [ "$$confirm" = "yes" ]; then helm uninstall $$release -n $$namespace; fi

helm-test: ## Запустить тесты Helm chart
	@echo "$(BLUE)Запуск тестов Helm chart...$(RESET)"
	./helm/test-chart.sh

k8s-logs: ## Показать логи приложения в Kubernetes
	@echo "$(BLUE)Логи приложения в namespace $(K8S_DEFAULT_NS)...$(RESET)"
	kubectl logs -n $(K8S_DEFAULT_NS) -l app.kubernetes.io/name=laravel-app -f

k8s-logs-php: ## Показать логи PHP-FPM контейнера
	@echo "$(BLUE)Логи PHP-FPM контейнера в namespace $(K8S_DEFAULT_NS)...$(RESET)"
	kubectl logs -n $(K8S_DEFAULT_NS) -l app.kubernetes.io/name=laravel-app -c php-fpm -f

k8s-logs-nginx: ## Показать логи Nginx контейнера
	@echo "$(BLUE)Логи Nginx контейнера в namespace $(K8S_DEFAULT_NS)...$(RESET)"
	kubectl logs -n $(K8S_DEFAULT_NS) -l app.kubernetes.io/name=laravel-app -c nginx -f

k8s-logs-queue: ## Показать логи Queue Worker контейнера
	@echo "$(BLUE)Логи Queue Worker контейнера в namespace $(K8S_DEFAULT_NS)...$(RESET)"
	kubectl logs -n $(K8S_DEFAULT_NS) -l app.kubernetes.io/name=laravel-app -c queue -f

k8s-shell: ## Подключиться к shell контейнера
	@echo "$(BLUE)Подключение к shell контейнера в namespace $(K8S_DEFAULT_NS) с shell $(K8S_DEFAULT_SHELL)...$(RESET)"
	kubectl exec -n $(K8S_DEFAULT_NS) -it deployment/laravel-app -- $(K8S_DEFAULT_SHELL)

k8s-shell-php: ## Подключиться к shell PHP-FPM контейнера
	@echo "$(BLUE)Подключение к shell PHP-FPM контейнера в namespace $(K8S_DEFAULT_NS) с shell $(K8S_DEFAULT_SHELL)...$(RESET)"
	kubectl exec -n $(K8S_DEFAULT_NS) -it deployment/laravel-app -c php-fpm -- $(K8S_DEFAULT_SHELL)

k8s-shell-nginx: ## Подключиться к shell Nginx контейнера
	@echo "$(BLUE)Подключение к shell Nginx контейнера в namespace $(K8S_DEFAULT_NS) с shell $(K8S_DEFAULT_SHELL)...$(RESET)"
	kubectl exec -n $(K8S_DEFAULT_NS) -it deployment/laravel-app -c nginx -- $(K8S_DEFAULT_SHELL)

k8s-shell-queue: ## Подключиться к shell Queue Worker контейнера
	@echo "$(BLUE)Подключение к shell Queue Worker контейнера в namespace $(K8S_DEFAULT_NS) с shell $(K8S_DEFAULT_SHELL)...$(RESET)"
	kubectl exec -n $(K8S_DEFAULT_NS) -it deployment/laravel-app -c queue -- $(K8S_DEFAULT_SHELL)

k8s-shell-first: ## Подключиться к shell первого доступного pod
	@echo "$(BLUE)Подключение к shell первого доступного pod в namespace $(K8S_DEFAULT_NS) с shell $(K8S_DEFAULT_SHELL)...$(RESET)"
	@pod=$$(kubectl get pods -n $(K8S_DEFAULT_NS) -l app.kubernetes.io/name=laravel-app -o jsonpath='{.items[0].metadata.name}'); \
	echo "$(GREEN)Подключение к pod: $$pod$(RESET)"; \
	kubectl exec -n $(K8S_DEFAULT_NS) -it $$pod -c php-fpm -- $(K8S_DEFAULT_SHELL)

k8s-port-forward: ## Проброс портов для локального доступа
	@echo "$(BLUE)Проброс портов в namespace $(K8S_DEFAULT_NS)...$(RESET)"
	kubectl port-forward -n $(K8S_DEFAULT_NS) svc/laravel-app 8080:80

k8s-status: ## Показать статус всех ресурсов приложения
	@echo "$(BLUE)Статус ресурсов приложения в namespace $(K8S_DEFAULT_NS)...$(RESET)"
	echo "$(GREEN)Pods:$(RESET)"; \
	kubectl get pods -n $(K8S_DEFAULT_NS) -l app.kubernetes.io/name=laravel-app; \
	echo "$(GREEN)Services:$(RESET)"; \
	kubectl get svc -n $(K8S_DEFAULT_NS) -l app.kubernetes.io/name=laravel-app; \
	echo "$(GREEN)Deployments:$(RESET)"; \
	kubectl get deployments -n $(K8S_DEFAULT_NS) -l app.kubernetes.io/name=laravel-app; \
	echo "$(GREEN)ConfigMaps:$(RESET)"; \
	kubectl get configmaps -n $(K8S_DEFAULT_NS) -l app.kubernetes.io/name=laravel-app; \
	echo "$(GREEN)Secrets:$(RESET)"; \
	kubectl get secrets -n $(K8S_DEFAULT_NS) -l app.kubernetes.io/name=laravel-app

k8s-describe: ## Подробная информация о ресурсах приложения
	@echo "$(BLUE)Подробная информация о ресурсах...$(RESET)"
	@read -p "Enter namespace (default: laravel-app-dev): " namespace; \
	namespace=$${namespace:-laravel-app-dev}; \
	echo "$(GREEN)Deployment:$(RESET)"; \
	kubectl describe deployment laravel-app -n $$namespace; \
	echo "$(GREEN)Service:$(RESET)"; \
	kubectl describe svc laravel-app -n $$namespace

k8s-scale: ## Масштабировать приложение
	@echo "$(BLUE)Масштабирование приложения...$(RESET)"
	@read -p "Enter namespace (default: laravel-app-dev): " namespace; \
	namespace=$${namespace:-laravel-app-dev}; \
	read -p "Enter number of replicas: " replicas; \
	kubectl scale deployment laravel-app -n $$namespace --replicas=$$replicas; \
	echo "$(GREEN)Приложение масштабировано до $$replicas реплик$(RESET)"

k8s-scale-helm: ## Масштабировать приложение через Helm
	@echo "$(BLUE)Масштабирование через Helm...$(RESET)"
	@read -p "Enter namespace (default: laravel-app-dev): " namespace; \
	namespace=$${namespace:-laravel-app-dev}; \
	read -p "Enter number of replicas: " replicas; \
	helm upgrade laravel-app helm/laravel-app -n $$namespace --set replicaCount=$$replicas --values helm/laravel-app/values-dev.yaml; \
	echo "$(GREEN)Приложение масштабировано до $$replicas реплик через Helm$(RESET)"

k8s-artisan: ## Выполнить artisan команду в Kubernetes
	@echo "$(BLUE)Выполнение artisan команды в Kubernetes...$(RESET)"
	@read -p "Enter namespace (default: laravel-app-dev): " namespace; \
	namespace=$${namespace:-laravel-app-dev}; \
	read -p "Enter artisan command (e.g., route:list): " cmd; \
	pod=$$(kubectl get pods -n $$namespace -l app.kubernetes.io/name=laravel-app -o jsonpath='{.items[0].metadata.name}'); \
	echo "$(GREEN)Выполнение: php artisan $$cmd в pod $$pod$(RESET)"; \
	kubectl exec -n $$namespace $$pod -c php-fpm -- php artisan $$cmd

k8s-migrate: ## Запустить миграции в Kubernetes
	@echo "$(BLUE)Запуск миграций в Kubernetes...$(RESET)"
	@read -p "Enter namespace (default: laravel-app-dev): " namespace; \
	namespace=$${namespace:-laravel-app-dev}; \
	pod=$$(kubectl get pods -n $$namespace -l app.kubernetes.io/name=laravel-app -o jsonpath='{.items[0].metadata.name}'); \
	echo "$(GREEN)Запуск миграций в pod $$pod$(RESET)"; \
	kubectl exec -n $$namespace $$pod -c php-fpm -- php artisan migrate

k8s-migrate-fresh: ## Пересоздать базу данных и запустить миграции
	@echo "$(RED)Пересоздание базы данных в Kubernetes...$(RESET)"
	@read -p "Enter namespace (default: laravel-app-dev): " namespace; \
	namespace=$${namespace:-laravel-app-dev}; \
	read -p "Вы уверены что хотите пересоздать базу данных? (yes/no): " confirm; \
	if [ "$$confirm" = "yes" ]; then \
		pod=$$(kubectl get pods -n $$namespace -l app.kubernetes.io/name=laravel-app -o jsonpath='{.items[0].metadata.name}'); \
		echo "$(GREEN)Пересоздание БД в pod $$pod$(RESET)"; \
		kubectl exec -n $$namespace $$pod -c php-fpm -- php artisan migrate:fresh --seed; \
	else \
		echo "$(YELLOW)Операция отменена$(RESET)"; \
	fi

k8s-seed: ## Запустить seeders в Kubernetes
	@echo "$(BLUE)Запуск seeders в Kubernetes...$(RESET)"
	@read -p "Enter namespace (default: laravel-app-dev): " namespace; \
	namespace=$${namespace:-laravel-app-dev}; \
	pod=$$(kubectl get pods -n $$namespace -l app.kubernetes.io/name=laravel-app -o jsonpath='{.items[0].metadata.name}'); \
	echo "$(GREEN)Запуск seeders в pod $$pod$(RESET)"; \
	kubectl exec -n $$namespace $$pod -c php-fpm -- php artisan db:seed

k8s-cache-clear: ## Очистить кеш в Kubernetes
	@echo "$(BLUE)Очистка кеша в Kubernetes...$(RESET)"
	@read -p "Enter namespace (default: laravel-app-dev): " namespace; \
	namespace=$${namespace:-laravel-app-dev}; \
	pod=$$(kubectl get pods -n $$namespace -l app.kubernetes.io/name=laravel-app -o jsonpath='{.items[0].metadata.name}'); \
	echo "$(GREEN)Очистка кеша в pod $$pod$(RESET)"; \
	kubectl exec -n $$namespace $$pod -c php-fpm -- php artisan cache:clear; \
	kubectl exec -n $$namespace $$pod -c php-fpm -- php artisan config:clear; \
	kubectl exec -n $$namespace $$pod -c php-fpm -- php artisan route:clear; \
	kubectl exec -n $$namespace $$pod -c php-fpm -- php artisan view:clear

k8s-config-cache: ## Создать кеш конфигурации в Kubernetes
	@echo "$(BLUE)Создание кеша конфигурации в Kubernetes...$(RESET)"
	@read -p "Enter namespace (default: laravel-app-dev): " namespace; \
	namespace=$${namespace:-laravel-app-dev}; \
	pod=$$(kubectl get pods -n $$namespace -l app.kubernetes.io/name=laravel-app -o jsonpath='{.items[0].metadata.name}'); \
	echo "$(GREEN)Создание кеша конфигурации в pod $$pod$(RESET)"; \
	kubectl exec -n $$namespace $$pod -c php-fpm -- php artisan config:cache; \
	kubectl exec -n $$namespace $$pod -c php-fpm -- php artisan route:cache; \
	kubectl exec -n $$namespace $$pod -c php-fpm -- php artisan view:cache

k8s-queue-work: ## Запустить queue worker вручную
	@echo "$(BLUE)Запуск queue worker вручную...$(RESET)"
	@read -p "Enter namespace (default: laravel-app-dev): " namespace; \
	namespace=$${namespace:-laravel-app-dev}; \
	pod=$$(kubectl get pods -n $$namespace -l app.kubernetes.io/name=laravel-app -o jsonpath='{.items[0].metadata.name}'); \
	echo "$(GREEN)Запуск queue worker в pod $$pod$(RESET)"; \
	kubectl exec -n $$namespace $$pod -c queue-worker -- php artisan queue:work

k8s-queue-failed: ## Показать неудачные задачи
	@echo "$(BLUE)Неудачные задачи в очереди...$(RESET)"
	@read -p "Enter namespace (default: laravel-app-dev): " namespace; \
	namespace=$${namespace:-laravel-app-dev}; \
	pod=$$(kubectl get pods -n $$namespace -l app.kubernetes.io/name=laravel-app -o jsonpath='{.items[0].metadata.name}'); \
	echo "$(GREEN)Неудачные задачи в pod $$pod$(RESET)"; \
	kubectl exec -n $$namespace $$pod -c php-fpm -- php artisan queue:failed

k8s-queue-retry: ## Повторить неудачные задачи
	@echo "$(BLUE)Повтор неудачных задач...$(RESET)"
	@read -p "Enter namespace (default: laravel-app-dev): " namespace; \
	namespace=$${namespace:-laravel-app-dev}; \
	read -p "Enter job ID (or 'all' for all failed jobs): " job_id; \
	pod=$$(kubectl get pods -n $$namespace -l app.kubernetes.io/name=laravel-app -o jsonpath='{.items[0].metadata.name}'); \
	echo "$(GREEN)Повтор задач в pod $$pod$(RESET)"; \
	if [ "$$job_id" = "all" ]; then \
		kubectl exec -n $$namespace $$pod -c php-fpm -- php artisan queue:retry all; \
	else \
		kubectl exec -n $$namespace $$pod -c php-fpm -- php artisan queue:retry $$job_id; \
	fi

k8s-queue-flush: ## Очистить все неудачные задачи
	@echo "$(RED)Очистка всех неудачных задач...$(RESET)"
	@read -p "Enter namespace (default: laravel-app-dev): " namespace; \
	namespace=$${namespace:-laravel-app-dev}; \
	read -p "Вы уверены что хотите очистить все неудачные задачи? (yes/no): " confirm; \
	if [ "$$confirm" = "yes" ]; then \
		pod=$$(kubectl get pods -n $$namespace -l app.kubernetes.io/name=laravel-app -o jsonpath='{.items[0].metadata.name}'); \
		echo "$(GREEN)Очистка неудачных задач в pod $$pod$(RESET)"; \
		kubectl exec -n $$namespace $$pod -c php-fpm -- php artisan queue:flush; \
	else \
		echo "$(YELLOW)Операция отменена$(RESET)"; \
	fi

k8s-restart: ## Перезапустить deployment
	@echo "$(BLUE)Перезапуск deployment...$(RESET)"
	@read -p "Enter namespace (default: laravel-app-dev): " namespace; \
	namespace=$${namespace:-laravel-app-dev}; \
	kubectl rollout restart deployment/laravel-app -n $$namespace; \
	echo "$(GREEN)Deployment перезапущен$(RESET)"

k8s-rollback: ## Откатить deployment к предыдущей версии
	@echo "$(BLUE)Откат deployment...$(RESET)"
	@read -p "Enter namespace (default: laravel-app-dev): " namespace; \
	namespace=$${namespace:-laravel-app-dev}; \
	kubectl rollout undo deployment/laravel-app -n $$namespace; \
	echo "$(GREEN)Deployment откачен$(RESET)"

k8s-rollback-to: ## Откатить deployment к конкретной версии
	@echo "$(BLUE)Откат deployment к конкретной версии...$(RESET)"
	@read -p "Enter namespace (default: laravel-app-dev): " namespace; \
	namespace=$${namespace:-laravel-app-dev}; \
	read -p "Enter revision number: " revision; \
	kubectl rollout undo deployment/laravel-app -n $$namespace --to-revision=$$revision; \
	echo "$(GREEN)Deployment откачен к версии $$revision$(RESET)"

k8s-rollout-status: ## Показать статус rollout
	@echo "$(BLUE)Статус rollout...$(RESET)"
	@read -p "Enter namespace (default: laravel-app-dev): " namespace; \
	namespace=$${namespace:-laravel-app-dev}; \
	kubectl rollout status deployment/laravel-app -n $$namespace

k8s-rollout-history: ## Показать историю rollout
	@echo "$(BLUE)История rollout...$(RESET)"
	@read -p "Enter namespace (default: laravel-app-dev): " namespace; \
	namespace=$${namespace:-laravel-app-dev}; \
	kubectl rollout history deployment/laravel-app -n $$namespace

k8s-top: ## Показать использование ресурсов
	@echo "$(BLUE)Использование ресурсов...$(RESET)"
	@read -p "Enter namespace (default: laravel-app-dev): " namespace; \
	namespace=$${namespace:-laravel-app-dev}; \
	kubectl top pods -n $$namespace -l app.kubernetes.io/name=laravel-app

k8s-events: ## Показать события в namespace
	@echo "$(BLUE)События в namespace...$(RESET)"
	@read -p "Enter namespace (default: laravel-app-dev): " namespace; \
	namespace=$${namespace:-laravel-app-dev}; \
	kubectl get events -n $$namespace --sort-by='.lastTimestamp'

k8s-ingress-status: ## Показать статус Ingress
	@echo "$(BLUE)Статус Ingress...$(RESET)"
	@read -p "Enter namespace (default: laravel-app-dev): " namespace; \
	namespace=$${namespace:-laravel-app-dev}; \
	kubectl get ingress -n $$namespace; \
	echo "$(GREEN)Подробная информация:$(RESET)"; \
	kubectl describe ingress -n $$namespace

k8s-pvc-status: ## Показать статус PersistentVolumeClaims
	@echo "$(BLUE)Статус PersistentVolumeClaims...$(RESET)"
	@read -p "Enter namespace (default: laravel-app-dev): " namespace; \
	namespace=$${namespace:-laravel-app-dev}; \
	kubectl get pvc -n $$namespace; \
	echo "$(GREEN)Подробная информация:$(RESET)"; \
	kubectl describe pvc -n $$namespace

k8s-secret-view: ## Показать содержимое Secret (base64 decoded)
	@echo "$(BLUE)Содержимое Secret...$(RESET)"
	@read -p "Enter namespace (default: laravel-app-dev): " namespace; \
	namespace=$${namespace:-laravel-app-dev}; \
	read -p "Enter secret name (default: laravel-app-secret): " secret; \
	secret=$${secret:-laravel-app-secret}; \
	echo "$(GREEN)Содержимое secret $$secret:$(RESET)"; \
	kubectl get secret $$secret -n $$namespace -o jsonpath='{.data}' | jq -r 'to_entries[] | "\(.key): \(.value | @base64d)"'

k8s-configmap-view: ## Показать содержимое ConfigMap
	@echo "$(BLUE)Содержимое ConfigMap...$(RESET)"
	@read -p "Enter namespace (default: laravel-app-dev): " namespace; \
	namespace=$${namespace:-laravel-app-dev}; \
	read -p "Enter configmap name (default: laravel-app-config): " configmap; \
	configmap=$${configmap:-laravel-app-config}; \
	echo "$(GREEN)Содержимое configmap $$configmap:$(RESET)"; \
	kubectl get configmap $$configmap -n $$namespace -o yaml

k8s-exec-all: ## Выполнить команду во всех pods
	@echo "$(BLUE)Выполнение команды во всех pods...$(RESET)"
	@read -p "Enter namespace (default: laravel-app-dev): " namespace; \
	namespace=$${namespace:-laravel-app-dev}; \
	read -p "Enter command to execute: " cmd; \
	echo "$(GREEN)Выполнение команды '$$cmd' во всех pods...$(RESET)"; \
	for pod in $$(kubectl get pods -n $$namespace -l app.kubernetes.io/name=laravel-app -o jsonpath='{.items[*].metadata.name}'); do \
		echo "$(YELLOW)Pod: $$pod$(RESET)"; \
		kubectl exec -n $$namespace $$pod -c php-fpm -- $$cmd; \
		echo ""; \
	done

k8s-copy-file: ## Скопировать файл в pod
	@echo "$(BLUE)Копирование файла в pod...$(RESET)"
	@read -p "Enter namespace (default: laravel-app-dev): " namespace; \
	namespace=$${namespace:-laravel-app-dev}; \
	read -p "Enter local file path: " local_file; \
	read -p "Enter remote file path: " remote_file; \
	pod=$$(kubectl get pods -n $$namespace -l app.kubernetes.io/name=laravel-app -o jsonpath='{.items[0].metadata.name}'); \
	echo "$(GREEN)Копирование $$local_file в $$pod:$$remote_file$(RESET)"; \
	kubectl cp $$local_file $$namespace/$$pod:$$remote_file -c php-fpm

k8s-copy-from: ## Скопировать файл из pod
	@echo "$(BLUE)Копирование файла из pod...$(RESET)"
	@read -p "Enter namespace (default: laravel-app-dev): " namespace; \
	namespace=$${namespace:-laravel-app-dev}; \
	read -p "Enter remote file path: " remote_file; \
	read -p "Enter local file path: " local_file; \
	pod=$$(kubectl get pods -n $$namespace -l app.kubernetes.io/name=laravel-app -o jsonpath='{.items[0].metadata.name}'); \
	echo "$(GREEN)Копирование $$pod:$$remote_file в $$local_file$(RESET)"; \
	kubectl cp $$namespace/$$pod:$$remote_file $$local_file -c php-fpm

k8s-dashboard-install: ## Установить Kubernetes Dashboard
	@echo "$(BLUE)Установка Kubernetes Dashboard...$(RESET)"
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
	@echo "$(GREEN)Dashboard установлен в namespace: kubernetes-dashboard$(RESET)"
	@echo "$(YELLOW)Для доступа используйте: make k8s-dashboard-access$(RESET)"

k8s-dashboard-token: ## Создать токен для доступа к Dashboard
	@echo "$(BLUE)Создание токена для Dashboard...$(RESET)"
	@if ! kubectl get serviceaccount admin-user -n kubernetes-dashboard >/dev/null 2>&1; then \
		echo "$(YELLOW)Создание ServiceAccount...$(RESET)"; \
		kubectl create serviceaccount admin-user -n kubernetes-dashboard; \
	fi
	@if ! kubectl get clusterrolebinding admin-user >/dev/null 2>&1; then \
		echo "$(YELLOW)Создание ClusterRoleBinding...$(RESET)"; \
		kubectl create clusterrolebinding admin-user --clusterrole=cluster-admin --serviceaccount=kubernetes-dashboard:admin-user; \
	fi
	@echo "$(GREEN)Токен для входа:$(RESET)"
	@kubectl -n kubernetes-dashboard create token admin-user

k8s-dashboard-access: ## Запустить доступ к Dashboard
	@echo "$(BLUE)Запуск доступа к Kubernetes Dashboard...$(RESET)"
	@echo "$(GREEN)Dashboard будет доступен по адресу:$(RESET)"
	@echo "$(GREEN)http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/$(RESET)"
	@echo "$(YELLOW)Получите токен командой: make k8s-dashboard-token$(RESET)"
	@echo "$(YELLOW)Нажмите Ctrl+C для остановки$(RESET)"
	kubectl proxy

k8s-dashboard-remove: ## Удалить Kubernetes Dashboard
	@echo "$(RED)Удаление Kubernetes Dashboard...$(RESET)"
	@read -p "Вы уверены что хотите удалить Dashboard? (yes/no): " confirm; \
	if [ "$$confirm" = "yes" ]; then \
		kubectl delete -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml; \
		kubectl delete clusterrolebinding admin-user 2>/dev/null || true; \
		echo "$(GREEN)Dashboard удален$(RESET)"; \
	else \
		echo "$(YELLOW)Операция отменена$(RESET)"; \
	fi

k8s-fix-certs: ## Исправить проблемы с сертификатами Microk8s
	@echo "$(BLUE)Исправление проблем с сертификатами...$(RESET)"
	./k8s/fix-microk8s-certs.sh

k8s-fix-image-pull: ## Исправить проблему ImagePullBackOff
	@echo "$(BLUE)Исправление проблемы ImagePullBackOff...$(RESET)"
	./k8s/fix-image-pull.sh

k8s-tinker: ## Открыть tinker в Kubernetes (без истории)
	@echo "$(BLUE)Открытие tinker в Kubernetes...$(RESET)"
	@read -p "Enter namespace (default: laravel-app-dev): " namespace; \
	namespace=$${namespace:-laravel-app-dev}; \
	pod=$$(kubectl get pods -n $$namespace -l app.kubernetes.io/name=laravel-app -o jsonpath='{.items[0].metadata.name}'); \
	echo "$(GREEN)Открытие tinker в pod $$pod$(RESET)"; \
	kubectl exec -n $$namespace -it $$pod -c php-fpm -- env PSYSH_HISTORY="" php artisan tinker

k8s-tn: k8s-tinker

# =============================================================================
# Docker для Kubernetes
# =============================================================================

docker-build-k8s: ## Собрать Docker образ для Kubernetes (production)
	@echo "$(BLUE)Сборка Docker образа для Kubernetes...$(RESET)"
	./docker/k8s/build-and-push.sh production

docker-build-k8s-dev: ## Собрать Docker образ для Kubernetes (development)
	@echo "$(BLUE)Сборка Docker образа для разработки...$(RESET)"
	./docker/k8s/build-and-push.sh development

docker-push-k8s: ## Собрать и загрузить образ в Microk8s registry
	@echo "$(BLUE)Сборка и загрузка в Microk8s registry...$(RESET)"
	./docker/k8s/build-and-push.sh

# =============================================================================
# Линтинг и исправление кода
# =============================================================================

lint: ## Запустить все линтеры в Docker
	@echo "$(GREEN)Запуск всех линтеров в Docker...$(RESET)"
	@echo "$(BLUE)📦 JavaScript/TypeScript lint...$(RESET)"
	docker compose -f docker-compose.dev.yml run -T --rm node-dev npm run lint:js
	@echo "$(BLUE)💄 CSS/SCSS lint...$(RESET)"
	docker compose -f docker-compose.dev.yml run -T --rm node-dev npm run lint:css
	@echo "$(BLUE)🐘 PHP lint...$(RESET)"
	docker compose -f docker-compose.dev.yml run -T --rm php-dev composer lint
	@echo "$(GREEN)✅ Все линтеры прошли успешно!$(RESET)"

lint-js: ## Запустить только JavaScript/TypeScript линтер в Docker
	@echo "$(GREEN)Запуск JavaScript/TypeScript линтера в Docker...$(RESET)"
	docker compose -f docker-compose.dev.yml run -T --rm node-dev npm run lint:js

lint-css: ## Запустить только CSS/SCSS линтер в Docker
	@echo "$(GREEN)Запуск CSS/SCSS линтера в Docker...$(RESET)"
	docker compose -f docker-compose.dev.yml run -T --rm node-dev npm run lint:css

lint-php: ## Запустить только PHP линтер в Docker
	@echo "$(GREEN)Запуск PHP линтера в Docker...$(RESET)"
	docker compose -f docker-compose.dev.yml run -T --rm php-dev composer lint

lint-fix: ## Исправить все ошибки линтеров в Docker
	@echo "$(GREEN)Исправление ошибок линтеров в Docker...$(RESET)"
	@echo "$(BLUE)📦 Исправление JavaScript/TypeScript...$(RESET)"
	docker compose -f docker-compose.dev.yml run -T --rm node-dev npm run lint:js
	@echo "$(BLUE)💄 Исправление CSS/SCSS...$(RESET)"
	docker compose -f docker-compose.dev.yml run -T --rm node-dev npm run lint:css
	@echo "$(BLUE)🐘 Исправление PHP...$(RESET)"
	docker compose -f docker-compose.dev.yml run -T --rm php-dev composer lint-fix
	@echo "$(GREEN)✅ Все ошибки исправлены!$(RESET)"

lint-fix-js: ## Исправить только JavaScript/TypeScript ошибки в Docker
	@echo "$(GREEN)Исправление JavaScript/TypeScript ошибок в Docker...$(RESET)"
	docker compose -f docker-compose.dev.yml run -T --rm node-dev npm run lint:js

lint-fix-css: ## Исправить только CSS/SCSS ошибки в Docker
	@echo "$(GREEN)Исправление CSS/SCSS ошибок в Docker...$(RESET)"
	docker compose -f docker-compose.dev.yml run -T --rm node-dev npm run lint:css

lint-fix-php: ## Исправить только PHP ошибки в Docker
	@echo "$(GREEN)Исправление PHP ошибок в Docker...$(RESET)"
	docker compose -f docker-compose.dev.yml run -T --rm php-dev composer lint-fix

prettier: ## Запустить Prettier для форматирования кода в Docker
	@echo "$(GREEN)Запуск Prettier в Docker...$(RESET)"
	docker compose -f docker-compose.dev.yml run -T --rm node-dev npm run prettier:check

prettier-fix: ## Исправить форматирование кода с Prettier в Docker
	@echo "$(GREEN)Исправление форматирования с Prettier в Docker...$(RESET)"
	docker compose -f docker-compose.dev.yml run -T --rm node-dev npx prettier --write .

stylelint: ## Запустить Stylelint для CSS/SCSS в Docker
	@echo "$(GREEN)Запуск Stylelint в Docker...$(RESET)"
	docker compose -f docker-compose.dev.yml run -T --rm node-dev npm run stylelint

stylelint-fix: ## Исправить CSS/SCSS с Stylelint в Docker
	@echo "$(GREEN)Исправление CSS/SCSS с Stylelint в Docker...$(RESET)"
	docker compose -f docker-compose.dev.yml run -T --rm node-dev npx stylelint --fix resources/css/

eslint: ## Запустить ESLint для JavaScript/TypeScript в Docker
	@echo "$(GREEN)Запуск ESLint в Docker...$(RESET)"
	docker compose -f docker-compose.dev.yml run -T --rm node-dev npx eslint resources/js --ext .js,.vue

eslint-fix: ## Исправить JavaScript/TypeScript с ESLint в Docker
	@echo "$(GREEN)Исправление JavaScript/TypeScript с ESLint в Docker...$(RESET)"
	docker compose -f docker-compose.dev.yml run -T --rm node-dev npx eslint resources/js --ext .js,.vue --fix

# =============================================================================
# Алиасы для краткости
# =============================================================================
t: test
tu: test-unit
tf: test-feature
tc: test-coverage
tp: test-parallel
tw: test-watch
up: sail-up
down: sail-down
build: sail-build
shell: sail-shell
hd: helm-deploy-dev
hs: helm-deploy-staging
hp: helm-deploy-prod

# Kubernetes алиасы
k8s-l: k8s-logs
k8s-lp: k8s-logs-php
k8s-ln: k8s-logs-nginx
k8s-lq: k8s-logs-queue
k8s-s: k8s-shell
k8s-sp: k8s-shell-php
k8s-sn: k8s-shell-nginx
k8s-sq: k8s-shell-queue
k8s-sf: k8s-shell-first
k8s-pf: k8s-port-forward
k8s-st: k8s-status
k8s-d: k8s-describe
k8s-sc: k8s-scale
k8s-sch: k8s-scale-helm
k8s-a: k8s-artisan
k8s-m: k8s-migrate
k8s-mf: k8s-migrate-fresh
k8s-se: k8s-seed
k8s-cc: k8s-cache-clear
k8s-cac: k8s-config-cache
k8s-qw: k8s-queue-work
k8s-qf: k8s-queue-failed
k8s-qr: k8s-queue-retry
k8s-qfl: k8s-queue-flush
k8s-r: k8s-restart
k8s-rb: k8s-rollback
k8s-rbt: k8s-rollback-to
k8s-rs: k8s-rollout-status
k8s-rh: k8s-rollout-history
k8s-t: k8s-top
k8s-e: k8s-events
k8s-i: k8s-ingress-status
k8s-pvc: k8s-pvc-status
k8s-sv: k8s-secret-view
k8s-cmv: k8s-configmap-view
k8s-ea: k8s-exec-all
k8s-cp: k8s-copy-file
k8s-cpf: k8s-copy-from 