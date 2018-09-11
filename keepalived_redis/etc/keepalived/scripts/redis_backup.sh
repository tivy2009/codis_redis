#!/bin/bash
REDISCLI="./usr/local/bin/redis-cli" 
ls_date=`date +%Y%m%d`
LOGFILE="/etc/keepalived/logs/keepalived-redis-state_$ls_date.log"
echo "[backup]" >> $LOGFILE
date >> $LOGFILE
echo "Run SLAVEOF cmd ..." >> $LOGFILE
$REDISCLI SLAVEOF $2 $3 >> $LOGFILE 2>&1
sleep 15 #delay 15 s wait data sync exchange role
