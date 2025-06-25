#!/bin/bash

# Kubernetes Dashboard Setup Script
# Автоматическая установка и настройка Kubernetes Dashboard

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

DASHBOARD_VERSION="v2.7.0"
NAMESPACE="kubernetes-dashboard"

echo -e "${BLUE}🚀 Kubernetes Dashboard Setup${NC}"
echo -e "${BLUE}==============================${NC}"
echo ""

# Function to check if kubectl is available
check_kubectl() {
    if ! command -v kubectl &> /dev/null; then
        echo -e "${RED}❌ kubectl не найден. Установите kubectl для продолжения.${NC}"
        exit 1
    fi
}

# Function to check if cluster is accessible
check_cluster() {
    if ! kubectl cluster-info &> /dev/null; then
        echo -e "${RED}❌ Не удается подключиться к Kubernetes кластеру.${NC}"
        echo -e "${YELLOW}Убедитесь что:${NC}"
        echo -e "  • Кластер запущен"
        echo -e "  • kubectl настроен правильно"
        echo -e "  • У вас есть доступ к кластеру"
        exit 1
    fi
}

# Function to install dashboard
install_dashboard() {
    echo -e "${YELLOW}📦 Установка Kubernetes Dashboard ${DASHBOARD_VERSION}...${NC}"
    
    if kubectl get namespace $NAMESPACE &> /dev/null; then
        echo -e "${YELLOW}⚠️  Namespace $NAMESPACE уже существует${NC}"
    fi
    
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/${DASHBOARD_VERSION}/aio/deploy/recommended.yaml
    
    echo -e "${GREEN}✅ Dashboard установлен${NC}"
}

# Function to create admin user
create_admin_user() {
    echo -e "${YELLOW}👤 Создание административного пользователя...${NC}"
    
    # Create ServiceAccount
    if ! kubectl get serviceaccount admin-user -n $NAMESPACE &> /dev/null; then
        kubectl create serviceaccount admin-user -n $NAMESPACE
        echo -e "${GREEN}✅ ServiceAccount создан${NC}"
    else
        echo -e "${YELLOW}⚠️  ServiceAccount admin-user уже существует${NC}"
    fi
    
    # Create ClusterRoleBinding
    if ! kubectl get clusterrolebinding admin-user &> /dev/null; then
        kubectl create clusterrolebinding admin-user \
            --clusterrole=cluster-admin \
            --serviceaccount=$NAMESPACE:admin-user
        echo -e "${GREEN}✅ ClusterRoleBinding создан${NC}"
    else
        echo -e "${YELLOW}⚠️  ClusterRoleBinding admin-user уже существует${NC}"
    fi
}

# Function to create token
create_token() {
    echo -e "${YELLOW}🔑 Создание токена доступа...${NC}"
    
    TOKEN=$(kubectl -n $NAMESPACE create token admin-user)
    
    echo -e "${GREEN}✅ Токен создан:${NC}"
    echo -e "${BLUE}$TOKEN${NC}"
    echo ""
    echo -e "${YELLOW}💾 Сохраните этот токен для входа в Dashboard${NC}"
    
    # Save token to file
    echo "$TOKEN" > dashboard-token.txt
    echo -e "${GREEN}✅ Токен сохранен в файл: dashboard-token.txt${NC}"
}

# Function to get dashboard status
get_status() {
    echo -e "${YELLOW}📊 Статус Dashboard...${NC}"
    
    echo -e "${BLUE}Pods в namespace $NAMESPACE:${NC}"
    kubectl get pods -n $NAMESPACE
    
    echo ""
    echo -e "${BLUE}Services в namespace $NAMESPACE:${NC}"
    kubectl get services -n $NAMESPACE
}

# Function to start proxy
start_proxy() {
    echo -e "${YELLOW}🌐 Запуск прокси для доступа к Dashboard...${NC}"
    echo ""
    echo -e "${GREEN}Dashboard будет доступен по адресу:${NC}"
    echo -e "${BLUE}http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/${NC}"
    echo ""
    echo -e "${YELLOW}Для входа используйте токен из файла dashboard-token.txt${NC}"
    echo -e "${YELLOW}Нажмите Ctrl+C для остановки прокси${NC}"
    echo ""
    
    kubectl proxy
}

# Function to remove dashboard
remove_dashboard() {
    echo -e "${RED}🗑️  Удаление Kubernetes Dashboard...${NC}"
    
    read -p "Вы уверены что хотите удалить Dashboard? (yes/no): " confirm
    if [ "$confirm" = "yes" ]; then
        kubectl delete -f https://raw.githubusercontent.com/kubernetes/dashboard/${DASHBOARD_VERSION}/aio/deploy/recommended.yaml
        kubectl delete clusterrolebinding admin-user 2>/dev/null || true
        rm -f dashboard-token.txt
        echo -e "${GREEN}✅ Dashboard удален${NC}"
    else
        echo -e "${YELLOW}Операция отменена${NC}"
    fi
}

# Function to show help
show_help() {
    echo -e "${BLUE}Использование:${NC}"
    echo -e "  $0 [команда]"
    echo ""
    echo -e "${BLUE}Команды:${NC}"
    echo -e "  install    Установить Dashboard"
    echo -e "  token      Создать новый токен"
    echo -e "  access     Запустить доступ к Dashboard"
    echo -e "  status     Показать статус Dashboard"
    echo -e "  remove     Удалить Dashboard"
    echo -e "  help       Показать эту справку"
    echo ""
    echo -e "${BLUE}Примеры:${NC}"
    echo -e "  $0 install   # Полная установка Dashboard"
    echo -e "  $0 token     # Создать новый токен"
    echo -e "  $0 access    # Запустить доступ"
}

# Main logic
case "${1:-install}" in
    "install")
        check_kubectl
        check_cluster
        install_dashboard
        echo -e "${YELLOW}⏳ Ожидание готовности Dashboard...${NC}"
        kubectl wait --for=condition=available --timeout=300s deployment/kubernetes-dashboard -n $NAMESPACE
        create_admin_user
        create_token
        get_status
        echo ""
        echo -e "${GREEN}🎉 Dashboard успешно установлен!${NC}"
        echo -e "${YELLOW}Для доступа запустите: $0 access${NC}"
        ;;
    "token")
        check_kubectl
        check_cluster
        create_token
        ;;
    "access")
        check_kubectl
        check_cluster
        if [ -f "dashboard-token.txt" ]; then
            echo -e "${GREEN}Токен из файла dashboard-token.txt:${NC}"
            echo -e "${BLUE}$(cat dashboard-token.txt)${NC}"
            echo ""
        else
            echo -e "${YELLOW}⚠️  Файл токена не найден. Создайте токен: $0 token${NC}"
            echo ""
        fi
        start_proxy
        ;;
    "status")
        check_kubectl
        check_cluster
        get_status
        ;;
    "remove")
        check_kubectl
        check_cluster
        remove_dashboard
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        echo -e "${RED}❌ Неизвестная команда: $1${NC}"
        echo ""
        show_help
        exit 1
        ;;
esac 