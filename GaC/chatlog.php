<html>
<body>

<h1>Chatlog</h1>

<?php
  try
  {
    $db = new PDO('sqlite:data/chat1.sqlite');

  print "<table border=1>";
    print "<tr><td>Id</td><td>user</td><td>msg</td></tr>";
    $result = $db->query('SELECT * FROM messages');
    foreach($result as $row){
      print "<tr><td>".$row['Id']."</td>";
      print "<td>".$row['user']."</td>";
      print "<td>".$row['msg']."</td></tr>";
    }
    print "</table>";

    $db = NULL;
  }
  catch(PDOException $e)
  {
    print 'Exception : '.$e->getMessage();
  }
?>

</body>
</html>
