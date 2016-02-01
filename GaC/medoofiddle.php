<?php
#include 'https://raw.githubusercontent.com/catfan/Medoo/master/medoo.php';
include_once 'medoo.php';
$database = new medoo([
	'database_type' => 'sqlite',
	'database_file' => 'data/emails.db'
]);
$database->insert("people", ["name" => "en","email"=>"en@tva"]);
$datas = $database->select("people", "*");
foreach($datas as $data){	echo "name:" . $data["name"] ."email:" . $data["email"] . "<br/>";}

echo "heart";
?>
