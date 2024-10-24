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

// Check if the 'guidelines_id' parameter is set in the GET request
if (isset($_GET['guidelines_id'])) {
    // Sanitize the input to prevent SQL injection
    $guidelines_id = $conn->real_escape_string($_GET['guidelines_id']);

    // Build and execute the SQL query
    $sql = "SELECT * FROM guidelines_after WHERE guidelines_id = '$guidelines_id'";
    $result = $conn->query($sql);

    if ($result->num_rows > 0) {
        // Initialize an empty array to store the data
        $data = array();

        // Fetch and append each row to the data array
        while ($row = $result->fetch_assoc()) {
          
           
             $imageData = file_get_contents($row['image']);
             $base64Image = base64_encode($imageData);
              $row['image'] = $base64Image;

                 $data[] = $row;
        }


        // Echo the data array as JSON
        echo json_encode($data);
    } else {
        echo "No data found for guidelines_id: $guidelines_id";
    }
}

// Close the database connection
$conn->close();

?>
