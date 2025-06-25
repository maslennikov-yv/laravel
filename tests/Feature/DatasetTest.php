<?php

// Тестирование с использованием datasets
it('validates different email formats', function (string $email, bool $isValid) {
    $validator = \Illuminate\Support\Facades\Validator::make(
        ['email' => $email],
        ['email' => 'required|email']
    );

    expect($validator->passes())->toBe($isValid);
})->with([
    ['test@example.com', true],
    ['user.name@domain.co.uk', true],
    ['test+tag@example.org', true],
    ['invalid-email', false],
    ['@domain.com', false],
    ['test@', false],
]);

// Тестирование математических операций
it('performs math operations correctly', function (int $a, int $b, int $expected) {
    expect($a + $b)->toBe($expected);
})->with([
    [1, 2, 3],
    [5, 5, 10],
    [10, -5, 5],
    [0, 0, 0],
]);

// Тестирование строковых операций
it('validates string operations', function (string $input, string $expected) {
    expect(strtoupper($input))->toBe($expected);
})->with([
    ['hello', 'HELLO'],
    ['world', 'WORLD'],
    ['Laravel', 'LARAVEL'],
    ['pest', 'PEST'],
]);

// Именованные datasets
dataset('user_data', [
    'john' => ['John Doe', 'john@example.com'],
    'jane' => ['Jane Smith', 'jane@example.com'],
    'bob' => ['Bob Johnson', 'bob@example.com'],
]);

it('creates users with different data', function (string $name, string $email) {
    $user = \App\Models\User::factory()->create([
        'name' => $name,
        'email' => $email,
        'email_verified_at' => null,
    ]);

    expect($user)
        ->name->toBe($name)
        ->email->toBe($email);
})->with('user_data'); 