<?php

// Establish a connection to the MySQL database
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "capst_project_new";

$conn = new mysqli($servername, $username, $password, $dbname);

// Check the connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Check if the 'settings_name' parameter is set in the GET request
if (isset($_GET['settings_name'])) {
    // Sanitize the input to prevent SQL injection
    $settings_name = $conn->real_escape_string($_GET['settings_name']);

    // Build and execute the SQL query
    $sql = "SELECT * FROM settings WHERE settings_name = '$settings_name'";
    $result = $conn->query($sql);

    if ($result) {
        // Fetch and display the data
        $rows = array();
        while ($row = $result->fetch_assoc()) {
            $rows[] = $row;
        }

        // Free the result set
        $result->free();

        // Echo the data as JSON
        echo json_encode($rows);
    } else {
        echo "Error: " . $sql . "<br>" . $conn->error;
    }
}

// Close the database connection
$conn->close();


?>
