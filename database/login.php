<?php
/**
 * User Login API
 * Endpoint: POST /login.php
 * Body: {"username": "string", "password": "string"}
 */

// Set error reporting untuk development (hapus di production)
error_reporting(E_ALL);
ini_set('display_errors', 0); // Jangan tampilkan error langsung, return sebagai JSON
ini_set('log_errors', 1); // Log errors to file instead

// Prevent any output before JSON
ob_start();

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Handle preflight request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    ob_end_clean(); // Clear any output
    http_response_code(200);
    exit();
}

// Error handler untuk memastikan semua error return JSON
function handleError($errno, $errstr, $errfile, $errline) {
    ob_end_clean(); // Clear any output
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Server error: ' . $errstr
    ]);
    exit();
}

set_error_handler('handleError');

try {
    require_once 'db_config.php';
} catch (Exception $e) {
    ob_end_clean(); // Clear any output
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Database connection error: ' . $e->getMessage()
    ]);
    exit();
}

// Only allow POST method
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    ob_end_clean(); // Clear any output
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed']);
    exit();
}

// Get JSON input
$data = json_decode(file_get_contents('php://input'), true);

if (!$data) {
    ob_end_clean(); // Clear any output
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Invalid JSON input']);
    exit();
}

$username = trim($data['username'] ?? '');
$password = trim($data['password'] ?? '');

// Validation
if (empty($username) || empty($password)) {
    ob_end_clean(); // Clear any output
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Username dan password harus diisi']);
    exit();
}

// Get user from database
try {
    $stmt = $conn->prepare("SELECT id, username, password_hash FROM user WHERE username = ?");
    if (!$stmt) {
        throw new Exception('Prepare failed: ' . $conn->error);
    }
    
    $stmt->bind_param("s", $username);
    if (!$stmt->execute()) {
        throw new Exception('Execute failed: ' . $stmt->error);
    }
    
    $result = $stmt->get_result();
    
    if ($result->num_rows === 0) {
        $stmt->close();
        $conn->close();
        ob_end_clean(); // Clear any output
        http_response_code(401);
        echo json_encode(['success' => false, 'message' => 'Username atau password salah']);
        exit();
    }
    
    $user = $result->fetch_assoc();
    
    // Check if password_hash is valid (might be old plain text password)
    $passwordValid = false;
    if (password_verify($password, $user['password_hash'])) {
        $passwordValid = true;
    } else {
        // Fallback: check if password_hash is actually plain text (for old data)
        if ($user['password_hash'] === $password) {
            $passwordValid = true;
            // Update to hashed password
            $updateStmt = $conn->prepare("UPDATE user SET password_hash = ? WHERE id = ?");
            $hashedPassword = password_hash($password, PASSWORD_DEFAULT);
            $updateStmt->bind_param("si", $hashedPassword, $user['id']);
            $updateStmt->execute();
            $updateStmt->close();
        }
    }
    
    // Verify password
    if ($passwordValid) {
        $stmt->close();
        $conn->close();
        
        ob_end_clean(); // Clear any output before JSON
        http_response_code(200);
        echo json_encode([
            'success' => true,
            'message' => 'Login berhasil',
            'user_id' => intval($user['id']),
            'username' => $user['username']
        ]);
        exit();
    } else {
        $stmt->close();
        $conn->close();
        ob_end_clean(); // Clear any output before JSON
        http_response_code(401);
        echo json_encode(['success' => false, 'message' => 'Username atau password salah']);
        exit();
    }
} catch (Exception $e) {
    if (isset($stmt)) $stmt->close();
    if (isset($conn)) $conn->close();
    ob_end_clean(); // Clear any output before JSON
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Database error: ' . $e->getMessage()
    ]);
    exit();
}
?>
