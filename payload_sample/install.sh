#!/bin/bash

set -euo pipefail
STARTTIME=`date +%s`

echo "Payload install.sh start at: "$STARTTIME | tee -a /root/payload_log_sample.log
#sleep 10
echo "I am a payload sample." | tee -a /root/payload_log_sample.log
#sleep 10
echo "This line goes into payload_install.log"
#sleep 10
echo "And this line goes into specified log file" >> /root/payload_log_sample.log
#sleep 10
echo "And this line goes into both payload_install.log and specified log file" | tee -a /root/payload_log_sample.log
#sleep 10
ENDTIME=`date +%s`
echo "Payload install.sh end at: "$ENDTIME | tee -a /root/payload_log_sample.log
