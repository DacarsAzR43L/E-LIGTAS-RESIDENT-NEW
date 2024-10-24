<?php

// Establish the database connection
$db = mysqli_connect("localhost", "root", "", "capst_project_new"); // Replace with your actual database credentials

// Check the connection
if (!$db) {
    die("Connection failed: " . mysqli_connect_error());
}

// Check if the 'uid' parameter is set in the GET request
if (isset($_GET['uid'])) {
    // Sanitize the input to prevent SQL injection
    $uid = mysqli_real_escape_string($db, $_GET['uid']);

    // Query to select rows based on uid and status
    $sql = "SELECT * FROM reports WHERE uid = '$uid' AND status = 1"; 

    // Perform the query
    $result = mysqli_query($db, $sql);

    if ($result) {
        // Fetch the results as an associative array
        $rows = array();
        while ($row = mysqli_fetch_assoc($result)) {
            // Handle multiple images in imageEvidence
            $imagePaths = explode(',', $row['imageEvidence']); // Split by comma
            $base64Images = [];

            foreach ($imagePaths as $imagePath) {
                if (file_exists($imagePath)) {
                    $imageData = file_get_contents($imagePath);
                    $base64Images[] = base64_encode($imageData);
                }
            }

            // Encode the resident profile image
            $imageResidentProfile = file_get_contents($row['residentProfile']);
            $base64ImageResidentProfile = base64_encode($imageResidentProfile);

            // Update the row data
            $row['imageEvidence'] = $base64Images; // Array of base64-encoded images
            $row['residentProfile'] = $base64ImageResidentProfile;

            // Add the row to the result set
            $rows[] = $row;
        }

        // Return the results as JSON
        echo json_encode($rows);
    } else {
        // Return an error message if the query fails
        echo "Error: " . $sql . "<br>" . mysqli_error($db);
    }
} else {
    // Return an error message if 'uid' is not set in the GET request
    echo "Error: 'uid' parameter is missing in the GET request.";
}

// Close the database connection
mysqli_close($db);

?>
