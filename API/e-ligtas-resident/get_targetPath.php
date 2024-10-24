<?php

$db = mysqli_connect("localhost", "root", "", "capst_project_new");

if (!$db) {
    die("Database Connection Error: " . mysqli_connect_error());
}

if (isset($_GET['uid'])) {
    $uid = $_GET['uid'];

    // Select the targetPath based on uid
    $selectQuery = "SELECT image FROM resident_profile WHERE uid='$uid'";
    $result = mysqli_query($db, $selectQuery);

    if ($result && mysqli_num_rows($result) > 0) {
        $row = mysqli_fetch_assoc($result);
        $targetPath = $row['image'];

        // Send JSON response back to Flutter
        $response = ['success' => true, 'targetPath' => $targetPath];
        header('Content-Type: application/json');
        echo json_encode($response);
    } else {
        // No matching record found
        $response = ['success' => false, 'message' => 'No matching record found.'];
        header('Content-Type: application/json');
        echo json_encode($response);
    }
} else {
    $response = ['success' => false, 'message' => 'Invalid data received.'];
    header('Content-Type: application/json');
    echo json_encode($response);
}

mysqli_close($db);
?>
