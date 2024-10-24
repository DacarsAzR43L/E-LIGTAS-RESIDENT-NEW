<?php

$conn = mysqli_connect("localhost", "root", "", "resident");

// Check the connection
if (!$conn) {
    die("Database Connection Error: " . mysqli_connect_error());
}

if (isset($_POST['status']) && isset($_POST['responder_name']) && isset($_POST['userfrom']) && isset($_POST['reportId'])) {
    
    // Receive POST parameters
    $status = $_POST['status'];
    $responderName = $_POST['responder_name'];
    $userfrom = $_POST['userfrom'];
  $reportId = intval($_POST['reportId']);


    // Check if the reportId exists
   $checkQuery = "SELECT report_id FROM active_reports WHERE report_id = $reportId";

    $result = $conn->query($checkQuery);

    if ($result && $result->num_rows > 0) {
        // ReportId exists, update the status

        $updateStatusQuery = "UPDATE active_reports SET status = '$status' WHERE report_id = $reportId";


        if ($conn->query($updateStatusQuery)) {
            
            // Status updated successfully, now insert responderName and userfrom
            $insertQuery = "INSERT INTO active_reports (report_id, responder_name, userfrom) VALUES ($reportId, '$responderName', '$userfrom') ON DUPLICATE KEY UPDATE responder_name = VALUES(responder_name), userfrom = VALUES(userfrom)";


            if ($conn->query($insertQuery)) {
                // Successful insertion
                $response = ['success' => true];
            } else {
                // Failed insertion
                $response = ['success' => false, 'message' => 'Failed to insert data after updating status.'];
            }
        } else {
            // Failed to update status
            $response = ['success' => false, 'message' => 'Failed to update status.'];
        }
    } else {
        // ReportId does not exist
        $response = ['success' => false, 'message' => "POST reportId: $reportId"];
    }

    // Send JSON response back to Flutter
    header('Content-Type: application/json');
    echo json_encode($response);

    $conn->close();
}
?>
