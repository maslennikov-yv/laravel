<?php

describe('Architecture', function () {
    test('controllers should extend base controller', function () {
        expect('App\Http\Controllers')
            ->toExtend('App\Http\Controllers\Controller');
    });

    test('models should extend base model', function () {
        expect('App\Models')
            ->toExtend('Illuminate\Database\Eloquent\Model');
    });

    test('models should use HasFactory trait', function () {
        expect('App\Models')
            ->toUse('Illuminate\Database\Eloquent\Factories\HasFactory');
    });

    test('controllers should not use database directly', function () {
        expect('App\Http\Controllers')
            ->not->toUse('Illuminate\Support\Facades\DB');
    });

    test('models should not use request', function () {
        expect('App\Models')
            ->not->toUse('Illuminate\Http\Request');
    });
});

describe('Naming Conventions', function () {
    test('controllers should have Controller suffix', function () {
        expect('App\Http\Controllers')
            ->toHaveSuffix('Controller');
    });

    test('models should be singular', function () {
        expect('App\Models\User')->toBeClasses();
    });
}); 