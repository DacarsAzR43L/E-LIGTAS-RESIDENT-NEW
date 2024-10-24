<?php

$conn = mysqli_connect("localhost", "root", "", "resident");

if (!$conn) {
    die("Database Connection Error: " . mysqli_connect_error());
}

// Check if responder_name is set in the POST request
if (isset($_POST['responder_name'])) {

    // Get the responder name from the POST request
    $responderName = $_POST['responder_name'];

    // Perform SQL query with a WHERE clause to select rows where responder_name is the specified responder name
    $sql = "SELECT report_id, dateandTime, uid, emergency_type, resident_name, locationName, locationLink, phoneNumber, message, imageEvidence, residentProfile FROM active_reports WHERE responder_name = '$responderName'";

    $result = $conn->query($sql);

    // Check if the query was successful
    if ($result === false) {
         die("Error in query: " . $conn->error . " Query: " . $sql);
    }

    // Fetch associative array
    $data = array();

    while ($row = $result->fetch_assoc()) {
        $imageData = file_get_contents($row['imageEvidence']);
        $base64Image1 = base64_encode($imageData);

        $imageResidentProfile = file_get_contents($row['residentProfile']);
        $base64Image2 = base64_encode($imageResidentProfile);

        $row['imageEvidence'] = $base64Image1;
        $row['residentProfile'] = $base64Image2;

        $data[] = $row;
    }

    // Output the data as JSON
    echo json_encode($data);

    // Close connection
    $conn->close();
} else {
    echo "Responder name not provided in the request.";
}
?>
