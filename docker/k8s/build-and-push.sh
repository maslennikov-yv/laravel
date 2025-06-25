#!/bin/bash

# Build and Push Laravel Docker Image to Microk8s Registry
# Usage: ./docker/k8s/build-and-push.sh [production|development] [tag]

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REGISTRY="localhost:32000"
IMAGE_NAME="laravel-app"
DEFAULT_TAG="latest"
BUILD_STAGE="production"

# Parse arguments
if [ "$1" = "development" ] || [ "$1" = "dev" ]; then
    BUILD_STAGE="development"
    DEFAULT_TAG="dev"
elif [ "$1" = "production" ] || [ "$1" = "prod" ]; then
    BUILD_STAGE="production"
    DEFAULT_TAG="latest"
elif [ -n "$1" ]; then
    DEFAULT_TAG="$1"
fi

TAG="${2:-$DEFAULT_TAG}"
FULL_IMAGE_NAME="${REGISTRY}/${IMAGE_NAME}:${TAG}"

echo -e "${BLUE}🐳 Building Laravel Docker image for Kubernetes${NC}"
echo -e "${YELLOW}Build stage: ${BUILD_STAGE}${NC}"
echo -e "${YELLOW}Image: ${FULL_IMAGE_NAME}${NC}"

# Check if Microk8s registry is enabled
check_registry() {
    echo -e "${BLUE}📦 Checking Microk8s registry...${NC}"
    
    if ! microk8s status | grep -q "registry.*enabled"; then
        echo -e "${YELLOW}⚠️  Microk8s registry is not enabled. Enabling...${NC}"
        microk8s enable registry
        echo -e "${GREEN}✅ Microk8s registry enabled${NC}"
        sleep 10
    else
        echo -e "${GREEN}✅ Microk8s registry is already enabled${NC}"
    fi
}

# Build Docker image
build_image() {
    echo -e "${BLUE}🔨 Building Docker image...${NC}"
    
    # Build with BuildKit for better performance
    export DOCKER_BUILDKIT=1
    
    docker build \
        --target ${BUILD_STAGE} \
        --tag ${FULL_IMAGE_NAME} \
        --file docker/k8s/Dockerfile \
        --build-arg BUILDKIT_INLINE_CACHE=1 \
        --progress=plain \
        .
    
    echo -e "${GREEN}✅ Image built successfully: ${FULL_IMAGE_NAME}${NC}"
}

# Push image to registry
push_image() {
    echo -e "${BLUE}📤 Pushing image to Microk8s registry...${NC}"
    
    docker push ${FULL_IMAGE_NAME}
    
    echo -e "${GREEN}✅ Image pushed successfully${NC}"
}

# Show image info
show_info() {
    echo -e "${BLUE}📋 Image Information:${NC}"
    echo -e "Registry: ${REGISTRY}"
    echo -e "Image: ${IMAGE_NAME}"
    echo -e "Tag: ${TAG}"
    echo -e "Full name: ${FULL_IMAGE_NAME}"
    echo -e "Build stage: ${BUILD_STAGE}"
    
    # Show image size
    SIZE=$(docker images ${FULL_IMAGE_NAME} --format "table {{.Size}}" | tail -n +2)
    echo -e "Size: ${SIZE}"
    
    echo ""
    echo -e "${GREEN}🚀 Usage in Kubernetes:${NC}"
    echo -e "helm upgrade laravel-app helm/laravel-app \\"
    echo -e "  --namespace laravel-app-dev \\"
    echo -e "  --values helm/laravel-app/values-dev.yaml \\"
    echo -e "  --set image.registry=\"${REGISTRY}\" \\"
    echo -e "  --set image.repository=\"${IMAGE_NAME}\" \\"
    echo -e "  --set image.tag=\"${TAG}\""
}

# Main execution
main() {
    echo -e "${GREEN}🚀 Starting Laravel Docker build process${NC}"
    
    check_registry
    build_image
    push_image
    show_info
    
    echo -e "${GREEN}✨ Build and push completed successfully!${NC}"
}

# Error handling
trap 'echo -e "${RED}❌ Build failed!${NC}"; exit 1' ERR

# Show help
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "Usage: $0 [BUILD_STAGE] [TAG]"
    echo ""
    echo "BUILD_STAGE:"
    echo "  production, prod    - Build production image (default)"
    echo "  development, dev    - Build development image with debugging"
    echo ""
    echo "TAG:"
    echo "  Custom tag for the image (default: latest for prod, dev for development)"
    echo ""
    echo "Examples:"
    echo "  $0                    # Build production image with tag 'latest'"
    echo "  $0 development        # Build development image with tag 'dev'"
    echo "  $0 production v1.0.0  # Build production image with tag 'v1.0.0'"
    echo "  $0 dev feature-xyz    # Build development image with tag 'feature-xyz'"
    exit 0
fi

# Run main function
main "$@" 