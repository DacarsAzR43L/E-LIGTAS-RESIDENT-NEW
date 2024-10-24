<?php

// Replace these credentials with your database information
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

// Get UID from the Flutter app
if (isset($_GET['uid'])){ 
$uid = $_GET['uid'];

// Fetch image data based on UID
$sql = "SELECT image,name,address,phoneNumber FROM resident_profile WHERE uid = '$uid'";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
    $row = $result->fetch_assoc();
    
    $targetPath = $row['image'];
   
     $imageData = file_get_contents($row['image']);
      $base64Image = base64_encode($imageData);


        $row['image'] = $base64Image;
        $row['targetPath'] = $targetPath;

    // Send the image data back to Flutter
      echo json_encode($row);
} else {
    echo "Image not found";
}
}
$conn->close();

?>
