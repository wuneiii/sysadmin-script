<?php
/*
	@author: wuneii@gmail.com
	@date  : 2012-07-13
	@desc  : proftpd's passwd file webadmin
	@note  : v0.1


*/
$pwd_file = '/etc/proftpd/passwd';
//$_ftpasswd_bin = '/usr/sbin/ftpasswd';
$_version = 'V0.1';
$_date = '2012-07-13';


$_default_shell ='/usr/sbin/nologin';
$_default_gid = 33;
$_default_uid = 33;


$_action = $_GET['act'];

proftpd_page_header();

if($_action == ''){

      $all_user = proftpd_get_user($pwd_file);
      echo <<<EOF
<script type="text/javascript">
function delete_confirm(){
    if(confirm('Are you sure?')){
        return true;
    }
    return false;
}
</script>
<table width="600px" border="1" align="center">
<tr class="frist">
    <td>user</td>
    <td scope="col">homedir</td>
    <td scope="col">shell</td>
    <td scope="col">op</td>
</tr>

EOF;
foreach($all_user as $user_name => $user_info){
    $shell = $user_info['shell'];
    $homedir = $user_info['homedir'];
    echo <<<EOF
<tr>
    <td scope="col">$user_name</td>
    <td scope="col">$homedir</td>
    <td scope="col">$shell</td>
    <td scope="col">
        <a href="?act=delete&username=$user_name" onclick="return delete_confirm();">delele</a> | 
        <a href="?act=update&username=$user_name">update</a> 
    </td>
</tr>

EOF;

}
    echo <<<EOF
</table>

EOF;
}else if($_action == 'update'){

    $username = $_GET['username'];
    $user_info = proftpd_get_user($pwd_file, $username);
    $homedir = $user_info['homedir'];
      echo <<<EOF
<form action='?act=doupdate' method="post">
<input type="hidden" name="username" value="$username">
<table width="600px" border="1" align="center">
<tr>
    <td class="frist">user</td>
    <td scope="col">$username</td>
</tr>
<tr>
    <td class="frist">password</td>
    <td scope="col"><input type='text' name="password" ></input></td>
</tr>
<tr>
    <td class="frist">homedir</td>
    <td scope="col"><input type='text' name="homedir" value='$homedir'></input></td>
</tr>
<tr>
    <td colspan='2' align='center'><input type="submit" value='submit'></input></td>
</tr>
</form>
</table>
EOF;
}else if($_action == 'doupdate'){

    $username = $_GET['username'];
    $passwd = $_GET['password'];
    $homedir = $_GET['homedir'];
    
    

}else if($_action == 'add'){
      echo <<<EOF
<style type="text/css">
table {border:0px solid #FF0000; font-size:12px; color:#000000;}
table td { border:1px solid #000000; padding:5px;}
.frist{ background-color:#FF9933; color:#FFFFFF; font-weight:bold;}
</style>
<form action='?act=doadd' method="post">
<table width="600px" border="1" align="center">
<tr>
    <td class="frist">username</td>
    <td scope="col"><input type='text' name="username" ></input></td>
</tr>
<tr>
    <td class="frist">password</td>
    <td scope="col"><input type='text' name="password" ></input></td>
</tr>
<tr>
    <td class="frist">homedir</td>
    <td scope="col"><input type='text' name="homedir"></input></td>
</tr>
<tr>
    <td colspan='2' align='center'><input type="submit" value='submit'></input></td>
</tr>
</form>
</table>
EOF;


}else if($_action == 'doadd'){

    $username = $_POST['username'];

    $passwd = $_POST['password'];
    $homedir = $_POST['homedir'];
    if($username == '' || $passwd == ''|| $homedir == ''){
    
        die('Dont blank!die();<a href="?">back</a>');

    }
    $all_user = proftpd_get_user($pwd_file);
    if($all_user[$usernmae] != ''){
        
        die('Username:'.$username.' have exists!die();<a href="?">back</a>');
    
    }   

    $gid = $_default_gid;
    $uid = $_default_uid;
    $shell = $_default_shell;
    if($homedir != '' && !file_exists($homedir)){
        
        $ret = mkdir($homedir,0777,true) && touch($homedir.'/.proftpd.vum') && file_put_contents($homedir.'/.proftpd.vum',time());
        if($ret != true){
            echo 'warning:mkdir faild';
        }
    
    }
    $ret = proftpd_add_user($username,$passwd,$uid,$gid,$homedir,$shell);
    if($ret){
        header('Location:?');
    }else{
        
        die('Add user error!<a href="?">back</a>');
    }

}else if ($_action == 'delete'){

    $username = $_GET['username'];
    if(proftpd_delete_user($pwd_file,$username)){

        header('Location:?');        

    }else{

        die('Delete faild!<a href="?">back</a>');

    }
}
/*
*
* if username == ''  return all user
* if username == some return this user detail info
*
*/
function proftpd_get_user($pwd_file,$username = ''){

    $content = file($pwd_file);
    if(count($content) == 0)
        return array();

    $user_list = array();
    foreach($content as $user){
        $user_info = explode(':',$user);
        $user_list[$user_info[0]]['homedir'] = $user_info[5];
        $user_list[$user_info[0]]['shell'] = $user_info[6];
        if($username != '' && $username == $user_info[0]){
            return array('homedir'=>$user_info[5],'shell'=>$user_info[6]);
        }
    }
    return $user_list;
}
function proftpd_page_header(){
    global $_version;
    echo <<<EOF
<style type="text/css">
table {border:0px solid #FF0000; font-size:12px; color:#000000;font-family: "Courier New", Courier, monospace;}
table td { border:1px solid #000000; padding:5px;}
.frist{ background-color:#FF9933; color:#FFFFFF; font-weight:bold;}
</style>
<table width="600px" border="1" align="center">
<tr class="frist">
    <td><a href="?">Proftpd Virtual User MyAdmin</a></td>
    <td scope="col">$_version</td>
    <td scope="col"></td>
    <td scope="col"><a href="?act=add">add user</a></td>
</tr>
</table>

EOF;
}
function proftpd_delete_user($pwd_file,$username){

    if($username == '')
        return false;
    $content = file($pwd_file);
    if(count($content) == 0)
        return false;
    foreach($content as $i => $user){
        if(strpos($user,$username.':',0) === 0){
            unset($content[$i]);
            break;
        }
    }
    $ret = file_put_contents($pwd_file,join("\n",$content));
    if($ret === false){
        return false;
    }

    return true;
}
function proftpd_evn_det(){

    global $pwd_file;
    if(!is_writable($pwd_file)){
        
        echo 'waring:'.$pwd_file.'catnot write!<br>';        
    
    }

}
function proftpd_add_user($username,$passwd,$uid,$gid,$homedir,$shell){
    global $_ftpasswd_bin;
    global $pwd_file;
    $passwd = proftpd_gen_password($passwd);
    $user = sprintf("%s:%s:%u:%u::%s:%s\n",$username,$passwd,$uid,$gid,$homedir,$shell);
    $ret = file_put_contents($pwd_file,$user,FILE_APPEND);
    if($ret === false){
        return false;
    }
    return true;
    
}

function proftpd_gen_password($passwd){

    if($passwd == '')
        return false;
    $_default_salt = '}#f4ga~g%7hjg4&j(7mk?/!bj30ab-wi=6^7-$^R9F|GK5J#E6WT;IO[JN';
    $md5 = md5($_default_salt);  
    $salt = '$1$'.substr($md5Str, 8, 8);
    return crypt($passwd,$salt);

}
?>
