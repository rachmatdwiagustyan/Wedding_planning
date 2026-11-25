<?php
// CORS Headers for Flutter Web / Mobile REST API
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With, User-Id, X-User-Id, user_id");
header("Content-Type: application/json; charset=UTF-8");

// Suppress unhandled PHP notices/warnings from breaking JSON output
error_reporting(E_ALL & ~E_NOTICE & ~E_WARNING);
ini_set('display_errors', '0');

// Exception safety net: always return valid JSON on uncaught exceptions
set_exception_handler(function(Throwable $e) {
    if (!headers_sent()) {
        http_response_code(500);
        header("Content-Type: application/json; charset=UTF-8");
    }
    echo json_encode([
        "success" => false,
        "message" => "Kesalahan server: " . $e->getMessage(),
        "data" => null
    ], JSON_UNESCAPED_UNICODE);
    exit();
});

// Fatal error safety net: always return valid JSON on fatal shutdown
register_shutdown_function(function() {
    $error = error_get_last();
    if ($error && in_array($error['type'], [E_ERROR, E_PARSE, E_CORE_ERROR, E_COMPILE_ERROR])) {
        if (!headers_sent()) {
            http_response_code(500);
            header("Content-Type: application/json; charset=UTF-8");
        }
        echo json_encode([
            "success" => false,
            "message" => "Terjadi kendala pada server: " . $error['message'] . " (" . basename($error['file']) . ":" . $error['line'] . ").",
            "data" => null
        ], JSON_UNESCAPED_UNICODE);
    }
});

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}
