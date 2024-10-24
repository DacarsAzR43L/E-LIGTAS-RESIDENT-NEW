<?php 

$db =mysql_connect("localhost", "root", "", "capst_project_new");

if (!$db) {
	echo "Database Connection Error!".mysql_error();
}