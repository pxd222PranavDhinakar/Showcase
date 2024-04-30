<?php
header('Access-Control-Allow-Origin: http://localhost:3000');
header('Content-Type: application/json');
ini_set('display_errors', 1);
error_reporting(E_ALL);

$baseDir = '/home/pxd222/public_html/Showcase';
$scriptPaths = [
    'generate_report' => $baseDir . '/Scripts/generate_report.sh',
];
$reportPath = $baseDir . '/report.md';
$action = $_GET['action'] ?? 'load';

if ($action == 'load') {
    $scriptsContent = [];
    foreach ($scriptPaths as $key => $path) {
        if (file_exists($path)) {
            $scriptsContent[$key] = htmlspecialchars(file_get_contents($path));
        } else {
            $scriptsContent[$key] = "Error: File not found - " . $path;
        }
    }
    echo json_encode($scriptsContent);
} else {
    $input = '/home/pxd222/public_html/Showcase/Scripts';
    $descriptorspec = [
        0 => ["pipe", "r"],
        1 => ["pipe", "w"],
        2 => ["pipe", "w"]
    ];
    $command = "bash " . $scriptPaths['generate_report'] . " " . escapeshellarg($input);
    $process = proc_open($command, $descriptorspec, $pipes);

    if (is_resource($process)) {
        fclose($pipes[0]);
        $output = stream_get_contents($pipes[1]);
        fclose($pipes[1]);
        $error = stream_get_contents($pipes[2]);
        fclose($pipes[2]);
        $returnValue = proc_close($process);

        if ($returnValue === 0) {
            if (file_exists($reportPath)) {
                $reportContent = file_get_contents($reportPath);
                echo json_encode(['data' => $reportContent]);
            } else {
                echo json_encode(['error' => 'Report file not found.']);
            }
        } else {
            // If there's an error executing the script, send the contents of report.md
            if (file_exists($reportPath)) {
                $reportContent = file_get_contents($reportPath);
                echo json_encode(['data' => $reportContent]);
            } else {
                echo json_encode(['error' => 'Error executing script: ' . $error]);
            }
        }
    } else {
        echo json_encode(['error' => 'Failed to open process.']);
    }
}
?>