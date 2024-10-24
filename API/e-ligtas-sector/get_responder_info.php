<?php



$conn = mysqli_connect("localhost", "root", "", "sectors");
// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

if(isset($_POST['email'])){
// Fetching email from Flutter POST request
$email = $_POST['email'];

// Sanitize and validate email input
$email = $conn->real_escape_string($email);

// SQL query to fetch data based on email
$sql = "SELECT responder_name, userfrom FROM users WHERE email = '$email'";

$result = $conn->query($sql);

if ($result->num_rows > 0) {
    // Output data of each row
    while ($row = $result->fetch_assoc()) {
        echo json_encode($row);
    }
} else {
    echo "0 results";
}

// Close connection
$conn->close();
}
?>
