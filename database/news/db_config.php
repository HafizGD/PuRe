<?php
/**
 * Database Configuration
 * Ganti dengan konfigurasi database XAMPP Anda
 */

$host = 'localhost';
$dbname = 'news_app';
$username = 'root';
$password = '';

try {
    $conn = new mysqli($host, $username, $password, $dbname);
    
    // Set charset to utf8mb4
    $conn->set_charset("utf8mb4");
    
    // Check connection
    if ($conn->connect_error) {
        die(json_encode([
            'success' => false,
            'message' => 'Connection failed: ' . $conn->connect_error
        ]));
    }
} catch (Exception $e) {
    die(json_encode([
        'success' => false,
        'message' => 'Database connection error: ' . $e->getMessage()
    ]));
}
?>
