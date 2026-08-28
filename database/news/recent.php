<?php
/**
 * Recent News API
 * Endpoint:
 *   POST /recent.php - Add recent news
 *   GET /recent.php?user_id=X - Get recent news list for user
 * 
 * POST Body: {"action": "add", "user_id": int, "link": "string", "title": "string", ...}
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

ob_start();

// GET - Get recent news for user
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $userId = isset($_GET['user_id']) ? intval($_GET['user_id']) : 0;
    
    if ($userId <= 0) {
        ob_end_clean();
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'user_id harus diisi']);
        exit();
    }
    
    $stmt = $conn->prepare("SELECT link, title, snippet, content, thumbnail, author, published_at FROM recent_news WHERE user_id = ? ORDER BY created_at DESC");
    $stmt->bind_param("i", $userId);
    $stmt->execute();
    $result = $stmt->get_result();
    
    $recents = [];
    while ($row = $result->fetch_assoc()) {
        $recents[] = [
            'link' => $row['link'],
            'title' => $row['title'],
            'snippet' => $row['snippet'],
            'content' => $row['content'],
            'thumbnail' => $row['thumbnail'],
            'author' => $row['author'],
            'publishedAt' => $row['published_at']
        ];
    }
    
    $stmt->close();
    $conn->close();
    
    ob_end_clean();
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
        ob_end_clean();
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Invalid JSON input']);
        exit();
    }
    
    $action = $data['action'] ?? '';
    $userId = isset($data['user_id']) ? intval($data['user_id']) : 0;
    $link = trim($data['link'] ?? '');
    $title = isset($data['title']) ? trim($data['title']) : null;
    $snippet = isset($data['snippet']) ? trim($data['snippet']) : null;
    $content = isset($data['content']) ? trim($data['content']) : null;
    $thumbnail = isset($data['thumbnail']) ? trim($data['thumbnail']) : null;
    $author = isset($data['author']) ? trim($data['author']) : null;
    $publishedAt = isset($data['publishedAt']) ? trim($data['publishedAt']) : null;
    
    if ($action !== 'add') {
        ob_end_clean();
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Action harus "add"']);
        exit();
    }
    
    if ($userId <= 0) {
        ob_end_clean();
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'user_id harus diisi']);
        exit();
    }
    
    if (empty($link)) {
        ob_end_clean();
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'link harus diisi']);
        exit();
    }
    
    // Check if recent news already exists for user and link
    $stmt = $conn->prepare("SELECT id FROM recent_news WHERE user_id = ? AND link = ?");
    $stmt->bind_param("is", $userId, $link);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows > 0) {
        // Update existing recent news with new data and timestamp
        $stmt->close();
        $updateFields = ["created_at = CURRENT_TIMESTAMP"];
        $updateTypes = '';
        $updateParams = [];
        
        if ($title !== null) {
            $updateFields[] = "title = ?";
            $updateTypes .= 's';
            $updateParams[] = &$title;
        }
        if ($snippet !== null) {
            $updateFields[] = "snippet = ?";
            $updateTypes .= 's';
            $updateParams[] = &$snippet;
        }
        if ($content !== null) {
            $updateFields[] = "content = ?";
            $updateTypes .= 's';
            $updateParams[] = &$content;
        }
        if ($thumbnail !== null) {
            $updateFields[] = "thumbnail = ?";
            $updateTypes .= 's';
            $updateParams[] = &$thumbnail;
        }
        if ($author !== null) {
            $updateFields[] = "author = ?";
            $updateTypes .= 's';
            $updateParams[] = &$author;
        }
        if ($publishedAt !== null) {
            $updateFields[] = "published_at = ?";
            $updateTypes .= 's';
            $updateParams[] = &$publishedAt;
        }
        
        if (!empty($updateFields)) {
            $updateTypes .= 'is'; // for user_id and link
            $updateParams[] = &$userId;
            $updateParams[] = &$link;
            
            $updateSql = "UPDATE recent_news SET " . implode(", ", $updateFields) . " WHERE user_id = ? AND link = ?";
            $updateStmt = $conn->prepare($updateSql);
            call_user_func_array([$updateStmt, 'bind_param'], array_merge([$updateTypes], $updateParams));
            $updateStmt->execute();
            $updateStmt->close();
        }
        $conn->close();
        ob_end_clean();
        echo json_encode(['success' => true, 'message' => 'Recent news berhasil diupdate']);
        exit();
    } else {
        // Insert new recent news with all News data
        $stmt = $conn->prepare("INSERT INTO recent_news (user_id, link, title, snippet, content, thumbnail, author, published_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
        $stmt->bind_param("isssssss", $userId, $link, $title, $snippet, $content, $thumbnail, $author, $publishedAt);
        
        if ($stmt->execute()) {
            $stmt->close();
            $conn->close();
            ob_end_clean();
            echo json_encode(['success' => true, 'message' => 'Recent news berhasil ditambahkan']);
        } else {
            $stmt->close();
            $conn->close();
            ob_end_clean();
            http_response_code(500);
            echo json_encode(['success' => false, 'message' => 'Gagal menambahkan recent news']);
        }
    }
    
    exit();
}

ob_end_clean();
http_response_code(405);
echo json_encode(['success' => false, 'message' => 'Method not allowed']);
?>
