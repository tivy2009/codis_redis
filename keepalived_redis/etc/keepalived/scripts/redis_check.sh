#!/bin/bash
ALIVE=`./usr/local/bin/redis-cli -h $1 -p $2 PING`
ls_date=`date +%Y%m%d`
LOGFILE="/etc/keepalived/logs/keepalived-redis-check_$ls_date.log"
echo "[CHECK]" >> $LOGFILE
date >> $LOGFILE
if [ "$ALIVE" == "PONG" ]; then :
    echo "Success: redis-cli -h $1 -p $2 PING $ALIVE" >> $LOGFILE 2>&1
    exit 0
else
    systemctl start redisd   
    echo "systemctl start redisd ..." >> $LOGFILE
fi

sleep 10

if [ "$ALIVE" == "PONG" ]; then :
    echo "Success: redis-cli -h $1 -p $2 PING $ALIVE" >> $LOGFILE 2>&1
    exit 0
else
    echo "Failed: redis-cli -h $1 -p $2 PING $ALIVE" >> $LOGFILE 2>&1
    exit 1
fi
