<?php
/**
 * User Registration API
 * Endpoint: POST /register.php
 * Body: {"username": "string", "password": "string"}
 */

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Handle preflight request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

ob_start();

require_once 'db_config.php';

// Only allow POST method
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    ob_end_clean();
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed']);
    exit();
}

// Get JSON input
$data = json_decode(file_get_contents('php://input'), true);

if (!$data) {
    ob_end_clean();
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Invalid JSON input']);
    exit();
}

$username = trim($data['username'] ?? '');
$password = trim($data['password'] ?? '');

// Validation
if (empty($username) || empty($password)) {
    ob_end_clean();
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Username dan password harus diisi']);
    exit();
}

if (strlen($username) < 3) {
    ob_end_clean();
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Username minimal 3 karakter']);
    exit();
}

if (strlen($password) < 6) {
    ob_end_clean();
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Password minimal 6 karakter']);
    exit();
}

// Check if username already exists
$stmt = $conn->prepare("SELECT id FROM user WHERE username = ?");
$stmt->bind_param("s", $username);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $stmt->close();
    $conn->close();
    ob_end_clean();
    http_response_code(409);
    echo json_encode(['success' => false, 'message' => 'Username sudah digunakan']);
    exit();
}

// Hash password
$passwordHash = password_hash($password, PASSWORD_DEFAULT);

// Insert new user
$stmt = $conn->prepare("INSERT INTO user (username, password_hash) VALUES (?, ?)");
$stmt->bind_param("ss", $username, $passwordHash);

if ($stmt->execute()) {
    $userId = $conn->insert_id;
    $stmt->close();
    $conn->close();
    
    ob_end_clean();
    http_response_code(201);
    echo json_encode([
        'success' => true,
        'message' => 'Registrasi berhasil',
        'user_id' => $userId,
        'username' => $username
    ]);
} else {
    $stmt->close();
    $conn->close();
    ob_end_clean();
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Gagal melakukan registrasi']);
}
?>
