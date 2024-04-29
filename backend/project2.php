<?php
header('Content-Type: application/json'); // Ensure we're returning JSON

$baseDir = __DIR__ . '/../scripts/file-management-system';  // Adjust the path as necessary

$scriptPaths = [
    'file_search' => $baseDir . '/search/file_search.sh',
    'file_filter' => $baseDir . '/search/file_filter.sh',
    'output_formatter' => $baseDir . '/output/output_formatter.sh',
    'interactive_mode' => $baseDir . '/interactive/interactive_mode.sh',
    'batch_processing' => $baseDir . '/batch/batch_processing.sh',
    'file_metadata' => $baseDir . '/utils/file_metadata.sh',
    'batch_config' => $baseDir . '/config/batch_config.txt'
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
