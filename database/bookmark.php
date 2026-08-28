<?php
/**
 * Bookmark News API
 * Endpoint: 
 *   POST /bookmark.php - Add or remove bookmark
 *   GET /bookmark.php?user_id=X - Get bookmarks for user
 * 
 * POST Body: {"action": "add|remove", "user_id": int, "link": "string"}
 */

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Handle preflight request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once 'db_config.php';

// GET - Get bookmarks for user
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $userId = isset($_GET['user_id']) ? intval($_GET['user_id']) : 0;
    
    if ($userId <= 0) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'user_id harus diisi']);
        exit();
    }
    
    $stmt = $conn->prepare("SELECT link, created_at FROM bookmarks_news WHERE user_id = ? ORDER BY created_at DESC");
    $stmt->bind_param("i", $userId);
    $stmt->execute();
    $result = $stmt->get_result();
    
    $bookmarks = [];
    while ($row = $result->fetch_assoc()) {
        $bookmarks[] = [
            'link' => $row['link'],
            'created_at' => $row['created_at']
        ];
    }
    
    $stmt->close();
    $conn->close();
    
    echo json_encode([
        'success' => true,
        'bookmarks' => $bookmarks
    ]);
    exit();
}

// POST - Add or remove bookmark
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data = json_decode(file_get_contents('php://input'), true);
    
    if (!$data) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Invalid JSON input']);
        exit();
    }
    
    $action = $data['action'] ?? '';
    $userId = isset($data['user_id']) ? intval($data['user_id']) : 0;
    $link = trim($data['link'] ?? '');
    
    // Validation
    if ($userId <= 0) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'user_id harus diisi']);
        exit();
    }
    
    if (empty($link)) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'link harus diisi']);
        exit();
    }
    
    if ($action === 'add') {
        // Check if bookmark already exists
        $stmt = $conn->prepare("SELECT id FROM bookmarks_news WHERE user_id = ? AND link = ?");
        $stmt->bind_param("is", $userId, $link);
        $stmt->execute();
        $result = $stmt->get_result();
        
        if ($result->num_rows > 0) {
            $stmt->close();
            $conn->close();
            echo json_encode(['success' => true, 'message' => 'Bookmark sudah ada']);
            exit();
        }
        
        // Add bookmark
        $stmt = $conn->prepare("INSERT INTO bookmarks_news (user_id, link) VALUES (?, ?)");
        $stmt->bind_param("is", $userId, $link);
        
        if ($stmt->execute()) {
            $stmt->close();
            $conn->close();
            echo json_encode(['success' => true, 'message' => 'Bookmark berhasil ditambahkan']);
        } else {
            $stmt->close();
            $conn->close();
            http_response_code(500);
            echo json_encode(['success' => false, 'message' => 'Gagal menambahkan bookmark']);
        }
        
    } elseif ($action === 'remove') {
        // Remove bookmark
        $stmt = $conn->prepare("DELETE FROM bookmarks_news WHERE user_id = ? AND link = ?");
        $stmt->bind_param("is", $userId, $link);
        
        if ($stmt->execute()) {
            $stmt->close();
            $conn->close();
            echo json_encode(['success' => true, 'message' => 'Bookmark berhasil dihapus']);
        } else {
            $stmt->close();
            $conn->close();
            http_response_code(500);
            echo json_encode(['success' => false, 'message' => 'Gagal menghapus bookmark']);
        }
        
    } else {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Action harus "add" atau "remove"']);
    }
    
    exit();
}

http_response_code(405);
echo json_encode(['success' => false, 'message' => 'Method not allowed']);
?>








