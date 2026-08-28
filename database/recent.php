<?php
/**
 * Recent News API
 * Endpoint:
 *   POST /recent.php - Add recent news
 *   GET /recent.php - Get recent news list
 * 
 * POST Body: {"action": "add", "link": "string"}
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

// GET - Get recent news
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    // Get latest 10 recent news
    $stmt = $conn->prepare("SELECT link, created_at FROM recent_news ORDER BY created_at DESC LIMIT 10");
    $stmt->execute();
    $result = $stmt->get_result();
    
    $recents = [];
    while ($row = $result->fetch_assoc()) {
        $recents[] = [
            'link' => $row['link'],
            'created_at' => $row['created_at']
        ];
    }
    
    $stmt->close();
    $conn->close();
    
    echo json_encode([
        'success' => true,
        'recents' => $recents
    ]);
    exit();
}

// POST - Add recent news
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data = json_decode(file_get_contents('php://input'), true);
    
    if (!$data) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Invalid JSON input']);
        exit();
    }
    
    $action = $data['action'] ?? '';
    $link = trim($data['link'] ?? '');
    
    if ($action !== 'add') {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Action harus "add"']);
        exit();
    }
    
    if (empty($link)) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'link harus diisi']);
        exit();
    }
    
    // Check if recent news already exists (to avoid duplicates)
    $stmt = $conn->prepare("SELECT id FROM recent_news WHERE link = ?");
    $stmt->bind_param("s", $link);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows > 0) {
        // Update created_at to current timestamp
        $stmt = $conn->prepare("UPDATE recent_news SET created_at = CURRENT_TIMESTAMP WHERE link = ?");
        $stmt->bind_param("s", $link);
        $stmt->execute();
        $stmt->close();
        $conn->close();
        
        echo json_encode(['success' => true, 'message' => 'Recent news berhasil diupdate']);
    } else {
        // Insert new recent news
        $stmt = $conn->prepare("INSERT INTO recent_news (link) VALUES (?)");
        $stmt->bind_param("s", $link);
        
        if ($stmt->execute()) {
            $stmt->close();
            $conn->close();
            echo json_encode(['success' => true, 'message' => 'Recent news berhasil ditambahkan']);
        } else {
            $stmt->close();
            $conn->close();
            http_response_code(500);
            echo json_encode(['success' => false, 'message' => 'Gagal menambahkan recent news']);
        }
    }
    
    exit();
}

http_response_code(405);
echo json_encode(['success' => false, 'message' => 'Method not allowed']);
?>








