<?php
http_response_code(200);
echo json_encode([
    "status" => "healthy", 
    "timestamp" => date("c"), 
    "service" => "php-fpm-dev",
    "php_version" => PHP_VERSION,
    "extensions" => [
        "pdo" => extension_loaded("pdo"),
        "pdo_pgsql" => extension_loaded("pdo_pgsql"),
        "redis" => extension_loaded("redis"),
        "soap" => extension_loaded("soap"),
        "gd" => extension_loaded("gd"),
        "zip" => extension_loaded("zip")
    ]
]); 