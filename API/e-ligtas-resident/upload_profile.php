<?php

$db = mysqli_connect("localhost", "root", "", "capst_project_new");

if (!$db) {
    die("Database Connection Error: " . mysqli_connect_error());
}

if (isset($_POST['name']) && isset($_POST['uid']) &&isset($_POST['address']) &&
  isset($_POST['phonenumber']) && isset($_FILES['image']) ) {

    $name = $_POST['name'];
    $address = $_POST['address'];
    $phonenumber = $_POST['phonenumber'];
    $uid = $_POST['uid'];
    $image = $_FILES['image'];

   
    // Move the uploaded file to a desired directory
    $uploadPath = '../e-ligtas-sector/upload/';
    $imageName = 'image_' . time() . '.jpg';
    $targetPath = $uploadPath . $imageName;

    if (move_uploaded_file($image['tmp_name'], $targetPath)) {

        // Insert data into the user_profile table
        $insertQuery = "INSERT INTO resident_profile (uid, name, address, phoneNumber, image) VALUES ('$uid', '$name','$address','$phonenumber', '$targetPath')";
        
        $result = mysqli_query($db, $insertQuery);

        if ($result) {
            $response = ['success' => true];
        } else {
            $response = ['success' => false, 'message' => 'Failed to insert data.'];
        }
    } else {
        $response = ['success' => false, 'message' => 'Failed to move the uploaded file.'];
    }
} else {
    $response = ['success' => false, 'message' => 'Invalid data received.'];
}

// Send JSON response back to Flutter
header('Content-Type: application/json');
echo json_encode($response);

mysqli_close($db);

?>
