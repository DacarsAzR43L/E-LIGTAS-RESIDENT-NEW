<?php

// Database connection
$db = mysqli_connect("localhost", "root", "", "capst_project_new");

if (!$db) {
    die(json_encode(['success' => false, 'message' => 'Database Connection Error: ' . mysqli_connect_error()]));
}

// Check if required data is set
$requiredFields = [
    'dateTime', 'uid', 'emergency_type', 'resident_name', 
    'locationName', 'locationLink', 'phoneNumber', 
    'message', 'residentProfile', 'status', 'SectorName'
];

foreach ($requiredFields as $field) {
    if (!isset($_POST[$field])) {
        echo json_encode(['success' => false, 'message' => "Missing required field: $field"]);
        exit;
    }
}

if (!isset($_FILES['imageEvidence'])) {
    echo json_encode(['success' => false, 'message' => "Image evidence is required."]);
    exit;
}

// Assigning POST data to variables
$dateTime = $_POST['dateTime'];
$uid = $_POST['uid'];
$emergency_type = $_POST['emergency_type'];
$resident_name = $_POST['resident_name'];
$locationName = $_POST['locationName'];
$locationLink = $_POST['locationLink'];
$phoneNumber = $_POST['phoneNumber'];
$message = $_POST['message'];
$residentProfile = $_POST['residentProfile'];
$status = $_POST['status'];
$sectorName = $_POST['SectorName'];

// Upload configuration
$uploadDir = '../e-ligtas-sector/upload/';
$imagePaths = []; // Array to store the paths of uploaded images

// Handle multiple file uploads
foreach ($_FILES['imageEvidence']['tmp_name'] as $index => $tmpName) {
    $imageName = 'image_' . time() . "_$index.webp"; // Save the image with a timestamp and index to avoid duplicates
    $targetPath = $uploadDir . $imageName;

    // Move the uploaded file
    if (move_uploaded_file($tmpName, $targetPath)) {
        $imagePaths[] = $targetPath; // Add the image path to the array
    } else {
        echo json_encode(['success' => false, 'message' => "Failed to upload image $index."]);
        exit;
    }
}

// Convert the array of image paths to a comma-separated string
$imagePathsString = implode(',', $imagePaths);

// Insert data into the active_reports table
$insertQuery = "INSERT INTO reports 
    (dateandTime, uid, emergency_type, resident_name, locationName, locationLink, phoneNumber, message, imageEvidence, status, residentProfile, sectorName) 
    VALUES 
    ('$dateTime', '$uid', '$emergency_type', '$resident_name', '$locationName', '$locationLink', '$phoneNumber', '$message', '$imagePathsString', '$status', '$residentProfile', '$sectorName')";

$result = mysqli_query($db, $insertQuery);

if ($result) {
    $response = ['success' => true, 'message' => 'Report submitted successfully.'];
} else {
    $response = ['success' => false, 'message' => 'Failed to insert data into the database.'];
}

// Send JSON response back to the client
header('Content-Type: application/json');
echo json_encode($response);

// Close the database connection
mysqli_close($db);

?>
