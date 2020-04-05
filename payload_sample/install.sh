#!/bin/bash

set -euo pipefail
STARTTIME=`date +%s`

echo "Payload install.sh start at: "$STARTTIME | tee -a /root/payload_log_sample.log
#sleep 10
echo "I am a payload sample." | tee -a /root/payload_log_sample.log
#sleep 10

## For CentOS
echo -n "Your system: *** " | tee -a /root/payload_log_sample.log
echo -n "$(cat /etc/system-release)" | tee -a /root/payload_log_sample.log
echo " *** is ready." | tee -a /root/payload_log_sample.log

## For Ubuntu
#echo "****************************************** " | tee -a /root/payload_log_sample.log
#echo "Your lsb_release -a:" | tee -a /root/payload_log_sample.log
#lsb_release -a | tee -a /root/payload_log_sample.log
#echo "****************************************** " | tee -a /root/payload_log_sample.log

#sleep 10
echo "This line goes into payload_install.log"
#sleep 10
echo "This line goes into specified log file" >> /root/payload_log_sample.log
#sleep 10
echo "This line goes into both payload_install.log and specified log file" | tee -a /root/payload_log_sample.log
#sleep 10
ENDTIME=`date +%s`
SPENTTIME=$(($ENDTIME-$STARTTIME))
echo "Payload install.sh end at: "$ENDTIME". Time usage: "$SPENTTIME" seconds" | tee -a /root/payload_log_sample.log
