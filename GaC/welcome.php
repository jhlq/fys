<html>
<body>

Welcome <?php echo $_POST["name"]; ?><br>
Your email address is: <?php echo $_POST["email"]; ?><br>

<?php
  try
  {
    //open the database
    //$db = new PDO('sqlite:data/dogsDb_PDO.sqlite');
    $db = new PDO('sqlite:data/chat1.sqlite');

    //create the database
    //$db->exec("CREATE TABLE Dogs (Id INTEGER PRIMARY KEY, Breed TEXT, Name TEXT, Age INTEGER)");    
    //$db->exec("CREATE TABLE messages (Id INTEGER PRIMARY KEY, user TEXT, msg TEXT)");    

    //insert some data...
    //$db->exec("INSERT INTO Dogs (Breed, Name, Age) VALUES ('Labrador', 'Tank', 2);".
    //           "INSERT INTO Dogs (Breed, Name, Age) VALUES ('Husky', 'Glacier', 7); " .
    //           "INSERT INTO Dogs (Breed, Name, Age) VALUES ('Golden-Doodle', 'Ellie', 4);");
    #$db->exec("INSERT INTO messages (user,msg) VALUES ('Quin','Welcome to the chatbase!');"."INSERT INTO messages (user,msg) VALUES ('Nicol','Have some love: <3<3<3<3<3');");
    
    print "<table border=1>";
    print "<tr><td>Id</td><td>user</td><td>msg</td></tr>";
    $result = $db->query('SELECT * FROM messages');
    foreach($result as $row){
      print "<tr><td>".$row['Id']."</td>";
      print "<td>".$row['user']."</td>";
      print "<td>".$row['msg']."</td></tr>";
    }
    print "</table>";

    //now output the data to a simple html table...
  /*  print "<table border=1>";
    print "<tr><td>Id</td><td>Breed</td><td>Name</td><td>Age</td></tr>";
    $result = $db->query('SELECT * FROM Dogs');
    foreach($result as $row)
    {
      print "<tr><td>".$row['Id']."</td>";
      print "<td>".$row['Breed']."</td>";
      print "<td>".$row['Name']."</td>";
      print "<td>".$row['Age']."</td></tr>";
    }
    print "</table>";
*/
    // close the database connection
    $db = NULL;
  }
  catch(PDOException $e)
  {
    print 'Exception : '.$e->getMessage();
  }
?>

</body>
</html>
