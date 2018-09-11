#!/bin/bash 
ls_date=`date +%Y%m%d`
LOGFILE=/etc/keepalived/logs/keepalived-redis-state_$ls_date.log 
echo "[stop]" >> $LOGFILE 
date >> $LOGFILE 
