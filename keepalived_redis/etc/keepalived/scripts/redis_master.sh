#!/bin/bash
REDISCLI="./usr/local/bin/redis-cli -h $1 -p $3" 
ls_date=`date +%Y%m%d`
LOGFILE="/etc/keepalived/logs/keepalived-redis-state_$ls_date.log"
echo "[master]" >> $LOGFILE
date >> $LOGFILE
echo "Being master...." >> $LOGFILE
echo "Run MASTER cmd ..." >> $LOGFILE
$REDISCLI SLAVEOF $2 $3 >> $LOGFILE
sleep 10 #delay 10 s wait data async cancel sync
echo "Run SLAVEOF NO ONE cmd ..." >> $LOGFILE
$REDISCLI SLAVEOF NO ONE >> $LOGFILE
