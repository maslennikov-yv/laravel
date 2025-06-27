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

# Laravel Application

A modern Laravel application with Kubernetes deployment and comprehensive testing and deployment pipeline.

## 🚀 Quick Start

### Prerequisites

- PHP 8.4+
- Composer
- Node.js 20+
- Docker
- Kubernetes cluster (for deployment)

### Local Development

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd example-app1
   ```

2. **Install dependencies**

   ```bash
   composer install
   npm install
   ```

3. **Setup environment**

   ```bash
   cp .env.example .env
   php artisan key:generate
   ```

4. **Setup database**

   ```bash
   php artisan migrate
   php artisan db:seed
   ```

5. **Start development server**
   ```bash
   php artisan serve
   npm run dev
   ```

## 🔧 Development Workflow

### Git Hooks (Husky)

This project uses Husky to enforce code quality standards. The following hooks are configured:

#### Pre-commit Hook

- Runs lint-staged to check and fix code style
- Executes PHP tests if PHP files were changed
- Formats code automatically

#### Commit Message Hook

- Validates conventional commit format
- Ensures consistent commit messages

#### Pre-push Hook

- Runs security checks
- Executes full test suite
- Warns about uncommitted changes
- Warns when pushing to main/develop branches

### Code Quality Tools

#### PHP

- **PHP CS Fixer**: Code style formatting
- **PHPStan**: Static analysis (Level 8)
- **Psalm**: Additional static analysis
- **PHPUnit**: Testing framework

#### JavaScript/CSS

- **ESLint**: JavaScript/Vue linting
- **Stylelint**: CSS/SCSS linting
- **Prettier**: Code formatting

### Available Commands

```bash
# PHP
composer lint          # Check code style
composer lint-fix      # Fix code style
composer test          # Run tests
composer test-coverage # Run tests with coverage
composer security      # Run security checks

# JavaScript/CSS
npm run lint           # Lint all files
npm run lint:js        # Lint JavaScript/Vue files
npm run lint:css       # Lint CSS/SCSS files

# Git hooks (automatic)
# Pre-commit: Runs lint-staged and tests
# Commit-msg: Validates commit format
# Pre-push: Runs security checks and full test suite
```

### Conventional Commits

This project follows the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

Types:

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `perf`: Performance improvements
- `test`: Adding or updating tests
- `build`: Build system changes
- `ci`: CI/CD changes
- `chore`: Maintenance tasks
- `revert`: Revert changes

Examples:

```bash
git commit -m "feat: add user authentication"
git commit -m "fix(auth): resolve login validation issue"
git commit -m "docs: update API documentation"
git commit -m "style: format code with PHP CS Fixer"
```

## 🐳 Docker & Kubernetes

### Local Development with Docker

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

### Kubernetes Deployment

```bash
# Deploy to development
helm upgrade --install laravel-app helm/laravel-app \
  --namespace laravel-app-dev \
  --create-namespace \
  --values helm/laravel-app/values-dev.yaml

# Deploy to production
helm upgrade --install laravel-app helm/laravel-app \
  --namespace laravel-app-prod \
  --create-namespace \
  --values helm/laravel-app/values-prod.yaml
```

## 📊 Monitoring & Health Checks

### Health Endpoints

- `/health`: Basic application health
- `/api/health`: Detailed health with database and Redis status

### Metrics

- Application metrics via Laravel Telescope (development)
- Kubernetes metrics via Prometheus/Grafana
- Log aggregation via ELK stack

## 🛠️ Troubleshooting

### Common Issues

1. **Husky hooks not working**

   ```bash
   npm run prepare  # Reinstall Husky
   ```

2. **Linting errors**

   ```bash
   composer lint-fix  # Fix PHP code style
   npm run lint:js    # Fix JavaScript code style
   npm run lint:css   # Fix CSS code style
   ```

3. **Tests failing**

   ```bash
   composer test --verbose  # Run tests with detailed output
   ```

4. **Docker build issues**
   ```bash
   docker system prune -a  # Clean Docker cache
   docker build --no-cache .  # Build without cache
   ```

## 📚 Additional Resources

- [Laravel Documentation](https://laravel.com/docs)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Helm Documentation](https://helm.sh/docs/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Husky Documentation](https://typicode.github.io/husky/)
- [CI/CD Pipeline](CI_CD.md) - Complete CI/CD pipeline documentation
