<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Redis;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "web" middleware group. Make something great!
|
*/

Route::get('/', function () {
    return view('welcome');
});

// Health check endpoint for CI/CD
Route::get('/health', function () {
    return response()->json([
        'status' => 'healthy',
        'timestamp' => now()->toISOString(),
        'service' => 'laravel-app',
        'version' => config('app.version', '1.0.0'),
        'environment' => config('app.env'),
    ]);
});

// API health check
Route::get('/api/health', function () {
    try {
        // Test database connection
        $dbStatus = DB::connection()->getPdo() ? 'connected' : 'disconnected';
        
        // Test Redis connection
        $redisStatus = 'unknown';
        try {
            Redis::ping();
            $redisStatus = 'connected';
        } catch (Exception $e) {
            $redisStatus = 'disconnected';
        }
        
        return response()->json([
            'status' => 'healthy',
            'timestamp' => now()->toISOString(),
            'service' => 'laravel-api',
            'database' => $dbStatus,
            'redis' => $redisStatus,
            'version' => config('app.version', '1.0.0'),
        ]);
    } catch (Exception $e) {
        return response()->json([
            'status' => 'unhealthy',
            'error' => $e->getMessage(),
            'timestamp' => now()->toISOString(),
        ], 500);
    }
});
