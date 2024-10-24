<?php

$db =mysqli_connect("localhost", "root", "", "capst_project_new");

if (!$db) {
    echo "Database Connection Error!".mysql_error();
}


if (isset($_GET['phone_number'])) {


// Get the item name from the request
$phone_number = $_GET['phone_number'];


// Prepare and execute a query to check if the item exists
$stmt = $db->prepare("SELECT * FROM resident_profile WHERE phoneNumber = ?");
$stmt->bind_param("s", $phone_number);
$stmt->execute();
$result = $stmt->get_result();


// Check if the item exists
if ($result->num_rows > 0) {
    // Item exists

    echo json_encode(["status" => "success", "message" => "Item exists."]);
} else {
    // Item does not exist
    echo json_encode(["status" => "error", "message" => "Item does not exist."]);
}

// Close the database connection
$stmt->close();
$db->close();
}

?>
