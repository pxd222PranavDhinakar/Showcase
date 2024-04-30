<?php
header('Content-Type: application/json');

// Get the current directory path
$currentDir = __DIR__;

// Get an array of all PHP files in the current directory
$phpFiles = array_filter(scandir($currentDir), function($file) {
    return pathinfo($file, PATHINFO_EXTENSION) === 'php';
});

$scripts = array();

// Loop through each PHP file and get its contents
foreach ($phpFiles as $file) {
    $filePath = $currentDir . '/' . $file;
    $fileContents = file_get_contents($filePath);
    $scripts[$file] = array(
        'title' => ucwords(str_replace('.php', '', $file)),
        'content' => $fileContents
    );
}

// Send the scripts as JSON
echo json_encode($scripts);
?>