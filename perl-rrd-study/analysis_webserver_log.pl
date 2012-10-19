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


my $config_file = shift || './config';
my $conf = new Config::General($config_file);
my %config = $conf->getall;

$data_name = $config{'config'}{'data_name'};
$counter_port = $config{'config'}{'counter_port'};
$server_list = $config{'server'};
$database = './data/';


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
        my @data = $data =~ /\b(?:search_failed|search_success)\s+(\d+)/g;
        
        $this_data->{$server}->{'success'} = $data[1];
        $this_data->{$server}->{'faild'} = $data[0];

        my $success = $this_data->{$server}->{'success'} - $last_data->{$server}->{'success'};
        my $faild = $this_data->{$server}->{'faild'} - $last_data->{$server}->{'faild'};
       
	$success = $success / 5;
	$faild = $faild / 5;

        RRDs::update($database.$server.'.rrd','--template=success:faild',"$now:$success:$faild");
        my $ERR=RRDs::error;
        warn "ERROR while updating $server.'rrd': $ERR\n" if $ERR;
        print "Write RRD file "."$database.$server.'.rrd'.$now:$success:$faild\n" if $_debug;
        
    }

   }	
   $last_data = $this_data;
   $this_data = undef;
   print "collect over\n" if $_debug;
}


sub create_webserver_rrd_file{
        
        my $start_time = time();

            foreach my $idc (keys %$server_list ){

            my $this_idc_server = $server_list -> {$idc};
            foreach my $server (keys %$this_idc_server){
                my $file_name = $database.$server.'.rrd';
                #print $file_name;
                # 5s一个点，1年数据精度不变
                RRDs::create($file_name,"--start", $start_time - 1,"--step",5,"DS:success:GAUGE:10:0:100000","DS:faild:GAUGE:10:0:10000","RRA:AVERAGE:0.5:1:6307200");    
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

