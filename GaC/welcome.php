<html>
<body>

Welcome <?php echo $_POST["name"]; ?><br>
Your email address is: <?php echo $_POST["email"]; ?><br>

<?php 
#setup db in sqlite3 with: create table people(name text, email text);
include_once 'medoo.php';
$database = new medoo([
	'database_type' => 'sqlite',
	'database_file' => 'data/emails.db'
]);
$arr=["name" => $_POST["name"],"email"=>$_POST["email"]];
echo $arr["name"];
$database->insert("people", $arr);
echo 'Name and email saved in database';
?>

</body>
</html>
