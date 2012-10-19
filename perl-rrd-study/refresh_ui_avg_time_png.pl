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
our $_debug = 1;


my $config_file = shift || './ui_config';
my $conf = new Config::General($config_file);
my %config = $conf->getall;

$data_name = $config{'config'}{'data_name'};
$counter_port = $config{'config'}{'counter_port'};
$server_list = $config{'server'};
$database = './data_ui_total/';


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
	
	
	my (@argv) ;
        my $this_idc_server = $server_list -> {$idc};
	my $cnt = 0;
        foreach my $server (keys %$this_idc_server){
            if ($this_idc_server->{$server} == 0){
                next;
            }
	    $cnt ++;
            my $rrd = $database.$server.'.rrd';
	    my $color = get_color();
	    push @argv , "DEF:ui_avg_time$cnt=$rrd:ui_avg_time:AVERAGE";
	    push @argv , "LINE1:ui_avg_time$cnt$color:$server";
        }

	
    my $t = time2str("%Y-%m-%d %T", time);	
    print "refresh $idc \n" if $_debug;
    RRDs::graph( $idc."_".$data_name.".png",
        "--title", "$idc UI Average Time Per Request ( $t )",
        "--font","DEFAULT:12:",
        "--start", $start_time,
        "--end", $end_time,
        "--imgformat","PNG",
        "--width=670",
        "--height=280",
        "--alt-autoscale",
	"--lower-limit=0",
	"--rigid",
	@argv,
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
