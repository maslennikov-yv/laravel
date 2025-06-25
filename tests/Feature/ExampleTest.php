<?php

test('the application returns a successful response', function () {
    $response = $this->get('/');

    $response->assertStatus(200);
});

test('welcome page contains Laravel', function () {
    $response = $this->get('/');

    $response
        ->assertStatus(200)
        ->assertSee('Laravel');
});

test('welcome page has correct structure', function () {
    $response = $this->get('/');

    expect($response->status())->toBe(200);
    expect($response->getContent())->toContain('Laravel');
});
