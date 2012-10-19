#!/usr/bin/perl

use strict;
use Config::General;
use Data::Dumper;
use LWP::UserAgent;
use File::Basename;
use RRDs;
use Date::Format;


$| = 1;
my $_DATA_COLLECT_CYCLE = 5;#s
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
    $_IS_TIMEOUT = 1;
};
alarm($_DATA_COLLECT_CYCLE);


while(1 == 1){
    if($_IS_TIMEOUT == 0){
	print "sleep 1 \n" if $_debug;
        sleep 1;next;
    }
    $_IS_TIMEOUT = 0;
    alarm($_DATA_COLLECT_CYCLE);
    
    do_something();
}

exit;

sub do_something{
    print "collect start\n" if $_debug;
    
    foreach my $idc (keys %$server_list ){

    my $this_idc_server = $server_list -> {$idc};
    foreach my $server (keys %$this_idc_server){

        if ($this_idc_server->{$server} == 0){
            next;
        }
        my $now = time();
        my $data = get_counters_data($server, $counter_port);
	if($data == '-1'){
		next;
	}
        my @data = $data =~ /\b(?:avg_latency)\s+([\d\.]+)/g;
        
	my $ui_avg_time = $data[0];
	print $ui_avg_time;

        RRDs::update($database.$server.'.rrd','--template=ui_avg_time',"$now:$ui_avg_time");
        my $ERR=RRDs::error;
        warn "ERROR while updating $server.'rrd': $ERR\n" if $ERR;
        
    }

   }	
   print "collect over\n" if $_debug;
}


sub create_ui_avg_time_rrd_file{
        
        my $start_time = time();

            foreach my $idc (keys %$server_list ){

            my $this_idc_server = $server_list -> {$idc};
            foreach my $server (keys %$this_idc_server){
                my $file_name = $database.$server.'.rrd';
                RRDs::create($file_name,"--start", $start_time - 1,"--step",5,"DS:ui_avg_time:GAUGE:10:0:10","RRA:AVERAGE:0.5:1:1607000"); #3 month   
            }
        }
    return;
}


sub get_counters_data{

	my ($server,$port) = @_;
	my $ua = LWP::UserAgent->new;
	$ua->agent("curl/7.19.7");
	$ua->timeout(0.2);
	my $req = HTTP::Request ->new(GET=>"http://$server:$port/counters");
	my $res = $ua -> request($req);
	if($res->is_success){
		warn "get counters success[$server:$port]\n" if $_debug;
		return $res->content;
	}else{
		warn 'get conters error'.$res->status_line;
		return -1;
	}
}

