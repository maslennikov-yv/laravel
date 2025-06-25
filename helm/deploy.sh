#!/bin/bash

# Laravel Helm Chart Deployment Script
# Usage: ./deploy.sh [environment] [release-name] [namespace]

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
ENVIRONMENT=${1:-dev}
RELEASE_NAME=${2:-laravel-app}
NAMESPACE=${3:-laravel-app-$ENVIRONMENT}
CHART_DIR="helm/laravel-app"

echo -e "${BLUE}🚀 Laravel Helm Chart Deployment${NC}"
echo -e "${BLUE}=================================${NC}"
echo ""
echo -e "Environment: ${YELLOW}$ENVIRONMENT${NC}"
echo -e "Release:     ${YELLOW}$RELEASE_NAME${NC}"
echo -e "Namespace:   ${YELLOW}$NAMESPACE${NC}"
echo ""

# Validate environment
case $ENVIRONMENT in
    dev|development)
        VALUES_FILE="values-dev.yaml"
        ;;
    staging|stage)
        VALUES_FILE="values-staging.yaml"
        ;;
    prod|production)
        VALUES_FILE="values-prod.yaml"
        ;;
    *)
        echo -e "${RED}❌ Invalid environment: $ENVIRONMENT${NC}"
        echo -e "${YELLOW}Valid environments: dev, staging, prod${NC}"
        exit 1
        ;;
esac

# Check if Helm is installed
if ! command -v helm &> /dev/null; then
    echo -e "${RED}❌ Helm is not installed${NC}"
    exit 1
fi

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}❌ kubectl is not installed${NC}"
    exit 1
fi

# Check if chart directory exists
if [ ! -d "$CHART_DIR" ]; then
    echo -e "${RED}❌ Chart directory not found: $CHART_DIR${NC}"
    exit 1
fi

# Check if values file exists
if [ ! -f "$CHART_DIR/$VALUES_FILE" ]; then
    echo -e "${RED}❌ Values file not found: $CHART_DIR/$VALUES_FILE${NC}"
    exit 1
fi

echo -e "${YELLOW}📋 Pre-deployment checks...${NC}"

# Add Bitnami repo if not exists
echo -e "${YELLOW}🔍 Checking Helm repositories...${NC}"
if ! helm repo list | grep -q bitnami; then
    echo -e "${YELLOW}📦 Adding Bitnami repository...${NC}"
    helm repo add bitnami https://charts.bitnami.com/bitnami
fi

# Update repositories
echo -e "${YELLOW}🔄 Updating Helm repositories...${NC}"
helm repo update

# Build dependencies
echo -e "${YELLOW}🔨 Building chart dependencies...${NC}"
helm dependency build $CHART_DIR

# Create namespace if it doesn't exist
echo -e "${YELLOW}🏗️  Creating namespace if not exists...${NC}"
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Validate the chart
echo -e "${YELLOW}✅ Validating Helm chart...${NC}"
helm lint $CHART_DIR --values $CHART_DIR/$VALUES_FILE

# Dry run
echo -e "${YELLOW}🧪 Performing dry run...${NC}"
helm upgrade --install $RELEASE_NAME $CHART_DIR \
    --namespace $NAMESPACE \
    --values $CHART_DIR/$VALUES_FILE \
    --dry-run --debug > /dev/null

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Dry run successful${NC}"
else
    echo -e "${RED}❌ Dry run failed${NC}"
    exit 1
fi

# Confirmation for production
if [[ "$ENVIRONMENT" == "prod" || "$ENVIRONMENT" == "production" ]]; then
    echo -e "${RED}⚠️  WARNING: You are about to deploy to PRODUCTION!${NC}"
    echo -e "${YELLOW}Please review the configuration:${NC}"
    echo ""
    
    # Show current values
    echo -e "${BLUE}Current configuration:${NC}"
    helm template $RELEASE_NAME $CHART_DIR \
        --values $CHART_DIR/$VALUES_FILE \
        --show-only templates/configmap.yaml | grep -A 20 "data:"
    
    echo ""
    read -p "Are you sure you want to continue? (yes/no): " -r
    if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        echo -e "${YELLOW}Deployment cancelled${NC}"
        exit 0
    fi
fi

# Deploy
echo -e "${GREEN}🚀 Deploying Laravel application...${NC}"
helm upgrade --install $RELEASE_NAME $CHART_DIR \
    --namespace $NAMESPACE \
    --values $CHART_DIR/$VALUES_FILE \
    --wait \
    --timeout 10m \
    --set-string "helm.sh/chart-version=$(date +%Y%m%d-%H%M%S)" \
    --set-string "helm.sh/chart-description=Deployed to $ENVIRONMENT environment via deploy.sh script"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Deployment successful!${NC}"
    echo ""
    
    # Show deployment status
    echo -e "${BLUE}📊 Deployment Status:${NC}"
    kubectl get pods -n $NAMESPACE -l app.kubernetes.io/instance=$RELEASE_NAME
    echo ""
    
    # Show services
    echo -e "${BLUE}🌐 Services:${NC}"
    kubectl get svc -n $NAMESPACE -l app.kubernetes.io/instance=$RELEASE_NAME
    echo ""
    
    # Show ingress if enabled
    if kubectl get ingress -n $NAMESPACE -l app.kubernetes.io/instance=$RELEASE_NAME &>/dev/null; then
        echo -e "${BLUE}🔗 Ingress:${NC}"
        kubectl get ingress -n $NAMESPACE -l app.kubernetes.io/instance=$RELEASE_NAME
        echo ""
    fi
    
    # Show notes
    echo -e "${BLUE}📝 Post-deployment notes:${NC}"
    helm get notes $RELEASE_NAME -n $NAMESPACE
    
else
    echo -e "${RED}❌ Deployment failed${NC}"
    echo ""
    echo -e "${YELLOW}📋 Troubleshooting steps:${NC}"
    echo "1. Check pod status: kubectl get pods -n $NAMESPACE"
    echo "2. Check pod logs: kubectl logs -n $NAMESPACE -l app.kubernetes.io/instance=$RELEASE_NAME"
    echo "3. Check events: kubectl get events -n $NAMESPACE --sort-by='.lastTimestamp'"
    echo "4. Check Helm status: helm status $RELEASE_NAME -n $NAMESPACE"
    exit 1
fi

echo ""
echo -e "${GREEN}🎉 Deployment completed successfully!${NC}"
echo -e "${YELLOW}Useful commands:${NC}"
echo "  View status: helm status $RELEASE_NAME -n $NAMESPACE"
echo "  View logs:   kubectl logs -n $NAMESPACE -l app.kubernetes.io/instance=$RELEASE_NAME -f"
echo "  Port forward: kubectl port-forward -n $NAMESPACE svc/$RELEASE_NAME 8080:80"
echo "  Uninstall:   helm uninstall $RELEASE_NAME -n $NAMESPACE" 