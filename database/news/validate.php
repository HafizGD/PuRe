<?php
/**
 * Validate News API
 * Endpoint:
 *   POST /validate.php - Validate news (add validation)
 *   GET /validate.php?link=URL - Get validation stats for news
 * 
 * POST Body: {"action": "validate", "user_id": int, "link": "string", "is_valid": 1|0}
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

// GET - Get validation stats for a news link
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $link = isset($_GET['link']) ? trim($_GET['link']) : '';
    
    if (empty($link)) {
        ob_end_clean();
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'link harus diisi']);
        exit();
    }
    
    $stmt = $conn->prepare("SELECT jumlah_valid, jumlah_tidak_valid FROM validate_news WHERE link = ?");
    $stmt->bind_param("s", $link);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();
        $stmt->close();
        $conn->close();
        
        ob_end_clean();
        echo json_encode([
            'success' => true,
            'link' => $link,
            'jumlah_valid' => intval($row['jumlah_valid']),
            'jumlah_tidak_valid' => intval($row['jumlah_tidak_valid'])
        ]);
    } else {
        $stmt->close();
        $conn->close();
        
        ob_end_clean();
        // Return default values if no validation exists
        echo json_encode([
            'success' => true,
            'link' => $link,
            'jumlah_valid' => 0,
            'jumlah_tidak_valid' => 0
        ]);
    }
    
    exit();
}

// POST - Add validation
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
    $isValid = isset($data['is_valid']) ? intval($data['is_valid']) : -1;
    
    if ($action !== 'validate') {
        ob_end_clean();
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Action harus "validate"']);
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
    
    if ($isValid !== 0 && $isValid !== 1) {
        ob_end_clean();
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'is_valid harus 0 (hoax) atau 1 (valid)']);
        exit();
    }
    
    // Check if user has already validated this news
    $stmt = $conn->prepare("SELECT id, is_valid FROM user_validation WHERE user_id = ? AND link = ?");
    $stmt->bind_param("is", $userId, $link);
    $stmt->execute();
    $userValidationResult = $stmt->get_result();
    $stmt->close();
    
    if ($userValidationResult->num_rows > 0) {
        // User has already validated, update their validation
        $row = $userValidationResult->fetch_assoc();
        $oldIsValid = intval($row['is_valid']);
        
        if ($oldIsValid !== $isValid) { // Only update if validation changed
            $stmt = $conn->prepare("UPDATE user_validation SET is_valid = ?, updated_at = CURRENT_TIMESTAMP WHERE user_id = ? AND link = ?");
            $stmt->bind_param("iis", $isValid, $userId, $link);
            $stmt->execute();
            $stmt->close();
        }
    } else {
        // User has not validated yet, insert new validation
        $stmt = $conn->prepare("INSERT INTO user_validation (user_id, link, is_valid) VALUES (?, ?, ?)");
        $stmt->bind_param("isi", $userId, $link, $isValid);
        $stmt->execute();
        $stmt->close();
    }
    
    // Recalculate aggregate counts in validate_news
    $stmt = $conn->prepare("SELECT SUM(CASE WHEN is_valid = 1 THEN 1 ELSE 0 END) as total_valid, SUM(CASE WHEN is_valid = 0 THEN 1 ELSE 0 END) as total_invalid FROM user_validation WHERE link = ?");
    $stmt->bind_param("s", $link);
    $stmt->execute();
    $aggregateResult = $stmt->get_result();
    $aggregateRow = $aggregateResult->fetch_assoc();
    $stmt->close();
    
    $totalValid = intval($aggregateRow['total_valid']);
    $totalInvalid = intval($aggregateRow['total_invalid']);
    
    // Update or insert into validate_news
    $stmt = $conn->prepare("INSERT INTO validate_news (link, jumlah_valid, jumlah_tidak_valid) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE jumlah_valid = VALUES(jumlah_valid), jumlah_tidak_valid = VALUES(jumlah_tidak_valid)");
    $stmt->bind_param("sii", $link, $totalValid, $totalInvalid);
    $stmt->execute();
    $stmt->close();
    $conn->close();
    
    ob_end_clean();
    echo json_encode([
        'success' => true,
        'message' => 'Validasi berhasil',
        'jumlah_valid' => $totalValid,
        'jumlah_tidak_valid' => $totalInvalid
    ]);
    exit();
}

ob_end_clean();
http_response_code(405);
echo json_encode(['success' => false, 'message' => 'Method not allowed']);
?>
