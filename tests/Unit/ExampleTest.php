<?php

test('that true is true', function () {
    expect(true)->toBeTrue();
});

test('basic math operations', function () {
    expect(2 + 2)->toBe(4);
    expect(10)->toBeGreaterThan(5);
    expect('Laravel')->toBeString();
});

test('array operations', function () {
    $array = [1, 2, 3, 4, 5];
    
    expect($array)
        ->toHaveCount(5)
        ->toContain(3)
        ->not->toContain(6);
});
