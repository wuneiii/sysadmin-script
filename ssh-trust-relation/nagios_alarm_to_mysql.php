#!/home/serving/php/bin/php
<?php
$mysql_host='127.0.0.1';
$mysql_user='tomato';
$mysql_pass='tomato_pass';
$mysql_db='tomato';

array_shift($argv);
list($al_idc,$al_host,$al_service,$al_type,$al_time,$al_infomation) = $argv;

mysql_connect($mysql_host, $mysql_user, $mysql_pass);
mysql_select_db($mysql_db);

$sql = "insert into nagios_alarm (id,idc,host,service,type,time,infomation) values ('','$al_idc','$al_host','$al_service','$al_type','$al_time','$al_infomation')";

mysql_query($sql);

?>
