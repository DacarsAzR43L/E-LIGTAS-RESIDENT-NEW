<?php
// Assuming you have a MySQL database
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "capst_project_new";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Check if 'category' is set in the GET request
if(isset($_GET['disaster_type'])){
    // Retrieve the category value from the GET request
    $category = $_GET['disaster_type'];

    // Query to get all rows with the specified category
    $sql = "SELECT * FROM guidelines WHERE disaster_type = '$category'";
    $result = $conn->query($sql);

    // Check if there are any rows
    if ($result->num_rows > 0) {
        $data = array();

        // Fetch and output data
        while($row = $result->fetch_assoc()) {
            // Retrieve image data and encode to base64
            $imageData = file_get_contents($row['thumbnail']);
            $base64Image = base64_encode($imageData);

            // Add base64-encoded image to the row data
            $row['thumbnail'] = $base64Image;

            // Add the row to the result data array
            $data[] = $row;
        }

        // Output JSON response
        header('Content-Type: application/json');
        echo json_encode(['data' => $data]);
    } else {
        // Output JSON response for no results
        header('Content-Type: application/json');
        echo json_encode(['message' => 'No results found']);
    }
} else {
    // Output JSON response for missing category parameter
    header('Content-Type: application/json');
    echo json_encode(['error' => 'Category not set in the GET request']);
}

// Close connection
$conn->close();
?>
