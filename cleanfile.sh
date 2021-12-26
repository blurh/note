#!/bin/bash 
# 2021-12-26
# 用于清理指定目录下格式形如 *-2021-12-01-21.log 的文件
# 超出指定大小会进行清理, 至指定阈值止
# 如果单个日志已经超过了阈值, 则发送告警, 人工介入处理
  
threshold="50" # 单位 G
logPath="/data/logs/xxx"
alertHost="http://192.168.50.10:9093"

thresholdKb=$(awk -v threshold=${threshold} 'BEGIN{print threshold * 1024 * 1024}')

function Log() {
    msg="$*"
    echo "[$(date +%F\ %T)]: ${msg}"
}

function sendAlertMsg() {
    checkfileResult=$1
    startTime=$(date +%F\T%T\.000+08:00)
    endTime=$(date +%F\T%T\.000+08:00 -d "+30 min")
    instance=$(ip addr | perl -lne 'print $1 if /inet ((?:\d+\.){3}\d+).* eth0/')
    Log "node ${instance} file ${checkfileResult} greather then ${threshold}G"
    curl -X POST -H "Content-Type: application/json" -d "[{ 
      \"labels\": {
        \"alertname\": \"file size too big\",
        \"instance\": \"${instance}\"
      },
      \"annotations\": {
        \"description\": \"node ${instance} file ${checkfileResult} greather then ${threshold}G\"
      },
      \"startsAt\": \"${startTime}\", 
      \"endsAt\": \"${endTime}\"
    }]" ${alertHost}/api/v2/alerts
}

function checkFileSize() {
    checkfileResult=$(find ${logPath}/ -type f -size +${threshold}G 2> /dev/null | head -1)
    if [ -n "${checkfileResult}" ]; then
        sendAlertMsg ${checkfileResult}
        exit
    fi
}

function gtThreshold() {
    echo "$1 ${thresholdKb}" | awk '{if($1>=$2){print "true"}else{print "false"}}'
}

function delOldLogFile() {
    logSize=$(du -s ${logPath} | awk '{print $1}')
    if [ "$(gtThreshold ${logSize})" == "true" ]; then
        filename=$(find ${logPath}/*/ -type f -name "*.log" | grep -P '\d{4}(\-\d{2}){3}.log' | sort -t / -k6,6 | head -1)
        Log "log size: ${logSize} greather then threshold: ${thresholdKb}, delete ${filename}"
        rm -f ${filename}
        delOldLogFile
    else 
        Log "log szie: ${logSize} less then threshold: ${thresholdKb}, exit"
    fi
}

function delEmptyDir() {
    find ${logPath} -type d -empty -delete
}

if [ "$0" == "${BASH_SOURCE[0]}" ]; then
    cd ${logPath}
    checkFileSize
    delOldLogFile
    delEmptyDir
fi

