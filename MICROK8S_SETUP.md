# 🚀 Краткое руководство по установке MicroK8s и запуску Laravel приложения

## 📋 Содержание
- [Установка MicroK8s](#установка-microk8s)
- [Настройка для Laravel](#настройка-для-laravel)
- [Запуск приложения](#запуск-приложения)
- [Полезные команды](#полезные-команды)

---

## 🐧 Установка MicroK8s

### Linux (Ubuntu/Debian)
```bash
# Установка через snap
sudo snap install microk8s --classic

# Добавление пользователя в группу microk8s
sudo usermod -a -G microk8s $USER
sudo chown -f -R $USER ~/.kube

# Перезагрузка или перелогин
newgrp microk8s

# Запуск MicroK8s
microk8s start

# Проверка статуса
microk8s status
```

### macOS
```bash
# Установка через Homebrew
brew install ubuntu/microk8s/microk8s

# Запуск MicroK8s
microk8s start

# Проверка статуса
microk8s status
```

### Windows
```bash
# Установка через winget
winget install Canonical.MicroK8s

# Или через Chocolatey
choco install microk8s

# Запуск MicroK8s
microk8s start

# Проверка статуса
microk8s status
```

---

## ⚙️ Настройка MicroK8s

### 1. Включение необходимых аддонов
```bash
# Основные аддоны для Laravel
microk8s enable dns          # DNS для разрешения имен
microk8s enable registry     # Локальный registry для образов
microk8s enable ingress      # Ingress контроллер
microk8s enable storage      # Хранилище
microk8s enable helm         # Helm для управления приложениями
microk8s enable helm3        # Helm 3

# Дополнительные аддоны (опционально)
microk8s enable dashboard    # Веб-интерфейс
microk8s enable metrics-server # Метрики
```

### 2. Настройка kubectl
```bash
# Настройка конфигурации kubectl
microk8s config > ~/.kube/config

# Проверка подключения
kubectl cluster-info
kubectl get nodes
```

### 3. Настройка Helm
```bash
# Проверка Helm
helm version

# Добавление репозиториев (если нужно)
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```

---

## 🏗️ Настройка для Laravel

### 1. Клонирование проекта
```bash
git clone <your-repo-url>
cd example-app1
```

### 2. Сборка Docker образов
```bash
# Сборка PHP-FPM образа
make docker-push-k8s

# Или вручную
./docker/k8s/build-and-push.sh
```

### 3. Создание namespace
```bash
kubectl create namespace laravel-app-dev
```

---

## 🚀 Запуск приложения

### 1. Развертывание через Helm
```bash
# Развертывание в development окружении
make hd

# Или вручную
helm upgrade laravel-app helm/laravel-app \
  -n laravel-app-dev \
  --values helm/laravel-app/values-dev.yaml \
  --install
```

### 2. Проверка статуса
```bash
# Статус всех ресурсов
make k8s-st

# Или вручную
kubectl get all -n laravel-app-dev
```

### 3. Доступ к приложению
```bash
# Проброс портов для локального доступа
make k8s-pf

# Или вручную
kubectl port-forward -n laravel-app-dev svc/laravel-app 8080:80
```

Приложение будет доступно по адресу: `http://localhost:8080`

---

## 🔧 Полезные команды

### Управление приложением
```bash
# Показать статус
make k8s-st

# Логи приложения
make k8s-l

# Логи PHP-FPM
make k8s-lp

# Логи Nginx
make k8s-ln

# Логи Queue Worker
make k8s-lq

# Подключиться к shell
make k8s-sf

# Выполнить artisan команду
make k8s-a

# Открыть tinker
make k8s-tn

# Масштабировать приложение
make k8s-sc

# Проброс портов
make k8s-pf
```

### Управление Helm
```bash
# Статус релиза
helm status laravel-app -n laravel-app-dev

# История релизов
helm history laravel-app -n laravel-app-dev

# Откат к предыдущей версии
helm rollback laravel-app -n laravel-app-dev

# Удаление релиза
helm uninstall laravel-app -n laravel-app-dev
```

### Управление MicroK8s
```bash
# Статус кластера
microk8s status

# Остановка кластера
microk8s stop

# Запуск кластера
microk8s start

# Сброс кластера
microk8s reset

# Обновление MicroK8s
microk8s refresh
```

---

## 🐛 Устранение неполадок

### Проблемы с образами
```bash
# Проверка registry
curl http://localhost:32000/v2/_catalog

# Пересборка образов
make docker-push-k8s
```

### Проблемы с правами доступа
```bash
# Исправление прав для Linux
sudo usermod -a -G microk8s $USER
sudo chown -f -R $USER ~/.kube
newgrp microk8s
```

### Проблемы с DNS
```bash
# Перезапуск DNS
microk8s disable dns
microk8s enable dns
```

### Проблемы с хранилищем
```bash
# Перезапуск storage
microk8s disable storage
microk8s enable storage
```

---

## 📚 Дополнительные ресурсы

- [Официальная документация MicroK8s](https://microk8s.io/docs)
- [Helm документация](https://helm.sh/docs)
- [Kubernetes документация](https://kubernetes.io/docs)

---

## 🎯 Быстрый старт (TL;DR)

```bash
# 1. Установка MicroK8s
sudo snap install microk8s --classic
sudo usermod -a -G microk8s $USER
newgrp microk8s

# 2. Настройка
microk8s start
microk8s enable dns registry ingress storage helm helm3
microk8s config > ~/.kube/config

# 3. Запуск Laravel
cd example-app1
make docker-push-k8s
kubectl create namespace laravel-app-dev
make hd
make k8s-pf

# 4. Открыть в браузере
# http://localhost:8080
```

**Готово! 🎉** 