## ✅ Project Status

This Laravel 12 application is fully configured and tested with:

- ✅ **Docker Development**: Laravel Sail setup with PHP 8.4
- ✅ **Testing Framework**: Pest testing with Docker integration
- ✅ **Kubernetes Deployment**: Complete Helm chart with multi-environment support
- ✅ **Dashboard Integration**: Kubernetes Dashboard with automated setup
- ✅ **Troubleshooting Tools**: Certificate fixes, ImagePullBackOff resolution, Service endpoint conflicts
- ✅ **Production Ready**: External services support (AWS RDS, ElastiCache, S3)

## 🚀 Quick Start with Docker

### One-command setup:
```sh
make setup
```

This command will:
- Install Laravel Sail (if not present)
- Copy .env.example to .env
- Start Docker containers
- Install PHP dependencies
- Generate application key
- Run database migrations and seeders

### Manual setup:
```sh
# Copy environment file
cp .env.example .env

# Install Laravel Sail and dependencies
make install-sail

# Start containers
make up

# Generate application key
make artisan CMD="key:generate"

# Run migrations and seeders
make migrate-fresh
```

Install NPM dependencies:

```sh
vendor/bin/sail npm ci
```

Run dev:

```sh
vendor/bin/sail npm run dev
```


### Daily usage:
```sh
# Start containers
make up

# Stop containers
make down

# Enter container shell
make shell

# Run tests
make test
```

## 🧪 Testing with Pest in Docker

This project uses [Pest](https://pestphp.com/) for testing in Docker containers with Laravel Sail and PHP 8.4.

### Quick Setup

Complete project setup (containers, dependencies, migrations):
```sh
make setup
```

### Quick Start

Run all tests in Docker:
```sh
vendor/bin/sail pest
# or
make test
```

Run specific test types:
```sh
# Unit tests in Docker
make test-unit

# Feature tests in Docker
make test-feature

# Tests with coverage in Docker
make test-coverage

# Tests in parallel
make test-parallel
```

### Docker Management

```sh
# Start containers
make up

# Stop containers  
make down

# Rebuild containers
make build

# Enter container shell
make shell
```

### Available Commands

**Testing:**
- `make test` - Run all tests in Docker
- `make test-unit` - Run Unit tests only
- `make test-feature` - Run Feature tests only
- `make test-coverage` - Run tests with coverage
- `make test-parallel` - Run tests in parallel
- `make test-group GROUP=auth` - Run specific test group
- `make test-local` - Run tests locally (without Docker)

**Development:**
- `make setup` - Complete project setup
- `make migrate` - Run database migrations
- `make artisan CMD="command"` - Run artisan commands
- `make composer CMD="command"` - Run composer commands
- `make help` - Show all available commands

## 🚀 Kubernetes Deployment

This project includes a comprehensive Helm chart for Kubernetes deployment with support for:

- **Flexible dependency management**: PostgreSQL, Redis, MinIO, Mailpit
- **Multiple environments**: dev, staging, production
- **External services support**: AWS RDS, ElastiCache, S3, etc.
- **Auto-scaling**: HorizontalPodAutoscaler for production
- **Security**: Network policies, security contexts, TLS

### Quick Kubernetes Deploy

```sh
# Development environment
make helm-deploy-dev

# Staging environment  
make helm-deploy-staging

# Production environment
make helm-deploy-prod
```

### Helm Commands

```sh
make helm-lint              # Validate Helm chart
make helm-template          # Generate Kubernetes manifests
make helm-deps              # Install chart dependencies
make helm-status            # Show release status
make k8s-logs              # View application logs
make k8s-shell             # Connect to container shell
```

### Documentation

- [Testing with Pest](TESTING.md) - Comprehensive testing guide
- [Docker Setup](DOCKER.md) - Docker and Sail usage guide
- [Kubernetes Deployment](KUBERNETES.md) - Complete Kubernetes deployment guide
