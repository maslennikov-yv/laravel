# 🚀 Kubernetes Utilities

Этот каталог содержит утилиты для работы с Kubernetes кластером.

## 📊 Kubernetes Dashboard

### Быстрый старт

```bash
# 1. Установить Dashboard
make k8s-dashboard-install

# 2. Создать токен доступа
make k8s-dashboard-token

# 3. Запустить доступ к Dashboard
make k8s-dashboard-access
```

### Использование скрипта

```bash
# Полная установка (рекомендуется)
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

### Возможности Dashboard

- 📊 **Мониторинг ресурсов**: CPU, память, диск
- 🚀 **Управление приложениями**: deployments, services, pods
- 📝 **Просмотр логов**: в реальном времени
- ⚙️ **Редактирование конфигураций**: YAML манифестов
- 📈 **Метрики**: графики использования ресурсов
- 🔍 **Отладка**: events, описания ресурсов

### Скриншоты функций

#### Главная страница
- Обзор кластера
- Статус узлов
- Использование ресурсов

#### Workloads
- Deployments
- ReplicaSets
- Pods
- Jobs
- CronJobs

#### Services and Discovery
- Services
- Ingresses
- Endpoints

#### Config and Storage
- ConfigMaps
- Secrets
- Persistent Volumes

### Безопасность

⚠️ **Важно**: Dashboard создает пользователя с правами `cluster-admin`

**Для продакшена рекомендуется**:
- Создать пользователей с ограниченными правами
- Использовать RBAC для контроля доступа
- Настроить TLS сертификаты
- Ограничить сетевой доступ

#### Создание пользователя с ограниченными правами

```yaml
# dashboard-user.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: dashboard-user
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: dashboard-user-role
rules:
- apiGroups: [""]
  resources: ["pods", "services", "configmaps"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["apps"]
  resources: ["deployments", "replicasets"]
  verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: dashboard-user-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: dashboard-user-role
subjects:
- kind: ServiceAccount
  name: dashboard-user
  namespace: kubernetes-dashboard
```

```bash
# Применить конфигурацию
kubectl apply -f dashboard-user.yaml

# Создать токен
kubectl -n kubernetes-dashboard create token dashboard-user
```

### Troubleshooting

#### Dashboard не запускается
```bash
# Проверить статус pods
kubectl get pods -n kubernetes-dashboard

# Проверить события
kubectl get events -n kubernetes-dashboard

# Логи Dashboard
kubectl logs -n kubernetes-dashboard -l k8s-app=kubernetes-dashboard
```

#### Проблемы с доступом
```bash
# Проверить прокси
kubectl proxy --port=8001

# Проверить токен
kubectl -n kubernetes-dashboard get secret admin-user-token -o jsonpath='{.data.token}' | base64 -d
```

#### Токен истек
```bash
# Создать новый токен
make k8s-dashboard-token

# Или через скрипт
./k8s/setup-dashboard.sh token
```

### Альтернативы

Если Dashboard не подходит, рассмотрите альтернативы:

- **Lens**: Десктопное приложение для Kubernetes
- **K9s**: Терминальный UI для Kubernetes
- **Octant**: Веб-интерфейс от VMware
- **Grafana + Prometheus**: Для мониторинга

### Полезные ссылки

- [Kubernetes Dashboard GitHub](https://github.com/kubernetes/dashboard)
- [Официальная документация](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/)
- [Руководство по безопасности](https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/README.md)
- [Troubleshooting Certificates](troubleshooting-certificates.md) 
