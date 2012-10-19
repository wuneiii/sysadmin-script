#!/usr/bin/perl

use strict;
use Config::General;
use Data::Dumper;
use Socket;
use IO::Socket;
use File::Basename;
use RRDs;
use Date::Format;

$| = 1;
my $_DATA_COLLECT_CYCLE = 20;
my $_IS_TIMEOUT = 0;
our ($data_name,$server_list,$counter_port,$database,  $this_data , $last_data);
our $_debug = 0;


my $config_file = shift || './config';
my $conf = new Config::General($config_file);
my %config = $conf->getall;

$data_name = $config{'config'}{'data_name'};
$counter_port = $config{'config'}{'counter_port'};
$server_list = $config{'server'};
$database = './data/';


local $SIG{ALRM} = sub{
    print "alarm\n" if $_debug;
    $_IS_TIMEOUT = 1;
};
alarm($_DATA_COLLECT_CYCLE);


while(1 == 1){
    if($_IS_TIMEOUT == 0){
        print 'sleep 1'."\n" if $_debug;
        sleep 1;
        next;
    }
    $_IS_TIMEOUT = 0;
    alarm($_DATA_COLLECT_CYCLE);
    
    refresh_graph();
}


sub refresh_graph{

    my ($def, $line);
    
    my $end_time = time();
    my $start_time = $end_time - 43200;

    foreach my $idc (keys %$server_list ){
	
	
	my (@argv_success,@argv_faild) ;
        my $this_idc_server = $server_list -> {$idc};
	my $cnt = 0;
        foreach my $server (keys %$this_idc_server){
            if ($this_idc_server->{$server} == 0){
                next;
            }
	    $cnt ++;
            my $rrd = $database.$server.'.rrd';
	    my $color = get_color();
	    push @argv_success , "DEF:success$cnt=$rrd:success:AVERAGE";
	    push @argv_success , "AREA:success$cnt$color:$server:STACK";
        }
	$cnt = 0;
        foreach my $server (keys %$this_idc_server){
            if ($this_idc_server->{$server} == 0){
                next;
            }
	    $cnt ++;
            my $rrd = $database.$server.'.rrd';
	    if($cnt == 1){
	    push @argv_success , "LINE1:success$cnt#000000";
		}else{
	    push @argv_success , "LINE1:success$cnt#000000::STACK";
	   }
        }
	    push @argv_success , "CDEF:topy=success$cnt,50,+";
	    push @argv_success , "AREA:topy#ffffff::STACK";
	my $cnt = 0;
        foreach my $server (keys %$this_idc_server){
            if ($this_idc_server->{$server} == 0){
                next;
            }
	    $cnt ++;
            my $rrd = $database.$server.'.rrd';
	    my $color = get_color();
	    push @argv_faild , "DEF:faild$cnt=$rrd:faild:AVERAGE";
	    push @argv_faild , "AREA:faild$cnt$color:$server:STACK";
        }

	
    my $t = time2str("%Y-%m-%d %T", time);	
    print "refresh $idc \n" if $_debug;
    RRDs::graph( $idc."_webserver_qps.png",
        "--title", "$idc webserver QPS ( $t )",
        "--font","DEFAULT:12:",
        "--start", $start_time,
        "--end", $end_time,
        "--imgformat","PNG",
        "--width=670",
        "--height=300",
        "--alt-autoscale",
	"--lower-limit=0",
	"--rigid",
	@argv_success,
	"--slope-mode");

    RRDs::graph( $idc."_webserver_faild_qps.png",
        "--title", "$idc webserver faild ( $t )",
        "--font","DEFAULT:12:",
        "--start", $start_time,
        "--end", $end_time,
        "--imgformat","PNG",
        "--width=670",
        "--height=200",
        "--alt-autoscale",
	"--lower-limit=0",
	"--rigid",
	@argv_faild,
	"--slope-mode");

        
        my $ERR=RRDs::error;
        warn "ERROR $ERR\n" if $ERR;
   }
  get_color_reset();

}



my $__color_point = 0;
sub get_color_reset{

	$__color_point = 0;

}
sub get_color{

	my @color = (
		'#CCCC00','#999900','#339900',
		'#66CC33','#CCFFCC','#99CC99',
		'#99FFCC','#66CCCC','#99FFFF',
		'#FFFFCC','#FFCC66','#CC6600',
		'#FF9933','#FF66FF','#CC33FF',
		'#0033CC','#0099FF','#0033FF','#663399');
	if($__color_point == scalar(@color)){
		$__color_point = 0;
	}
	my $ret =$color[$__color_point];
	$__color_point ++;
	return $ret;



}
