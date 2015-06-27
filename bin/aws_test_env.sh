#!/bin/bash
date_tenminutesago() {
	echo `date +%Y-%m-%dT%H:%M:%S -d "10 minute ago"`
}
date_now() {
        echo `date +%Y-%m-%dT%H:%M:%S`
}

alias date_begin=date_tenminutesago
alias date_end=date_now

getElbHealthyHostCount() {
        elbIdentifier=$1
        statsMethod=$2
        aws cloudwatch get-metric-statistics --start-time ${date_begin} --end-time ${date_end} --period 60 --namespace 'AWS/ELB' --metric-name 'HealthyHostCount' --statistics $statsMethod --dimensions Name=LoadBalancerName,Value=$elbIdentifier
}
getRdsConnectionCount() {
        rdsIdentifier=$1
        statsMethod=$2
        aws cloudwatch get-metric-statistics --start-time $(date_begin) --end-time $(date_end) --period 3600 --namespace 'AWS/RDS' --metric-name 'DatabaseConnections' --statistics $statsMethod --dimensions Name=DBInstanceIdentifier,Value=$rdsIdentifier
}
