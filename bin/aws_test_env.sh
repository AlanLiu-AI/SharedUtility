#!/bin/bash
date_tenminutesago() {
        echo `date +%Y-%m-%dT%H:%M:%S -d "10 minute ago"`
}
date_fiveminutesago() {
        echo `date +%Y-%m-%dT%H:%M:%S -d "5 minute ago"`
}
date_twominutesago() {
        echo `date +%Y-%m-%dT%H:%M:%S -d "2 minute ago"`
}
date_oneminuteafter() {
        echo `date +%Y-%m-%dT%H:%M:%S -d "1 minute"`
}
date_now() {
        echo `date +%Y-%m-%dT%H:%M:%S`
}

getEC2InstanceIdByName() {
        ec2InstanceName=$1
        aws ec2 describe-instances --filter "Name=tag:Name,Values=${ec2InstanceName}" | grep InstanceId | grep -oE "i-([0-9a-z]+)"
}

getEC2PrivateDNSByName() {
        ec2InstanceName=$1
        aws ec2 describe-instances --filter "Name=tag:Name,Values=${ec2InstanceName}" | grep PrivateDnsName | head -n 1 | grep -oP "ip-(.*).ec2.internal"
}

getElbHealthyHostCount() {
        elbIdentifier=$1
        statsMethod=$2
        CMD="aws cloudwatch get-metric-statistics --start-time $(date_twominutesago) --end-time $(date_oneminuteafter) --period 60 --namespace 'AWS/ELB' --metric-name 'HealthyHostCount' --statistics $statsMethod --dimensions Name=LoadBalancerName,Value=$elbIdentifier"
        echo $CMD; eval $CMD
}
getRdsConnectionCount() {
        rdsIdentifier=$1
        statsMethod=$2
        CMD="aws cloudwatch get-metric-statistics --start-time $(date_tenminutesago) --end-time $(date_oneminuteafter) --period 60 --namespace 'AWS/RDS' --metric-name 'DatabaseConnections' --statistics $statsMethod --dimensions Name=DBInstanceIdentifier,Value=$rdsIdentifier"
        echo $CMD; eval $CMD
}
