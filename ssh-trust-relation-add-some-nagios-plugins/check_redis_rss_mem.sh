#!/bin/bash


STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3
STATE_DEPENDENT=4

if [[ $# != 3 ]]
then
        echo 'error: parameters error'
        exit $STATE_CRITICAL
fi

_hostname=$1
_port=$2
_th=$3



redis_cli=/home/serving/nagios/libexec/redis-cli

if [[ ! -f ${redis_cli} ]]
then
        echo "error:$redis_cli is not exists"
        exit $STATE_CRITICAL
fi

_rss_used=`${redis_cli} -h ${_hostname} -p ${_port} info|grep used_memory_rss|sed -e 's/used_memory_rss:\|\s//g'`
echo "used_memory_rss:${_rss_used};threshold is $3"

if [[  ${_rss_used} -gt $3 ]]
then
        exit $STATE_CRITICAL
else
        exit $STATE_OK
fi
