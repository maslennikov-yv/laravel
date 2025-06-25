<?php

use App\Models\User;

describe('User Model', function () {
    test('can create a user', function () {
        $user = User::factory()->create([
            'name' => 'John Doe',
            'email' => 'john@example.com',
            'email_verified_at' => null,
        ]);

        expect($user)
            ->name->toBe('John Doe')
            ->email->toBe('john@example.com')
            ->email_verified_at->toBeNull();

        expect($user->exists)->toBeTrue();
    });

    test('user email must be unique', function () {
        User::factory()->create(['email' => 'test@example.com']);

        expect(fn() => User::factory()->create(['email' => 'test@example.com']))
            ->toThrow(\Illuminate\Database\QueryException::class);
    });

    test('user has timestamps', function () {
        $user = User::factory()->create();

        expect($user)
            ->created_at->not->toBeNull()
            ->updated_at->not->toBeNull();
    });
});

describe('User Factory', function () {
    test('creates users with valid data', function () {
        $users = User::factory()->count(5)->create();

        expect($users)->toHaveCount(5);

        $users->each(function ($user) {
            expect($user->name)->toBeString()->not->toBeEmpty();
            expect($user->email)->toBeValidEmail();
            expect($user->password)->toBeString()->not->toBeEmpty();
        });
    });
});

it('can use helper function to create user', function () {
    $user = createUser(['name' => 'Test User']);

    expect($user)
        ->toBeInstanceOf(User::class)
        ->name->toBe('Test User');
});

it('can create multiple users with helper', function () {
    $users = createUsers(3);

    expect($users)->toHaveCount(3);
    expect($users->first())->toBeInstanceOf(User::class);
}); 