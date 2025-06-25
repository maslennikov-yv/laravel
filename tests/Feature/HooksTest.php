<?php

use App\Models\User;

describe('User Management with Hooks', function () {
    beforeEach(function () {
        // Выполняется перед каждым тестом в этой группе
        $this->testUser = User::factory()->create([
            'name' => 'Test User',
            'email' => 'test@example.com',
            'email_verified_at' => null,
        ]);
    });

    afterEach(function () {
        // Выполняется после каждого теста в этой группе
        // В данном случае не нужно, так как RefreshDatabase очищает базу
    });

    test('user exists after setup', function () {
        expect($this->testUser)->toBeInstanceOf(User::class);
        expect($this->testUser->name)->toBe('Test User');
    });

    test('can update user', function () {
        $this->testUser->update(['name' => 'Updated Name']);
        
        expect($this->testUser->fresh()->name)->toBe('Updated Name');
    });

    test('can delete user', function () {
        $userId = $this->testUser->id;
        $this->testUser->delete();
        
        expect(User::find($userId))->toBeNull();
    });
});

// Тесты с группировкой
describe('Authentication Tests', function () {
    test('user can be authenticated', function () {
        $user = User::factory()->create();
        
        expect(auth()->attempt([
            'email' => $user->email,
            'password' => 'password', // Стандартный пароль из фабрики
        ]))->toBeTrue();
        
        expect(auth()->user()->id)->toBe($user->id);
    });

    test('user cannot be authenticated with wrong password', function () {
        $user = User::factory()->create();
        
        expect(auth()->attempt([
            'email' => $user->email,
            'password' => 'wrong-password',
        ]))->toBeFalse();
        
        expect(auth()->user())->toBeNull();
    });
})->group('auth');

// Пропуск тестов
it('will be skipped', function () {
    expect(true)->toBeTrue();
})->skip('This test is not ready yet');

// Условный пропуск
it('runs only on specific conditions', function () {
    expect(PHP_VERSION)->toBeString();
})->skipOnWindows();

// Тест только для определенной версии PHP
it('runs only on PHP 8.4+', function () {
    expect(version_compare(PHP_VERSION, '8.4.0', '>='))->toBeTrue();
})->skip(version_compare(PHP_VERSION, '8.4.0', '<'), 'Requires PHP 8.4+'); 