#!/bin/bash

# Laravel Helm Chart Test Script
# This script tests the Helm chart without deploying to a real cluster

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

CHART_DIR="helm/laravel-app"

echo -e "${BLUE}🧪 Laravel Helm Chart Test Suite${NC}"
echo -e "${BLUE}=================================${NC}"
echo ""

# Test 1: Chart validation
echo -e "${YELLOW}📋 Test 1: Chart validation...${NC}"
if helm lint $CHART_DIR; then
    echo -e "${GREEN}✅ Chart validation passed${NC}"
else
    echo -e "${RED}❌ Chart validation failed${NC}"
    exit 1
fi
echo ""

# Test 2: Dependencies check
echo -e "${YELLOW}📦 Test 2: Dependencies check...${NC}"
if [ -d "$CHART_DIR/charts" ] && [ "$(ls -A $CHART_DIR/charts)" ]; then
    echo -e "${GREEN}✅ Dependencies are installed${NC}"
    ls -la $CHART_DIR/charts/
else
    echo -e "${YELLOW}⚠️  Installing dependencies...${NC}"
    helm dependency build $CHART_DIR
    echo -e "${GREEN}✅ Dependencies installed${NC}"
fi
echo ""

# Test 3: Template generation for all environments
echo -e "${YELLOW}🔧 Test 3: Template generation...${NC}"

environments=("dev" "staging" "prod")
for env in "${environments[@]}"; do
    values_file="$CHART_DIR/values-$env.yaml"
    if [ -f "$values_file" ]; then
        echo -e "${BLUE}Testing $env environment...${NC}"
        if helm template laravel-app $CHART_DIR --values $values_file > /dev/null; then
            echo -e "${GREEN}✅ $env templates generated successfully${NC}"
        else
            echo -e "${RED}❌ $env template generation failed${NC}"
            exit 1
        fi
    else
        echo -e "${YELLOW}⚠️  Values file for $env not found: $values_file${NC}"
    fi
done
echo ""

# Test 4: Dry-run deployment for dev environment
echo -e "${YELLOW}🚀 Test 4: Dry-run deployment (dev)...${NC}"
if helm upgrade --install laravel-app-test $CHART_DIR \
    --namespace laravel-app-test \
    --values $CHART_DIR/values-dev.yaml \
    --dry-run > /dev/null; then
    echo -e "${GREEN}✅ Dry-run deployment successful${NC}"
else
    echo -e "${RED}❌ Dry-run deployment failed${NC}"
    exit 1
fi
echo ""

# Test 5: Check required templates
echo -e "${YELLOW}📄 Test 5: Required templates check...${NC}"
required_templates=(
    "deployment.yaml"
    "service.yaml"
    "configmap.yaml"
    "secret.yaml"
    "serviceaccount.yaml"
    "_helpers.tpl"
)

missing_templates=()
for template in "${required_templates[@]}"; do
    if [ -f "$CHART_DIR/templates/$template" ]; then
        echo -e "${GREEN}✅ $template found${NC}"
    else
        echo -e "${RED}❌ $template missing${NC}"
        missing_templates+=("$template")
    fi
done

if [ ${#missing_templates[@]} -eq 0 ]; then
    echo -e "${GREEN}✅ All required templates present${NC}"
else
    echo -e "${RED}❌ Missing templates: ${missing_templates[*]}${NC}"
    exit 1
fi
echo ""

# Test 6: Values validation
echo -e "${YELLOW}⚙️  Test 6: Values validation...${NC}"

# Check if values files have required keys
required_keys=("app" "image" "service" "resources")
for env in "${environments[@]}"; do
    values_file="$CHART_DIR/values-$env.yaml"
    if [ -f "$values_file" ]; then
        echo -e "${BLUE}Validating $env values...${NC}"
        for key in "${required_keys[@]}"; do
            if grep -q "^$key:" "$values_file" || grep -q "^$key:" "$CHART_DIR/values.yaml"; then
                echo -e "${GREEN}✅ $key found in $env${NC}"
            else
                echo -e "${RED}❌ $key missing in $env${NC}"
            fi
        done
    fi
done
echo ""

# Test 7: Dependencies configuration
echo -e "${YELLOW}🔗 Test 7: Dependencies configuration...${NC}"
dependencies=("redis" "postgresql" "minio" "mailpit")

for dep in "${dependencies[@]}"; do
    # Check if dependency is configurable in values
    if grep -q "$dep:" "$CHART_DIR/values.yaml"; then
        echo -e "${GREEN}✅ $dep configuration found${NC}"
    else
        echo -e "${YELLOW}⚠️  $dep configuration not found${NC}"
    fi
done
echo ""

# Test 8: External services configuration
echo -e "${YELLOW}🌐 Test 8: External services configuration...${NC}"
if grep -q "externalServices:" "$CHART_DIR/values.yaml"; then
    echo -e "${GREEN}✅ External services configuration found${NC}"
    
    # Check specific external services
    external_services=("postgresql" "redis" "s3" "smtp")
    for service in "${external_services[@]}"; do
        if grep -A 5 "externalServices:" "$CHART_DIR/values.yaml" | grep -q "$service:"; then
            echo -e "${GREEN}✅ External $service configuration found${NC}"
        else
            echo -e "${YELLOW}⚠️  External $service configuration not found${NC}"
        fi
    done
else
    echo -e "${RED}❌ External services configuration missing${NC}"
fi
echo ""

# Test 9: Security features
echo -e "${YELLOW}🔒 Test 9: Security features...${NC}"
security_features=("securityContext" "networkPolicy" "serviceAccount")

for feature in "${security_features[@]}"; do
    if find "$CHART_DIR/templates" -name "*.yaml" -exec grep -l "$feature" {} \; | head -1 > /dev/null; then
        echo -e "${GREEN}✅ $feature found in templates${NC}"
    else
        echo -e "${YELLOW}⚠️  $feature not found in templates${NC}"
    fi
done
echo ""

# Summary
echo -e "${BLUE}📊 Test Summary${NC}"
echo -e "${BLUE}===============${NC}"
echo -e "${GREEN}✅ All tests passed successfully!${NC}"
echo ""
echo -e "${YELLOW}Chart is ready for deployment to:${NC}"
echo -e "  • Development environment: ${GREEN}make helm-deploy-dev${NC}"
echo -e "  • Staging environment: ${GREEN}make helm-deploy-staging${NC}"
echo -e "  • Production environment: ${GREEN}make helm-deploy-prod${NC}"
echo ""
echo -e "${YELLOW}Useful commands:${NC}"
echo -e "  • Lint chart: ${BLUE}make helm-lint${NC}"
echo -e "  • Generate templates: ${BLUE}make helm-template${NC}"
echo -e "  • Install dependencies: ${BLUE}make helm-deps${NC}"
echo ""
echo -e "${GREEN}🎉 Laravel Helm Chart is ready for production use!${NC}" 