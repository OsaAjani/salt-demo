<?php
	$host = '192.168.56.150';
	$dbname = 'server_app';
	$user = 'root';
	$password = 'root';
	$bdd = new PDO('mysql:host=' . $host . ';dbname=' . $dbname, $user, $password);
	$bdd->exec("SET CHARACTER SET utf8");

	$req = $bdd->query("select @@hostname as hostname");

	$database_hostname = $req->fetch()['hostname'];
	$server_hostname = gethostname();

	$query = 'INSERT INTO hello(server_hostname, database_hostname, at) VALUES(:server_hostname, @@hostname, NOW())';
	$params = ['server_hostname' => $server_hostname];
	$req = $bdd->prepare($query);
	$req->execute($params);

	$query = 'SELECT * FROM hello';
	$req = $bdd->prepare($query);
	$req->execute();
	$hellos = $req->fetchAll();
?>
<h1>Sarah Connor? Nice to meet you, I'm <i><?php echo gethostname(); ?></i>!</h1>
<h2>Here is my friend <u><?php echo $hostname; ?></u>, an incredible database of mine.</h2>
<br/>
<h3>I know you, you have already meet all thoses peoples :</h3>
<?php foreach ($hellos as $hello) { ?>
	<?php echo $hello['server_hostname'] . ' & ' . $hello['database_hostname'] . ' at ' . $hello['at']; ?><br/>
<?php } ?>
