<?php
// Establish the database connection
$db = mysqli_connect("localhost", "root", "", "capst_project_new"); // Replace with your actual database credentials

// Check the connection
if (!$db) {
    die("Connection failed: " . mysqli_connect_error());
}

if (isset($_GET['report_id'])) {
 
    $reportId =$_GET['report_id'];

    // First, select the residentProfile and imageEvidence paths based on the report_id
    $sqlSelect = "SELECT residentProfile, imageEvidence FROM reports WHERE report_id = $reportId";
    $result = mysqli_query($db, $sqlSelect);

    if ($result && $row = mysqli_fetch_assoc($result)) {
        // Get the file path
        $imageEvidencePath = $row['imageEvidence'];

        if (file_exists($imageEvidencePath)) {
            unlink($imageEvidencePath);
        }

        // Now, delete the report from the database
        $sqlDelete = "DELETE FROM reports WHERE report_id = $reportId";

        if (mysqli_query($db, $sqlDelete)) {
            echo "Data and associated files removed successfully";
        } else {
            echo "Error removing data from the database: " . mysqli_error($db);
        }
    } else {
        echo "Error fetching data or data not found";
    }
} else {
    // Return an error message if 'report_id' is not set in the GET request
    echo "Error: 'report_id' parameter is missing or not a valid integer in the GET request.";
}

// Close the database connection
mysqli_close($db);
?>
