<?php
header('Access-Control-Allow-Origin: http://localhost:3000'); // Allow AJAX calls from your Node.js server
header('Content-Type: application/json'); // Ensuring the header is set before any output

// Enable error reporting
ini_set('display_errors', 1);
error_reporting(E_ALL);

// Path to the Bash script
$scriptPath = '../Scripts/generate_report.sh';

// Path to the directory you want to generate the report for
$directoryPath = '../Scripts';

// Execute the script and capture the output
$scriptOutput = shell_exec("bash $scriptPath $directoryPath 2>&1");

// Path to the generated report file
$reportPath = '../report.md';

// Check if the report file exists
if (file_exists($reportPath)) {
    // Read the contents of the report file
    $reportContent = file_get_contents($reportPath);
    
    // Send the report content back to the frontend as JSON
    echo json_encode(['data' => $reportContent]);
} else {
    // If the report file doesn't exist, send an error message
    echo json_encode(['error' => 'Report file not found.']);
}

?>
