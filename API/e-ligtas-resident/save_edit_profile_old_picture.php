<?php

$db = mysqli_connect("localhost", "root", "", "capst_project_new");

if (!$db) {
    die("Database Connection Error: " . mysqli_connect_error());
}

if (isset($_POST['name']) && isset($_POST['uid']) && isset($_POST['address']) &&
    isset($_POST['phonenumber'])) {

    $name = $_POST['name'];
    $address = $_POST['address'];
    $phonenumber = $_POST['phonenumber'];
    $uid = $_POST['uid'];

    // Update data in the user_profile table without changing the image path
    $updateQuery = "UPDATE resident_profile SET name='$name', address='$address', phoneNumber='$phonenumber' WHERE uid='$uid'";
    $result = mysqli_query($db, $updateQuery);

    if ($result) {
        $response = ['success' => true];
    } else {
        $response = ['success' => false, 'message' => 'Failed to update data.'];
    }
} else {
    $response = ['success' => false, 'message' => 'Invalid data received.'];
}

// Send JSON response back to Flutter
header('Content-Type: application/json');
echo json_encode($response);

mysqli_close($db);
?>
