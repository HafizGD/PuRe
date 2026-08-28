<?php
$origin = $_SERVER['HTTP_ORIGIN'] ?? '';

if ($origin !== '') {
    header("Access-Control-Allow-Origin: $origin");
    header('Vary: Origin');
}
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit();
}

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    exit('Method Not Allowed');
}

$url = filter_var($_GET['url'] ?? '', FILTER_VALIDATE_URL);
$scheme = is_string($url)
    ? strtolower(parse_url($url, PHP_URL_SCHEME) ?? '')
    : '';

if ($url === false || !in_array($scheme, ['http', 'https'], true)) {
    http_response_code(400);
    exit('Invalid image URL');
}

$ch = curl_init($url);

curl_setopt_array($ch, [
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_FOLLOWLOCATION => true,
    CURLOPT_MAXREDIRS => 3,
    CURLOPT_CONNECTTIMEOUT => 5,
    CURLOPT_TIMEOUT => 15,
    CURLOPT_USERAGENT => 'PuRe Image Proxy/1.0',
    CURLOPT_HTTPHEADER => [
        'Accept: image/avif,image/webp,image/png,image/jpeg,*/*;q=0.8'
    ],
]);

$body = curl_exec($ch);
$status = (int) curl_getinfo($ch, CURLINFO_RESPONSE_CODE);
$contentType = (string) curl_getinfo($ch, CURLINFO_CONTENT_TYPE);
$error = curl_error($ch);

curl_close($ch);

if (
    $body === false ||
    $status < 200 ||
    $status >= 300 ||
    $body === ''
) {
    http_response_code(502);
    exit(
        'Unable to fetch image' .
        ($error !== '' ? ': ' . $error : '')
    );
}

if (!str_starts_with(strtolower($contentType), 'image/')) {
    http_response_code(415);
    exit('Remote resource is not an image');
}

header('Content-Type: ' . explode(';', $contentType, 2)[0]);
header('Cache-Control: public, max-age=3600');

echo $body;