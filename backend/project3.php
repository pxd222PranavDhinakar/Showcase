<?php
header('Access-Control-Allow-Origin: http://localhost:3000'); // Adjust if your front-end is hosted elsewhere
header('Content-Type: application/json'); // Setting the correct header for JSON output

// Enable error reporting for debugging - remove this in production
ini_set('display_errors', 1);
error_reporting(E_ALL);

// Define the base directory and script paths
$baseDir = '/Users/pranavdhinakar/Documents/Blog';  // Adjust according to your server setup
$scriptPaths = [
    'generate_report' => $baseDir . '/Scripts/generate_report.sh',
];
$reportPath = $baseDir . '/report.md';  // Location of the report file

// Check if the action is to load scripts or generate the report
$action = $_GET['action'] ?? 'load';  // Default action is to load scripts

if ($action == 'load') {
    // Load and send script contents
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
    // Generate the report and send its contents
    $output = shell_exec("bash " . $scriptPaths['generate_report'] . " 2>&1");

    // Check if the report file exists and send its contents
    if (file_exists($reportPath)) {
        $reportContent = file_get_contents($reportPath);
        echo json_encode(['data' => $reportContent]);
    } else {
        echo json_encode(['error' => 'Report file not found.']);
    }
}
?>
