<html>
<body>

Welcome <?php echo $_POST["name"]; ?><br>
Your email address is: <?php echo $_POST["email"]; ?>

<?php 
include_once 'medoo.php';
$database = new medoo([
	'database_type' => 'sqlite',
	'database_file' => 'data/emails.db'
]);
$database->insert("people", ["name" => $_POST["name"],"email"=>$_POST["email"]]);
echo 'Name and email saved in database';
?>

</body>
</html>
