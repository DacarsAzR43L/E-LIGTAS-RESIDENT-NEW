<?php

$db = mysqli_connect("localhost", "root", "", "capst_project_new");

if (!$db) {
    die("Database Connection Error: " . mysqli_connect_error());
}

if (isset($_GET['uid']) && isset($_GET['phonenumber'])) {
    $uid = $_GET['uid'];
    $phonenumber = $_GET['phonenumber'];

    // Check if the phoneNumber exists for other uids
    $checkOtherUidsQuery = "SELECT * FROM resident_profile WHERE uid<>'$uid' AND phoneNumber='$phonenumber'";
    $resultOtherUids = mysqli_query($db, $checkOtherUidsQuery);

    if ($resultOtherUids && mysqli_num_rows($resultOtherUids) > 0) {
        $response = ['status' => 'exists_other_uid'];
    } else {
        // Check if phoneNumber exists for the given uid
        $checkQuery = "SELECT * FROM resident_profile WHERE uid='$uid' AND phoneNumber='$phonenumber'";
        $result = mysqli_query($db, $checkQuery);

        if ($result && mysqli_num_rows($result) > 0) {
            $response = ['status' => 'exists_only_this_uid'];
        } else {
            $response = ['status' => 'does_not_exist'];
        }
    }
} else {
    $response = ['status' => 'failed', 'message' => 'Invalid data received.'];
}

// Send JSON response back to Flutter
header('Content-Type: application/json');
echo json_encode($response);

mysqli_close($db);
?>
