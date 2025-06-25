#!/bin/bash

echo "🚀 Setting up Husky and development tools..."

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

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    print_error "Node.js is not installed. Please install Node.js 20+ first."
    exit 1
fi

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    print_error "npm is not installed. Please install npm first."
    exit 1
fi

# Check if Composer is installed
if ! command -v composer &> /dev/null; then
    print_error "Composer is not installed. Please install Composer first."
    exit 1
fi

print_status "Installing npm dependencies..."
npm install

if [ $? -ne 0 ]; then
    print_error "Failed to install npm dependencies"
    exit 1
fi

print_status "Installing Composer dependencies..."
composer install

if [ $? -ne 0 ]; then
    print_error "Failed to install Composer dependencies"
    exit 1
fi

print_status "Setting up Husky..."
npm run prepare

if [ $? -ne 0 ]; then
    print_error "Failed to setup Husky"
    exit 1
fi

print_status "Making Husky hooks executable..."
chmod +x .husky/pre-commit
chmod +x .husky/commit-msg
chmod +x .husky/pre-push

print_status "Testing PHP CS Fixer..."
composer lint --dry-run

if [ $? -ne 0 ]; then
    print_warning "PHP CS Fixer found issues. Run 'composer lint-fix' to fix them."
else
    print_success "PHP CS Fixer check passed"
fi

print_status "Testing PHPStan..."
composer exec phpstan analyse --level=8

if [ $? -ne 0 ]; then
    print_warning "PHPStan found issues. Check the output above."
else
    print_success "PHPStan check passed"
fi

print_status "Testing ESLint..."
npx eslint resources/js --ext .js,.vue --fix

if [ $? -ne 0 ]; then
    print_warning "ESLint found issues. Check the output above."
else
    print_success "ESLint check passed"
fi

print_status "Testing Stylelint..."
npx stylelint resources/css --fix

if [ $? -ne 0 ]; then
    print_warning "Stylelint found issues. Check the output above."
else
    print_success "Stylelint check passed"
fi

print_success "🎉 Husky setup completed successfully!"

echo ""
echo "📋 What's been configured:"
echo "  ✅ Git hooks (pre-commit, commit-msg, pre-push)"
echo "  ✅ PHP CS Fixer for code style"
echo "  ✅ PHPStan for static analysis"
echo "  ✅ ESLint for JavaScript/Vue linting"
echo "  ✅ Stylelint for CSS/SCSS linting"
echo "  ✅ Prettier for code formatting"
echo "  ✅ Conventional commit validation"
echo ""

echo "🔧 Available commands:"
echo "  composer lint          # Check PHP code style"
echo "  composer lint-fix      # Fix PHP code style"
echo "  composer test          # Run PHP tests"
echo "  composer security      # Run security checks"
echo "  npm run lint           # Lint all files"
echo "  npm run lint:js        # Lint JavaScript/Vue files"
echo "  npm run lint:css       # Lint CSS/SCSS files"
echo ""

echo "🚀 Git hooks will now run automatically:"
echo "  • Pre-commit: Lint and format code"
echo "  • Commit-msg: Validate commit format"
echo "  • Pre-push: Security checks and tests"
echo ""

print_success "Setup complete! Happy coding! 🎯" 