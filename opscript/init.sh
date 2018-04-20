#!/bin/bash

umask 0022
alias initpass="echo 'chushimima' |passwd root --stdin"
export EDITOR="/usr/bin/vim"
host=`hostname`
export PS1="\[\e]2;\u@${host}\a\]\[\e[01;36m\]\u\[\e[01;35m\]@\[\e[01;33m\]${host}\[\e[00m\]:\[\e[01;34m\]\w\$\[\e[00m\] "
#export PS1="\[\e]2;\u@${host}\a\]\[\e[01;36m\]\u\[\e[01;35m\]@\[\e[01;31m\]${host}\[\e[00m\]:\[\e[01;34m\]\w\$\[\e[00m\] "
#export PS1="\[\e]2;\u@${host}\a\]\[\e[01;36m\]\u\[\e[01;35m\]@\[\e[01;32m\]${host}\[\e[00m\]:\[\e[01;34m\]\w\$\[\e[00m\] "


file=server.list
function lh(){

    _server=$1
    _tag=$2
    if [[ -z ${_server} &&  -z  ${_tag} ]] 
    then    
        sed -e 's/=.*$//' ${file} 
    else    
        sed -n -e "/${_server}.*${_tag}/ s/=.*$// p" ${file} 
    fi 

}
function go(){ 
    _server=$1 
    _tag=$2 
    server=`lh ${_server} ${_tag}`
    server_num=`echo ${server}|sed 's/ /\n/g' | wc -l` 
    if [[ ${server_num} == 1 ]] 
    then    
        ssh `id -un`@${server} 
    else    
        echo ${server}|sed 's/ /\n/g' 
    fi 
 
} 
function fsh(){

    _tag=$1
    _cmd=$2
    if [[ $# == 1 ]]
    then
        lh ${_tag}
    else

    for server in `lh ${_tag}`
    do
        echo -e "\033[40;33;1m${server}\033[0m" 
        ssh `id -un`@${server} "${_cmd}"
    done

    fi
}

function finfo() {
    fsh "$1" 'echo CPU: $( cat /proc/cpuinfo | grep "model name" | cut -d: -f2 | uniq); echo $(cat /proc/cpuinfo | grep processor | 
wc -l) processor $(cat /proc/cpuinfo | grep -e "physical id" | sort | uniq | wc -l) physical $(cat /proc/cpuinfo | grep "cpu cores" 
| head -n1 | awk "{print \$4}")core/physical $(cat /proc/cpuinfo | grep "siblings" | head -n1 | awk "{print \$3}")siblings/physical;
dmidecode | grep -4 "System Information" |grep -E "(Manufacturer:|Product Name:)" | awk -F: "{print \$2}" | head -n2 | tr -d "\n" ; 
echo ; dmidecode | grep -6 "Memory Device" | grep -v Mapp | grep -v Range | grep -v Installed | grep -v Enabled | grep Size | grep M
B | uniq -c | awk "{print \$1*\$3/1024,\"GB\",\$1,\"x\",\$3,\$4}"'
}


function cdop() {
    local user=`/usr/bin/id -nu`
    local date=`date +%Y%m%d`
    if [ "$user" = "root" ]; then
        mkdir -p /root/opdir/$date && cd /root/opdir/$date/
    else
        mkdir -p /home/$user/opdir/$date && cd /home/$user/opdir/$date/
    fi
}
