<?php
header('Content-Type: application/json'); // Ensure we're returning JSON


$scriptPaths = [
    'file_search' => '../scripts/search/file_search.sh',
    'file_filter' => '../scripts//search/file_filter.sh',
    'output_formatter' => $baseDir . '../scripts//output/output_formatter.sh',
    'interactive_mode' => $baseDir . '../scripts//interactive/interactive_mode.sh',
    'batch_processing' => $baseDir . '../scripts//batch/batch_processing.sh',
    'file_metadata' => $baseDir . '../scripts//utils/file_metadata.sh',
    'batch_config' => $baseDir . '../scripts/config/batch_config.txt'
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
