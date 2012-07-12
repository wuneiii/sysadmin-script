#!/bin/bash

umask 0022
alias initpass="echo 'sysinitABCD@ZJM13F' |passwd root --stdin"
export EDITOR="/usr/bin/vim"
local host=`hostname`
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
