#!/bin/bash
date_onehourago() {
	echo `date +%Y-%m-%dT%H:%M:%S -d  "1 hour ago"`
}
date_now() {
        echo `date +%Y-%m-%dT%H:%M:%S`
}

alias date_begin=date_onehourago
alias date_end=date_now

getElbHealthyHostCount() {
        elbIdentifier=$1
        statsMethod=$2
        aws cloudwatch get-metric-statistics --start-time ${date_begin} --end-time ${date_end} --period 3600 --namespace 'AWS/ELB' --metric-name 'HealthyHostCount' --statistics $statsMethod --dimensions Name=LoadBalancerName,Value=$elbIdentifier
}
getRdsConnectionCount() {
        rdsIdentifier=$1
        statsMethod=$2
        aws cloudwatch get-metric-statistics --start-time $(date_begin) --end-time $(date_end) --period 3600 --namespace 'AWS/RDS' --metric-name 'DatabaseConnections' --statistics Minimum --dimensions Name=DBInstanceIdentifier,Value=$rdsIdentifier
}

