<?php
$conn = mysqli_connect("localhost", "root", "", "sectors");

if (!$conn) {
    die("Database Connection Error: " . mysqli_connect_error());
}

// Check if 'email' and 'password' are set in $_POST

if (isset($_POST['email']) && isset($_POST['password'])) {
    // Retrieve email and password from Flutter app
    $email = $_POST['email'];
    $providedPassword = $_POST['password'];

    // Perform a query to retrieve the user's information
    $sql = "SELECT * FROM users WHERE email = '$email'";
    $result = $conn->query($sql);

    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();

        // Check if 'encrypted_password' is set in $row
        if (isset($row['password'])) {
            // Verify the provided password against the stored encrypted password
            if (password_verify($providedPassword, $row['password'])) {
                // Passwords match, check the status column
                if ($row['verified'] == 'active') {
                    // User is active, send a success response
                    echo json_encode(["status" => "Login successful", "message" => ""]);
                } else {
                    // User is not active, send an error response with a specific message
                    echo json_encode(["status" => "User account is not verified", "message" => ""]);
                }
            } else {
                // Passwords do not match, send an error response with a specific message
                echo json_encode(["status" => "Password do not match", "message" => ""]);
            }
        } else {
            // Handle the case where 'encrypted_password' is not present in $row
            echo json_encode(["status" => "Database schema issue", "message" => ""]);
        }
    } else {
        // User does not exist, send an error response with a specific message
        echo json_encode(["status" => "User does not Exist", "message" => ""]);
    }
} else {
    // 'email' or 'password' not set in $_POST, send an error response with a specific message
    echo json_encode(["status" => "Email or password not provided", "message" => ""]);
}

$conn->close();
?>
