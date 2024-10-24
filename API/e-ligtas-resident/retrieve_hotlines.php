<?php

$db = mysqli_connect("localhost", "root", "", "capst_project_new");

if (!$db) {
    die("Database Connection Error: " . mysqli_connect_error());
}
// Check the connection
if ($db->connect_error) {
    die("Connection failed: " . $mysqli->connect_error);
}

// Fetch data from the database
$result = $db->query('SELECT sector_from, hotlines_number FROM emergency_hotlines');

// Check if the query was successful
if (!$result) {
    die("Query failed: " . $db->error);
}

// Fetch data as an associative array
$data = array();
while ($row = $result->fetch_assoc()) {
    $data[] = $row;
}

// Close the MySQLi connection
$db->close();

// Output JSON response
header('Content-Type: application/json');
echo json_encode($data);
