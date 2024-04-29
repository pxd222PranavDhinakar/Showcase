<?php
header('Access-Control-Allow-Origin: http://localhost:8000'); // Allow AJAX calls from your Node.js server
header('Content-Type: application/json'); // If you are returning JSON

// Path to the Bash script
$scriptPath = 'http://eecslab-22.case.edu/~pxd222/Showcase/scripts/monitor_resources.sh';

// Execute the script and capture the output
$output = shell_exec("bash $scriptPath");

// Display the output (For debugging, you can uncomment the next line to see it on PHP page directly)
// echo "<pre>$output</pre>";

// Send output back to the frontend as JSON
header('Content-Type: application/json');
echo json_encode(['data' => nl2br($output)]);
?>
