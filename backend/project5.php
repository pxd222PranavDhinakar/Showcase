<?php
header('Access-Control-Allow-Origin: http://localhost:3000'); // Adjust if your front-end is hosted elsewhere
header('Content-Type: application/json'); // Setting the correct header for JSON output

// Enable error reporting for debugging - remove this in production
ini_set('display_errors', 1);
error_reporting(E_ALL);

// Define the base directory and script paths
$baseDir = '/Users/pranavdhinakar/Documents/Blog';  // Adjust according to your server setup
$scriptPath = $baseDir . '/Scripts/asm_analysis.awk';
$pointerSPath = $baseDir . '/C/pointer.s';

// Check if the action is to load scripts or run the analysis
$action = $_GET['action'] ?? 'load';  // Default action is to load scripts

if ($action == 'load') {
    // Load and send script contents
    $scriptContent = file_exists($scriptPath) ? htmlspecialchars(file_get_contents($scriptPath)) : "Error: File not found - " . $scriptPath;
    $pointerSContent = file_exists($pointerSPath) ? htmlspecialchars(file_get_contents($pointerSPath)) : "Error: File not found - " . $pointerSPath;
    echo json_encode(['script' => $scriptContent, 'pointerS' => $pointerSContent]);
} else {
    // Run the AWK script and send the output
    $output = shell_exec("awk -f " . $scriptPath . " " . $pointerSPath . " 2>&1");
    echo json_encode(['output' => $output]);
}
?>