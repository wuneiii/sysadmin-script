#!/usr/bin/perl -w
# This script fetches data from $rrd, creates a graph of memory
# consumption from oracle statspack history records
#
# call the RRD perl modsule
# use lib qw( /usr/local/rrdtool-1.0.41/lib/perl ../lib/perl );
#
# on windows you might need to set default font envioment variable
# $ENV{"RRD_DEFAULT_FONT"} = "C:\\WINDOWS\\FONTS\\TIMES.TTF";

use RRDs;

my $rrd = "executecount.rrd";
my ($starttime,$endtime,$minvalue,$maxvalue);
my $statfile = "exestats.txt";
my $numline;
my ($timeslot,$value);

$starttime=0;
$endtime=0;
$numline=0;
$timeslot=0;
$value=0;

open(FILE,$statfile);
while(<FILE>)
{
chomp;
($timeslot,$value)=(split(/,/,$_));
if ($numline==0) {
$starttime=$timeslot;
}
#print "Time slot: ${timeslot} value: ${value} \n";
$numline=$numline+1;
}
close(FILE);
$endtime=$timeslot;

# print "starttime at ${starttime} endtime at ${endtime} \n";
my $rracount;
$rracount=$numline+10;

RRDs::create($rrd, "--start", $starttime - 1,"--step",900,"DS:index:GAUGE:900:U:U","RRA:AVERAGE:0.5:1:${rracount}");
my $ERROR = RRDs::error;
print "ERROR unable to create ${rrd} : ${ERROR} \n" if $ERROR;

open(FILE,$statfile);
while(<FILE>)
{
chomp;
($timeslot,$value)=(split(/,/,$_));
RRDs::update ($rrd,"$timeslot:$value");
$ERR=RRDs::error;
print "ERROR while updating $rrd: $ERR\n" if $ERR;
}
close(FILE);

my ($averages,$xsize,$ysize) = RRDs::graph "execute_count.png",
"-title", "Database free memory of large pool",
"-font","DEFAULT:10:",
"-start", "$starttime",
"-end", "$endtime",
"-imgformat","PNG",
"-width=600",
"-height=3000",
"-alt-autoscale",
# "–x-grid","MINUTE:10:HOUR:1:HOUR:4:0:%X",
# "–no-gridfit",
"DEF:index=$rrd:index:AVERAGE",
# "AREA:index#123456″,
"LINE1:index#ff0000:value of free large pool size (M)",
# "–color=FRAME#CCFFFF",
# "–color=CANVAS#CCFFFF",
# "–color=SHADEB#9999CC",
# "–color=BACK#CCCCCC",
"-slope-mode",
"-watermark","made by rrdtool",
"-vertical-label","free large pool size (M)",
"COMMENT: …..What a complex and powerful rrdtool …..",
;

print "Gifsize: ${xsize}x${ysize}\n";
print "Averages: ", (join ", ", @$averages);
