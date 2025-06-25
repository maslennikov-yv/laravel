# 🧪 Тестирование с Pest в Docker

Этот проект настроен для использования [Pest](https://pestphp.com/) - современного и элегантного фреймворка для тестирования PHP в Docker контейнерах с Laravel Sail.

## 🐳 Предварительные требования

Убедитесь, что Docker и Docker Compose установлены на вашей системе:
- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)

## 🚀 Быстрый старт

### Первоначальная настройка
```bash
# Настроить проект (запустить контейнеры, установить зависимости, выполнить миграции)
make setup
```

### Запуск всех тестов
```bash
# В Docker контейнерах (рекомендуется)
vendor/bin/sail pest
# или
make test

# Локально (если PHP 8.4 установлен локально)
make test-local
```

### Запуск определенного типа тестов
```bash
# Unit тесты в Docker
make test-unit

# Feature тесты в Docker
make test-feature

# Тесты с покрытием кода
make test-coverage
```

## 📋 Доступные команды

### 🐳 Docker/Sail команды
- `make sail-up` / `make up` - Запустить Docker контейнеры
- `make sail-down` / `make down` - Остановить Docker контейнеры
- `make sail-build` / `make build` - Пересобрать Docker контейнеры
- `make sail-shell` / `make shell` - Войти в shell контейнера приложения
- `make setup` - Полная настройка проекта в Docker

### 🧪 Основные команды тестирования
- `make test` - Запустить все тесты в Docker
- `make test-unit` - Запустить только Unit тесты в Docker
- `make test-feature` - Запустить только Feature тесты в Docker
- `make test-coverage` - Запустить тесты с покрытием кода в Docker
- `make test-parallel` - Запустить тесты параллельно в Docker

### 🔍 Специальные команды тестирования
- `make test-group GROUP=auth` - Запустить тесты определенной группы
- `make test-filter FILTER="User Model"` - Запустить тесты с фильтром
- `make test-watch` - Запустить тесты в режиме наблюдения
- `make test-debug` - Запустить тесты с отладочной информацией
- `make test-coverage-html` - Создать HTML отчет о покрытии

### 🛠️ Команды разработки
- `make install` - Установить PHP зависимости в Docker
- `make npm-install` - Установить npm зависимости в Docker
- `make migrate` - Запустить миграции в Docker
- `make migrate-fresh` - Пересоздать базу данных
- `make seed` - Запустить seeders в Docker
- `make clean` - Очистить кеш и временные файлы

### 📦 Локальные команды (без Docker)
- `make test-local` - Запустить тесты локально
- `make install-local` - Установить зависимости локально

### 🔗 Краткие алиасы
- `make t` - test
- `make tu` - test-unit
- `make tf` - test-feature
- `make tc` - test-coverage
- `make tp` - test-parallel
- `make up` - sail-up
- `make down` - sail-down

## 📝 Структура тестов

```
tests/
├── Pest.php              # Конфигурация Pest
├── TestCase.php           # Базовый класс для тестов
├── Unit/                  # Unit тесты
│   ├── ExampleTest.php
│   └── ValidationTest.php
└── Feature/               # Feature тесты
    ├── ExampleTest.php
    ├── UserTest.php
    ├── ArchitectureTest.php
    ├── DatasetTest.php
    └── HooksTest.php
```

## ✨ Возможности Pest

### 1. Простой синтаксис
```php
// Вместо PHPUnit
class ExampleTest extends TestCase
{
    public function test_example()
    {
        $this->assertTrue(true);
    }
}

// С Pest
test('example', function () {
    expect(true)->toBeTrue();
});
```

### 2. Описательные тесты
```php
it('can create a user', function () {
    $user = User::factory()->create();
    expect($user)->toBeInstanceOf(User::class);
});
```

### 3. Группировка с describe
```php
describe('User Model', function () {
    test('can create user', function () {
        // тест
    });
    
    test('can update user', function () {
        // тест
    });
});
```

### 4. Datasets для параметризованных тестов
```php
it('validates emails', function (string $email, bool $isValid) {
    // тест
})->with([
    ['test@example.com', true],
    ['invalid-email', false],
]);
```

### 5. Хуки beforeEach/afterEach
```php
describe('User tests', function () {
    beforeEach(function () {
        $this->user = User::factory()->create();
    });
    
    test('user exists', function () {
        expect($this->user)->toBeInstanceOf(User::class);
    });
});
```

### 6. Группировка тестов
```php
test('auth test', function () {
    // тест
})->group('auth');

// Запуск: ./vendor/bin/pest --group=auth
```

### 7. Пропуск тестов
```php
test('will be skipped', function () {
    // тест
})->skip('Not ready yet');

test('conditional skip', function () {
    // тест
})->skipOnWindows();
```

## 🎯 Expectations (Ожидания)

### Базовые ожидания
```php
expect($value)
    ->toBe(42)                    // ===
    ->toEqual([1, 2, 3])         // ==
    ->toBeTrue()                 // === true
    ->toBeFalse()                // === false
    ->toBeNull()                 // === null
    ->toBeEmpty()                // empty()
    ->toBeString()               // is_string()
    ->toBeInt()                  // is_int()
    ->toBeArray()                // is_array()
    ->toBeInstanceOf(User::class) // instanceof
    ->toHaveCount(5)             // count()
    ->toContain('item')          // in_array()
    ->toStartWith('prefix')      // str_starts_with()
    ->toEndWith('suffix')        // str_ends_with()
    ->toMatch('/pattern/')       // preg_match()
    ->toBeGreaterThan(10)        // >
    ->toBeLessThan(100)          // <
    ->toBeGreaterThanOrEqual(10) // >=
    ->toBeLessThanOrEqual(100)   // <=
    ->toBeBetween(1, 10)         // >= && <=
    ->not->toBe(42)              // Отрицание
```

### Laravel специфичные ожидания
```php
// HTTP Response
expect($response)
    ->toHaveStatus(200)
    ->toHaveHeader('Content-Type', 'application/json')
    ->toHaveRedirect('/dashboard');

// Database
expect('users')->toHaveRecord(['email' => 'test@example.com']);

// Validation
expect($validator)->toHaveErrors(['email']);
```

### Кастомные ожидания
```php
// В tests/Pest.php
expect()->extend('toBeValidEmail', function () {
    return $this->toMatch('/^[^\s@]+@[^\s@]+\.[^\s@]+$/');
});

// Использование
expect('test@example.com')->toBeValidEmail();
```

## 🏗️ Архитектурные тесты

```php
test('controllers extend base controller', function () {
    expect('App\Http\Controllers')
        ->toExtend('App\Http\Controllers\Controller');
});

test('models use HasFactory trait', function () {
    expect('App\Models')
        ->toUse('Illuminate\Database\Eloquent\Factories\HasFactory');
});

test('controllers have Controller suffix', function () {
    expect('App\Http\Controllers')
        ->toHaveSuffix('Controller');
});
```

## 🔧 Конфигурация

### pest.json
```json
{
    "testdox": true,
    "colors": "always",
    "coverage": {
        "include": ["app"],
        "exclude": ["app/Console"]
    },
    "parallel": {
        "processes": 4
    }
}
```

### tests/Pest.php
```php
// Расширение TestCase для Feature тестов
pest()->extend(Tests\TestCase::class)
    ->use(Illuminate\Foundation\Testing\RefreshDatabase::class)
    ->in('Feature');

// Кастомные ожидания
expect()->extend('toBeValidEmail', function () {
    return $this->toMatch('/^[^\s@]+@[^\s@]+\.[^\s@]+$/');
});

// Глобальные функции
function createUser(array $attributes = []): User
{
    return User::factory()->create($attributes);
}
```

## 🐳 Работа с Docker

### Управление контейнерами
```bash
# Запустить все контейнеры
make up

# Остановить контейнеры
make down

# Пересобрать контейнеры
make build

# Войти в shell контейнера приложения
make shell

# Посмотреть логи
make sail-logs
```

### Выполнение команд в контейнере
```bash
# Выполнить любую artisan команду
make artisan CMD="route:list"

# Выполнить composer команду
make composer CMD="require package/name"

# Установить npm зависимости
make npm-install

# Запустить Vite dev server
make npm-dev
```

## 📊 Покрытие кода

```bash
# Текстовый отчет в Docker
make test-coverage

# HTML отчет в Docker
make test-coverage-html

# Прямые команды через Sail
vendor/bin/sail pest --coverage
vendor/bin/sail pest --coverage-html=coverage-report
```

## 🚀 Параллельное выполнение

```bash
# В Docker (автоматическое определение процессов)
make test-parallel

# Прямая команда с указанием процессов
vendor/bin/sail pest --parallel --processes=4
```

## 📱 Режим наблюдения

```bash
# В Docker (автоматический перезапуск при изменении файлов)
make test-watch

# Прямая команда
vendor/bin/sail pest --watch
```

## 🔧 Настройка окружения

### Переменные окружения для тестов
В файле `phpunit.xml` настроены переменные для тестового окружения:
```xml
<env name="APP_ENV" value="testing"/>
<env name="DB_CONNECTION" value="sqlite"/>
<env name="DB_DATABASE" value=":memory:"/>
<env name="CACHE_STORE" value="array"/>
```

### Docker Compose настройки
Проект использует Laravel Sail с PHP 8.4 и следующими сервисами:
- **PostgreSQL** - основная база данных
- **Redis** - кеширование и очереди
- **Mailpit** - тестирование email
- **Meilisearch** - полнотекстовый поиск
- **MinIO** - S3-совместимое хранилище
- **Selenium** - браузерные тесты

## 🎨 Полезные советы

1. **Используйте описательные имена тестов**
   ```php
   it('creates user with valid email address')
   it('throws exception when email is invalid')
   ```

2. **Группируйте связанные тесты**
   ```php
   describe('User authentication', function () {
       // тесты аутентификации
   });
   ```

3. **Используйте datasets для тестирования множественных сценариев**
   ```php
   it('validates different inputs', function ($input, $expected) {
       // тест
   })->with([
       ['input1', 'expected1'],
       ['input2', 'expected2'],
   ]);
   ```

4. **Создавайте кастомные ожидания для доменной логики**
   ```php
   expect()->extend('toBeValidUser', function () {
       return $this->toBeInstanceOf(User::class)
                   ->and($this->value->email)->toBeValidEmail();
   });
   ```

## 📚 Дополнительные ресурсы

- [Официальная документация Pest](https://pestphp.com/docs)
- [Pest Laravel Plugin](https://pestphp.com/docs/plugins/laravel)
- [Pest Architecture Plugin](https://pestphp.com/docs/plugins/arch)
- [Примеры тестов в этом проекте](tests/) 