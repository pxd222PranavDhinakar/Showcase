<?php
header('Access-Control-Allow-Origin: http://localhost:8000');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Accept');

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit; // Handle CORS preflight
}

// Fetch repository languages
$curl = curl_init();
curl_setopt_array($curl, [
    CURLOPT_URL => "https://api.github.com/repos/pxd222PranavDhinakar/Blog/languages",
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_USERAGENT => 'PHP Application',
    CURLOPT_HTTPHEADER => [
        'Authorization: Bearer ' . getenv('API_TOKEN')
    ]
]);

$response = curl_exec($curl);
$err = curl_error($curl);
curl_close($curl);

$languages = json_decode($response, true);

// Fetch commit history
$curl = curl_init();
curl_setopt_array($curl, [
    CURLOPT_URL => "https://api.github.com/repos/pxd222PranavDhinakar/Blog/commits",
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_USERAGENT => 'PHP Application',
    CURLOPT_HTTPHEADER => [
        'Authorization: Bearer ' . getenv('API_TOKEN')
    ]
]);

$response = curl_exec($curl);
$err = curl_error($curl);
curl_close($curl);

$commits = json_decode($response, true);

header('Content-Type: application/json');

if ($err) {
    echo json_encode(["error" => "cURL Error #:" . $err]);
} else {
    echo json_encode(["languages" => $languages, "commits" => $commits]);
}