<?php 

$db =mysqli_connect("localhost", "root", "", "capst_project_new");

if (!$db) {
	echo "Database Connection Error!".mysql_error();
}




if (isset($_POST['email']) ||isset($_POST['uid'])) {

 $uid = $_POST['uid'];
 $email = $_POST['email'];



$token = md5(rand(1111,9999));


$insert = $db ->query("INSERT INTO login(uid, email)
	VALUES('".$uid."','".$email."')");

if ($insert) {

	$last_insertId = mysqli_insert_id($db);

		$url = 'http://'.$_SERVER['SERVER_NAME'].'/e-ligtas-resident/verify.php?id='.$last_insertId. '&token=' .$token;

		echo json_decode($url);
	}	


}




	