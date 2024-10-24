<?php

$db = mysqli_connect("localhost", "root", "", "resident");

if (!$db) {
    die("Database Connection Error: " . mysqli_connect_error());
}

if (
    isset($_POST['dateandTime']) &&
    isset($_POST['emergency_type']) &&
    isset($_POST['resident_name']) &&
    isset($_POST['locationName']) &&
    isset($_POST['locationLink']) &&
    isset($_POST['phoneNumber']) &&
    isset($_POST['message']) &&
    isset($_FILES['imageEvidence']) &&
    isset($_POST['status']) &&
    isset($_POST['responder_name']) &&
    isset($_POST['userfrom']) &&
    isset($_FILES['residentProfile'])
) {
    $dateandTime = $_POST['dateandTime'];
    $emergency_type = $_POST['emergency_type'];
    $resident_name = $_POST['resident_name'];
    $locationName = $_POST['locationName'];
    $locationLink = $_POST['locationLink'];
    $phoneNumber = $_POST['phoneNumber'];
    $message = $_POST['message'];
    $status = $_POST['status'];
    $responder_name = $_POST['responder_name'];
    $userfrom = $_POST['userfrom'];

    // Move the uploaded imageEvidence file to a desired directory
    $uploadPath = 'upload/';
    $imageEvidenceFileName = 'evidence_' . time() . '.jpg';
    $targetImageEvidencePath = $uploadPath . $imageEvidenceFileName;

    // Move the uploaded residentProfile file to a desired directory
    $residentProfileFileName = 'profile_' . time() . '.jpg';
    $targetResidentProfilePath = $uploadPath . $residentProfileFileName;

    if (
        move_uploaded_file($_FILES['imageEvidence']['tmp_name'], $targetImageEvidencePath) &&
        move_uploaded_file($_FILES['residentProfile']['tmp_name'], $targetResidentProfilePath)
    ) {

        // Insert data into the active_request table
        $imageEvidence = $targetImageEvidencePath;
        $residentProfile = $targetResidentProfilePath;

        $insertQuery = "INSERT INTO active_reports (dateandTime, emergency_type, resident_name, locationName, locationLink, phoneNumber, message, imageEvidence, status, responder_name, userfrom, residentProfile) VALUES ('$dateandTime', '$emergency_type', '$resident_name', '$locationName', '$locationLink', '$phoneNumber', '$message', '$imageEvidence', '$status', '$responder_name', '$userfrom', '$residentProfile')";

        $result = mysqli_query($db, $insertQuery);

        if ($result) {
            $response = ['success' => true];
        } else {
            $response = ['success' => false, 'message' => 'Failed to insert data.'];
        }
    } else {
        $response = ['success' => false, 'message' => 'Failed to move one or more uploaded files.'];
    }

    // Send JSON response back to Flutter
    header('Content-Type: application/json');
    echo json_encode($response);

    mysqli_close($db);
}
?>
