# ⚡ Быстрый старт Laravel + MicroK8s

## 🚀 Установка за 5 минут

### 1. Установка MicroK8s
```bash
# Linux
sudo snap install microk8s --classic
sudo usermod -a -G microk8s $USER
newgrp microk8s

# macOS
brew install ubuntu/microk8s/microk8s

# Windows
winget install Canonical.MicroK8s
```

### 2. Настройка кластера
```bash
microk8s start
microk8s enable dns registry ingress storage helm helm3
microk8s config > ~/.kube/config
```

### 3. Запуск Laravel
```bash
cd example-app1
make docker-push-k8s
kubectl create namespace laravel-app-dev
make hd
make k8s-pf
```

### 4. Открыть приложение
```
http://localhost:8080
```

## 🔧 Основные команды

```bash
# Статус приложения
make k8s-st

# Логи
make k8s-l

# Shell
make k8s-sf

# Tinker
make k8s-tn

# Масштабирование
make k8s-sc
```

## 📖 Подробное руководство
См. [MICROK8S_SETUP.md](MICROK8S_SETUP.md) 