<?php
/**
 * Test Connection API
 * Endpoint: GET /test.php
 * Untuk testing koneksi database dan API
 */

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Handle preflight request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once 'db_config.php';

// Test database connection
try {
    // Test query sederhana
    $stmt = $conn->prepare("SELECT 1 as test");
    $stmt->execute();
    $result = $stmt->get_result();
    $stmt->close();
    
    // Check if database tables exist
    $tables = ['user', 'bookmarks_news', 'recent_news', 'validate_news'];
    $existingTables = [];
    
    foreach ($tables as $table) {
        $checkStmt = $conn->prepare("SHOW TABLES LIKE ?");
        $checkStmt->bind_param("s", $table);
        $checkStmt->execute();
        $checkResult = $checkStmt->get_result();
        if ($checkResult->num_rows > 0) {
            $existingTables[] = $table;
        }
        $checkStmt->close();
    }
    
    $conn->close();
    
    echo json_encode([
        'success' => true,
        'message' => 'Koneksi database berhasil!',
        'database' => 'news_app',
        'tables_found' => $existingTables,
        'tables_expected' => $tables,
        'all_tables_exist' => count($existingTables) === count($tables),
        'server_info' => [
            'php_version' => phpversion(),
            'server_time' => date('Y-m-d H:i:s'),
        ]
    ]);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Database connection error: ' . $e->getMessage()
    ]);
}
?>

