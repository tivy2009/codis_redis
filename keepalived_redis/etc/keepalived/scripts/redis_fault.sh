#!/bin/bash 
ls_date=`date +%Y%m%d`
LOGFILE=/etc/keepalived/logs/keepalived-redis-state_$ls_date.log 
echo "[fault]" >> $LOGFILE
date >> $LOGFILE 
