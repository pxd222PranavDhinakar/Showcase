<?php
header('Access-Control-Allow-Origin: http://localhost:8000'); // Allow AJAX calls from your Node.js server
header('Content-Type: application/json'); // If you are returning JSON

// Path to the Bash script
$scriptPath = '../Scripts/monitor_resources.sh';

// Check if the script file exists and is executable
if (is_executable($scriptPath)) {
    // Execute the script and capture the output
    $output = shell_exec("bash $scriptPath");
} else {
    $output = "Script not found or not executable";
}

// Display the output (For debugging, you can uncomment the next line to see it on PHP page directly)
// echo "<pre>$output</pre>";

// Send output back to the frontend as JSON
header('Content-Type: application/json');
echo json_encode(['data' => nl2br($output)]);
?>