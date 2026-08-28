<?php
/**
 * Validate News API
 * Endpoint:
 *   POST /validate.php - Validate news (add validation)
 *   GET /validate.php?link=URL - Get validation stats for news
 * 
 * POST Body: {"action": "validate", "link": "string", "is_valid": 1|0}
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

// GET - Get validation stats for a news link
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $link = isset($_GET['link']) ? trim($_GET['link']) : '';
    
    if (empty($link)) {
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
        
        echo json_encode([
            'success' => true,
            'link' => $link,
            'jumlah_valid' => intval($row['jumlah_valid']),
            'jumlah_tidak_valid' => intval($row['jumlah_tidak_valid'])
        ]);
    } else {
        $stmt->close();
        $conn->close();
        
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
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Invalid JSON input']);
        exit();
    }
    
    $action = $data['action'] ?? '';
    $link = trim($data['link'] ?? '');
    $isValid = isset($data['is_valid']) ? intval($data['is_valid']) : -1;
    
    if ($action !== 'validate') {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Action harus "validate"']);
        exit();
    }
    
    if (empty($link)) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'link harus diisi']);
        exit();
    }
    
    if ($isValid !== 0 && $isValid !== 1) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'is_valid harus 0 (hoax) atau 1 (valid)']);
        exit();
    }
    
    // Check if validation record exists
    $stmt = $conn->prepare("SELECT id, jumlah_valid, jumlah_tidak_valid FROM validate_news WHERE link = ?");
    $stmt->bind_param("s", $link);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows > 0) {
        // Update existing record
        $row = $result->fetch_assoc();
        $currentValid = intval($row['jumlah_valid']);
        $currentInvalid = intval($row['jumlah_tidak_valid']);
        
        if ($isValid === 1) {
            $currentValid++;
        } else {
            $currentInvalid++;
        }
        
        $stmt = $conn->prepare("UPDATE validate_news SET jumlah_valid = ?, jumlah_tidak_valid = ? WHERE link = ?");
        $stmt->bind_param("iis", $currentValid, $currentInvalid, $link);
        
        if ($stmt->execute()) {
            $stmt->close();
            $conn->close();
            echo json_encode([
                'success' => true,
                'message' => 'Validasi berhasil diupdate',
                'jumlah_valid' => $currentValid,
                'jumlah_tidak_valid' => $currentInvalid
            ]);
        } else {
            $stmt->close();
            $conn->close();
            http_response_code(500);
            echo json_encode(['success' => false, 'message' => 'Gagal mengupdate validasi']);
        }
    } else {
        // Insert new validation record
        $jumlahValid = $isValid === 1 ? 1 : 0;
        $jumlahTidakValid = $isValid === 0 ? 1 : 0;
        
        $stmt = $conn->prepare("INSERT INTO validate_news (link, jumlah_valid, jumlah_tidak_valid) VALUES (?, ?, ?)");
        $stmt->bind_param("sii", $link, $jumlahValid, $jumlahTidakValid);
        
        if ($stmt->execute()) {
            $stmt->close();
            $conn->close();
            echo json_encode([
                'success' => true,
                'message' => 'Validasi berhasil ditambahkan',
                'jumlah_valid' => $jumlahValid,
                'jumlah_tidak_valid' => $jumlahTidakValid
            ]);
        } else {
            $stmt->close();
            $conn->close();
            http_response_code(500);
            echo json_encode(['success' => false, 'message' => 'Gagal menambahkan validasi']);
        }
    }
    
    exit();
}

http_response_code(405);
echo json_encode(['success' => false, 'message' => 'Method not allowed']);
?>








