<?php
header('Content-Type: application/json'); // Ensure we're returning JSON

// Define the base directory relative to the current script file
$baseDir = '/home/pxd222/public_html/Showcase';  // Adjust according to your server setup

$scriptPaths = [
    'file_search' => $baseDir . '/Scripts/file-management-system/search/file_search.sh',
    'file_filter' => $baseDir . '/Scripts/file-management-system/search/file_filter.sh',
    'output_formatter' => $baseDir . '/Scripts/file-management-system/output/output_formatter.sh',
    'interactive_mode' => $baseDir . '/Scripts/file-management-system/interactive/interactive_mode.sh',
    'batch_processing' => $baseDir . '/Scripts/file-management-system/batch/batch_processing.sh',
    'file_metadata' => $baseDir . '/Scripts/file-management-system/utils/file_metadata.sh',
    'batch_config' => $baseDir . '/Scripts/file-management-system/config/batch_config.txt'
];

$scriptsContent = [];
foreach ($scriptPaths as $key => $path) {
    if (file_exists($path)) {
        $scriptsContent[$key] = htmlspecialchars(file_get_contents($path));
    } else {
        $scriptsContent[$key] = "Error: File not found - " . $path;
    }
}

echo json_encode($scriptsContent);
?>
