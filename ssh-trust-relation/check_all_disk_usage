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
        echo " alarm if disk urate over 95%"
        echo ""
        support
        exit $STATE_OK
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
                DISK_LIST=`df -P|awk '{print $5}'|sed -e '1d' -e 's/%//'`
                MAX=0
                for i in $DISK_LIST
                do
                        if [[ ${i} -gt ${MAX} ]]
                        then
                                MAX=${i}
                        fi
                done
                test ${MAX} -gt 95 && echo `df -P` && exit $STATE_CRITICAL
                echo 'Max disk urate is '${MAX}
                exit $STATE_OK
                ;;
esac
