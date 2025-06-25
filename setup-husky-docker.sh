#!/bin/bash

echo "🐳 Setting up Husky and development tools in Docker containers..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is available (v2)
if ! docker compose version &> /dev/null; then
    print_error "Docker Compose is not available. Please install Docker Compose first."
    exit 1
fi

print_status "Building development containers..."
docker compose -f docker-compose.dev.yml build

if [ $? -ne 0 ]; then
    print_error "Failed to build development containers"
    exit 1
fi

print_status "Starting development services..."
docker compose -f docker-compose.dev.yml up -d postgres-dev redis-dev mailpit-dev

if [ $? -ne 0 ]; then
    print_error "Failed to start development services"
    exit 1
fi

print_status "Installing Composer dependencies in PHP container..."
docker compose -f docker-compose.dev.yml run --rm php-dev composer install

if [ $? -ne 0 ]; then
    print_error "Failed to install Composer dependencies"
    exit 1
fi

print_status "Installing npm dependencies in Node container..."
docker compose -f docker-compose.dev.yml run --rm node-dev npm install

if [ $? -ne 0 ]; then
    print_error "Failed to install npm dependencies"
    exit 1
fi

print_status "Setting up Husky in Node container..."
docker compose -f docker-compose.dev.yml run --rm node-dev npm run prepare

if [ $? -ne 0 ]; then
    print_error "Failed to setup Husky"
    exit 1
fi

print_status "Making Husky hooks executable..."
docker compose -f docker-compose.dev.yml run --rm node-dev chmod +x .husky/pre-commit
docker compose -f docker-compose.dev.yml run --rm node-dev chmod +x .husky/commit-msg
docker compose -f docker-compose.dev.yml run --rm node-dev chmod +x .husky/pre-push

print_status "Testing PHP CS Fixer in PHP container..."
docker compose -f docker-compose.dev.yml run --rm php-dev composer lint --dry-run

if [ $? -ne 0 ]; then
    print_warning "PHP CS Fixer found issues. Run 'docker compose -f docker-compose.dev.yml run --rm php-dev composer lint-fix' to fix them."
else
    print_success "PHP CS Fixer check passed"
fi

print_status "Testing PHPStan in PHP container..."
docker compose -f docker-compose.dev.yml run --rm php-dev composer exec phpstan analyse --level=8

if [ $? -ne 0 ]; then
    print_warning "PHPStan found issues. Check the output above."
else
    print_success "PHPStan check passed"
fi

print_status "Testing ESLint in Node container..."
docker compose -f docker-compose.dev.yml run --rm node-dev npx eslint resources/js --ext .js,.vue --fix

if [ $? -ne 0 ]; then
    print_warning "ESLint found issues. Check the output above."
else
    print_success "ESLint check passed"
fi

print_status "Testing Stylelint in Node container..."
docker compose -f docker-compose.dev.yml run --rm node-dev npx stylelint resources/css --fix

if [ $? -ne 0 ]; then
    print_warning "Stylelint found issues. Check the output above."
else
    print_success "Stylelint check passed"
fi

print_status "Setting up Laravel environment..."
docker compose -f docker-compose.dev.yml run --rm php-dev cp .env.example .env
docker compose -f docker-compose.dev.yml run --rm php-dev php artisan key:generate

print_status "Running database migrations..."
docker compose -f docker-compose.dev.yml run --rm php-dev php artisan migrate --force

print_success "🎉 Docker-based Husky setup completed successfully!"

echo ""
echo "📋 What's been configured:"
echo "  ✅ Development containers (PHP 8.4, Node.js 20)"
echo "  ✅ Git hooks (pre-commit, commit-msg, pre-push)"
echo "  ✅ PHP CS Fixer for code style"
echo "  ✅ PHPStan for static analysis"
echo "  ✅ ESLint for JavaScript/Vue linting"
echo "  ✅ Stylelint for CSS/SCSS linting"
echo "  ✅ Prettier for code formatting"
echo "  ✅ Conventional commit validation"
echo "  ✅ PostgreSQL, Redis, Mailpit services"
echo ""

echo "🔧 Available Docker commands:"
echo "  # PHP commands"
echo "  docker compose -f docker-compose.dev.yml run --rm php-dev composer lint"
echo "  docker compose -f docker-compose.dev.yml run --rm php-dev composer lint-fix"
echo "  docker compose -f docker-compose.dev.yml run --rm php-dev composer test"
echo "  docker compose -f docker-compose.dev.yml run --rm php-dev composer security"
echo ""
echo "  # Node.js commands"
echo "  docker compose -f docker-compose.dev.yml run --rm node-dev npm run lint"
echo "  docker compose -f docker-compose.dev.yml run --rm node-dev npm run lint:js"
echo "  docker compose -f docker-compose.dev.yml run --rm node-dev npm run lint:css"
echo ""
echo "  # Laravel commands"
echo "  docker compose -f docker-compose.dev.yml run --rm php-dev php artisan serve"
echo "  docker compose -f docker-compose.dev.yml run --rm php-dev php artisan migrate"
echo "  docker compose -f docker-compose.dev.yml run --rm php-dev php artisan tinker"
echo ""

echo "🚀 Git hooks will now run automatically in containers:"
echo "  • Pre-commit: Lint and format code"
echo "  • Commit-msg: Validate commit format"
echo "  • Pre-push: Security checks and tests"
echo ""

echo "🌐 Development services:"
echo "  • PostgreSQL: localhost:5432"
echo "  • Redis: localhost:6379"
echo "  • Mailpit: http://localhost:8025"
echo ""

print_success "Docker-based setup complete! Happy coding! 🎯" 