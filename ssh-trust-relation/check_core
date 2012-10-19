#! /bin/sh

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

PROGNAME=`basename $0`
PROGPATH=`echo $0 | sed -e 's,[\\/][^\\/][^\\/]*$,,'`
REVISION="0.0.1"

. $PROGPATH/utils.sh


print_usage() {
        echo "Usage: $PROGNAME" 
}

print_help() {
        print_revision $PROGNAME $REVISION
        echo ""
        print_usage
        echo ""
        echo "Check core.* file in some dir"
        echo ""
        support
        exit $STATE_OK
}

BUSSINESS_PATH='root_server middle_server0 middle_server1 middle_server2 middle_server3 middle_server4 leaf_server ui_server web_server'
CORE_LIST=''
HAVE_CORE=0

###
# @name : fine_core
# @return: 0 no core 1 have core
# @return: if return 1 ;$CORE_LIST will be set
##
function find_core(){
        bus_dir="/home/serving/$1/bin";
        test ! -d ${bus_dir} && return 0;
        find_result=`find ${bus_dir} -name 'core.*'`
        CORE_LIST=${CORE_LIST}`echo -e ${find_result}`
        if [[ ! -z ${CORE_LIST} ]]
        then
                HAVE_CORE=1
        fi

}
function get_core_info(){
        core_list=$1
        test -z ${core_list} && return;
        info=''
        for core in ${core_list}
        do
                info=${info}"  "`file ${core}`
        done
        echo ${info};

}
case "$1" in
        --help)
                print_help
                exit $STATE_OK
                ;;
        -h)
                print_help
                exit $STATE_OK
                ;;
        --version)
                print_revision $PROGNAME $REVISION
                exit $STATE_OK
                ;;
        -V)
                print_revision $PROGNAME $REVISION
                exit $STATE_OK
                ;;
        *)
                for DIR in ${BUSSINESS_PATH}
                do
                        find_core ${DIR}
                done

                if [[ ${HAVE_CORE} == 1 ]];
                then
                        get_core_info ${CORE_LIST};
                        exit $STATE_WARNING;
                else
                        echo 'congratulation!no core!'
                        exit $STATE_OK
                fi
                ;;
esac
