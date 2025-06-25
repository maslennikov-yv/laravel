<?php

use Illuminate\Support\Facades\Validator;

describe('Email Validation', function () {
    test('valid emails pass validation', function () {
        $validEmails = [
            'test@example.com',
            'user.name@domain.co.uk',
            'test+tag@example.org',
        ];

        foreach ($validEmails as $email) {
            expect($email)->toBeValidEmail();
            
            $validator = Validator::make(['email' => $email], [
                'email' => 'required|email'
            ]);
            
            expect($validator->passes())->toBeTrue();
        }
    });

    test('invalid emails fail validation', function () {
        $invalidEmails = [
            'invalid-email',
            '@domain.com',
            'test@',
            'test..test@example.com',
        ];

        foreach ($invalidEmails as $email) {
            $validator = Validator::make(['email' => $email], [
                'email' => 'required|email'
            ]);
            
            expect($validator->fails())->toBeTrue();
        }
    });
});

describe('Custom Expectations', function () {
    test('custom toBeOne expectation works', function () {
        expect(1)->toBeOne();
        expect(2)->not->toBeOne();
    });

    test('custom URL validation works', function () {
        expect('https://example.com')->toBeValidUrl();
        expect('http://test.org')->toBeValidUrl();
        expect('invalid-url')->not->toBeValidUrl();
    });
});

it('validates required fields', function () {
    $validator = Validator::make([], [
        'name' => 'required',
        'email' => 'required|email',
    ]);

    expect($validator->fails())->toBeTrue();
    expect($validator->errors()->has('name'))->toBeTrue();
    expect($validator->errors()->has('email'))->toBeTrue();
});

it('validates field lengths', function () {
    $data = [
        'name' => str_repeat('a', 300), // Слишком длинное имя
        'email' => 'test@example.com',
    ];

    $validator = Validator::make($data, [
        'name' => 'required|max:255',
        'email' => 'required|email',
    ]);

    expect($validator->fails())->toBeTrue();
    expect($validator->errors()->has('name'))->toBeTrue();
    expect($validator->errors()->has('email'))->toBeFalse();
}); 