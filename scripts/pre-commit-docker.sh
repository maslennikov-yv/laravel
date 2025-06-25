#!/bin/sh
set -e

echo "🔍 Running pre-commit checks in Docker containers..."

# Настройка переменных окружения для git hooks
export PATH="/usr/local/bin:/usr/bin:/bin:$PATH"

# Проверка наличия Docker с полным путем
DOCKER_CMD="/usr/bin/docker"
if [ ! -x "$DOCKER_CMD" ]; then
    echo "❌ Docker not found at $DOCKER_CMD"
    exit 1
fi

echo "✅ Docker found at: $DOCKER_CMD"

# Проверка, что Docker daemon запущен
if ! "$DOCKER_CMD" info >/dev/null 2>&1; then
    echo "❌ Docker daemon is not running. Please start Docker first."
    exit 1
fi

echo "✅ Docker daemon is running"

# Запуск линтеров и тестов (с флагом -T для неинтерактивного режима)
# JS/TS lint
echo "📦 Running JS/TS lint..."
if "$DOCKER_CMD" compose -f docker-compose.dev.yml run -T --rm node-dev npm run lint; then
    echo "✅ JS/TS lint passed"
else
    echo "❌ JS/TS lint failed"
    exit 1
fi

# Prettier
echo "🎨 Running Prettier check..."
if "$DOCKER_CMD" compose -f docker-compose.dev.yml run -T --rm node-dev npm run prettier:check; then
    echo "✅ Prettier check passed"
else
    echo "❌ Prettier check failed"
    exit 1
fi

# Stylelint
echo "💄 Running Stylelint..."
if "$DOCKER_CMD" compose -f docker-compose.dev.yml run -T --rm node-dev npm run stylelint; then
    echo "✅ Stylelint passed"
else
    echo "❌ Stylelint failed"
    exit 1
fi

# PHP тесты
echo "🧪 Running PHP tests..."
if "$DOCKER_CMD" compose -f docker-compose.dev.yml run -T --rm php-dev composer test; then
    echo "✅ PHP tests passed"
else
    echo "❌ PHP tests failed"
    exit 1
fi

echo "🎉 All pre-commit checks passed!"
exit 0 