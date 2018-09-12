#!/bin/bash
basepath=$(cd `dirname $0`; pwd)
ALIVE=`/usr/local/bin/redis-cli -h $1 -p $2 info replication | grep role | awk -F: '{print $2}' | awk 'gsub(/^ *| *$|\r$/,"")'`
ls_date=`date +%Y%m%d`
LOGFILE="/etc/keepalived/logs/keepalived-redis-check_$ls_date.log"
echo "[CHECK]" >> $LOGFILE
date >> $LOGFILE
MASTER=false
if [ "$ALIVE" == "master" ] || [ "$ALIVE" == "slave" ]; then :
    echo "Success: redis-cli -h $1 -p $2 info replication $ALIVE" >> $LOGFILE 2>&1
    for i in `ip addr show dev $3 up | grep "inet " | awk '{print $2}' | awk -F/ '{print $1}' | awk 'gsub(/^ *| *$|\r$/,"")'`;  
    do  
        if [ "$i" == $4 ]; then :
            MASTER=true 
	    break
        fi
    done 

    if [[ ("$MASTER" == true) && ("$ALIVE" == 'master') ]] || [[ ("$MASTER" == false) && ("$ALIVE" == 'slave') ]]; then :
	echo "keepalived and redis status is ok; redis role is $ALIVE." >> $LOGFILE 2>&1
	exit 0
    else
        echo "keepalived and redis status is error,current keepalived master is $MASTER, redis role is $ALIVE." >> $LOGFILE 2>&1
        tmp_state_file=redis_state.tmp
        if [ ! -f "$basepath/$tmp_state_file" ];then
            echo `date +%s` > $basepath/$tmp_state_file 2>&1
            if [[ "$MASTER" == true ]]; then :
                echo "redis role change to master $1 $5 $2" >> $LOGFILE 2>&1
                ./redis_master.sh $1 $5 $2
            elif [[ "$MASTER" == false ]]; then :
                echo "redis role change to backup $1 $5 $2" >> $LOGFILE 2>&1
                ./redis_backup.sh $1 $5 $2
            fi
            exit 0
        else
            echo "exists $basepath/$tmp_state_file file." >> $LOGFILE 2>&1
            a=`stat -c %Y $basepath/$tmp_state_file`
            b=`date +%s`
            if [ $[ $b - $a ] -gt 120 ];then
                echo "delete file:$basepath/$tmp_state_file" >> $LOGFILE 2>&1
                rm -rf $basepath/$tmp_state_file
            fi
            exit 1
        fi
    fi 
else
    echo "Failed: redis-cli -h $1 -p $2 info replication $ALIVE" >> $LOGFILE 2>&1
    tmp_file=redis_check.tmp
    if [ ! -f "$basepath/$tmp_file" ];then
        echo `date +%s` > $basepath/$tmp_file 2>&1
    	echo "try to restart redisd..." >> $LOGFILE 2>&1
    	systemctl restart redisd
    	echo "restart redisd complete......" >> $LOGFILE 2>&1
        sleep 30
    else
        echo "exists $basepath/$tmp_file file." >> $LOGFILE 2>&1
        a=`stat -c %Y $basepath/$tmp_file`
        b=`date +%s`
        if [ $[ $b - $a ] -gt 120 ];then
            echo "delete file:$basepath/$tmp_file" >> $LOGFILE 2>&1
            rm -rf $basepath/$tmp_file
        fi
        exit 1
    fi
fi

if [ "$ALIVE" == "master" ] || [ "$ALIVE" == "slave" ]; then :
    echo "Success: redis-cli -h $1 -p $2 info replication $ALIVE" >> $LOGFILE 2>&1
    for i in `ip addr show dev $3 up | grep "inet " | awk '{print $2}' | awk -F/ '{print $1}' | awk 'gsub(/^ *| *$|\r$/,"")'`;  
    do  
        if [ "$i" == $4 ]; then :
            MASTER=true 
	    break
        fi
    done 

    if [[ ("$MASTER" == true) && ("$ALIVE" == 'master') ]] || [[ ("$MASTER" == false) && ("$ALIVE" == 'slave') ]]; then :
	echo "keepalived and redis status is ok; redis role is $ALIVE." >> $LOGFILE 2>&1
	exit 0
    else
        echo "keepalived and redis status is error;current keepalived master is $MASTER, redis role is $ALIVE." >> $LOGFILE 2>&1
	exit 1
    fi 

else
    echo "Failed: redis-cli -h $1 -p $2 info replication $ALIVE" >> $LOGFILE 2>&1
    exit 1
fi

