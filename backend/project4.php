<?php
header('Access-Control-Allow-Origin: *'); // Modify accordingly for production
header('Content-Type: application/json'); // Send back JSON data

$repo = "pxd222PranavDhinakar/Videos";
$path = "";  // Path within the repository, if your videos are in the root this stays empty

// GitHub API URL to list contents of a directory
$url = "https://api.github.com/repos/$repo/contents/$path";

// Setup curl
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
curl_setopt($ch, CURLOPT_USERAGENT, 'Custom User Agent String');
curl_setopt($ch, CURLOPT_HTTPHEADER, array(
    'Authorization: token '
));

$result = curl_exec($ch);
curl_close($ch);

// Decode JSON response
$files = json_decode($result);

$videos = [];

if (is_array($files)) {
    foreach ($files as $file) {
        if ($file->type == "file" && pathinfo($file->name, PATHINFO_EXTENSION) === 'mp4') {
            array_push($videos, [
                'name' => $file->name,
                'url' => $file->download_url
            ]);
        }
    }
}

echo json_encode($videos);
?>
