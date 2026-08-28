<?php
/**
 * Verified News API
 * Endpoint: GET /verified_news.php
 * 
 * Returns news that have been validated by at least 5 users,
 * ordered by validation count (highest first)
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

ob_start();

// GET - Get verified news (minimal 5 validations)
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    try {
        // Get news links that have at least 5 validations, ordered by jumlah_valid DESC
        $stmt = $conn->prepare("
            SELECT link, jumlah_valid, jumlah_tidak_valid 
            FROM validate_news 
            WHERE jumlah_valid >= 5 
            ORDER BY jumlah_valid DESC
        ");
        $stmt->execute();
        $result = $stmt->get_result();
        
        $verifiedLinks = [];
        while ($row = $result->fetch_assoc()) {
            $verifiedLinks[] = [
                'link' => $row['link'],
                'jumlah_valid' => intval($row['jumlah_valid']),
                'jumlah_tidak_valid' => intval($row['jumlah_tidak_valid']),
            ];
        }
        $stmt->close();
        
        if (empty($verifiedLinks)) {
            $conn->close();
            ob_end_clean();
            echo json_encode([
                'success' => true,
                'verified_news' => []
            ]);
            exit();
        }
        
        // For each verified link, get the most recent news data from recent_news or bookmarks_news
        $verifiedNews = [];
        foreach ($verifiedLinks as $verifiedLink) {
            $link = $verifiedLink['link'];
            
            // Try to get from recent_news first (most recent)
            $stmt = $conn->prepare("
                SELECT link, title, snippet, content, thumbnail, author, published_at
                FROM recent_news
                WHERE link = ?
                ORDER BY created_at DESC
                LIMIT 1
            ");
            $stmt->bind_param("s", $link);
            $stmt->execute();
            $newsResult = $stmt->get_result();
            
            if ($newsResult->num_rows > 0) {
                $newsRow = $newsResult->fetch_assoc();
                $verifiedNews[] = [
                    'link' => $newsRow['link'],
                    'title' => $newsRow['title'],
                    'snippet' => $newsRow['snippet'],
                    'content' => $newsRow['content'],
                    'thumbnail' => $newsRow['thumbnail'],
                    'author' => $newsRow['author'],
                    'publishedAt' => $newsRow['published_at'],
                    'jumlah_valid' => $verifiedLink['jumlah_valid'],
                    'jumlah_tidak_valid' => $verifiedLink['jumlah_tidak_valid'],
                ];
                $stmt->close();
                continue;
            }
            $stmt->close();
            
            // If not found in recent_news, try bookmarks_news
            $stmt = $conn->prepare("
                SELECT link, title, snippet, content, thumbnail, author, published_at
                FROM bookmarks_news
                WHERE link = ?
                LIMIT 1
            ");
            $stmt->bind_param("s", $link);
            $stmt->execute();
            $bookmarkResult = $stmt->get_result();
            
            if ($bookmarkResult->num_rows > 0) {
                $bookmarkRow = $bookmarkResult->fetch_assoc();
                $verifiedNews[] = [
                    'link' => $bookmarkRow['link'],
                    'title' => $bookmarkRow['title'],
                    'snippet' => $bookmarkRow['snippet'],
                    'content' => $bookmarkRow['content'],
                    'thumbnail' => $bookmarkRow['thumbnail'],
                    'author' => $bookmarkRow['author'],
                    'publishedAt' => $bookmarkRow['published_at'],
                    'jumlah_valid' => $verifiedLink['jumlah_valid'],
                    'jumlah_tidak_valid' => $verifiedLink['jumlah_tidak_valid'],
                ];
            }
            $stmt->close();
        }
        
        $conn->close();
        ob_end_clean();
        echo json_encode([
            'success' => true,
            'verified_news' => $verifiedNews
        ]);
        exit();
        
    } catch (Exception $e) {
        $conn->close();
        ob_end_clean();
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Error: ' . $e->getMessage()
        ]);
        exit();
    }
}

http_response_code(405);
ob_end_clean();
echo json_encode(['success' => false, 'message' => 'Method not allowed']);
?>







