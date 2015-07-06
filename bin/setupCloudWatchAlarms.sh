#!/bin/bash
# This shell helps to setup formatted alarms for both prod/staging system. 
# Note that this shell does create or update alarms for us, no deletions.
#

getEC2InstanceIdByName() {
	ec2InstanceName=$1
	aws ec2 describe-instances --filter "Name=tag:Name,Values=${ec2InstanceName}" | grep InstanceId | grep -oE "i-([0-9a-z]+)"
}

putEC2Alarms() {
	alarmSubscriber=$1
	alarmPrefix=$2
	alarmName=$3
	ec2NodeName=$4
	environment=$5
	ec2InstanceId=`getEC2InstanceIdByName $ec2NodeName`
	aws cloudwatch put-metric-alarm --alarm-name ${alarmPrefix}-EC2-${alarmName}-CPUUtilization --alarm-description "Alarm when EC2 CPU exceeds 75 percent" --metric-name CPUUtilization --namespace AWS/EC2 --statistic Average --period 300 --threshold 75 --comparison-operator GreaterThanThreshold --evaluation-periods 1 --alarm-actions ${alarmSubscriber} --unit Percent --dimensions  Name=InstanceId,Value=${ec2InstanceId} 
	aws cloudwatch put-metric-alarm --alarm-name ${alarmPrefix}-EC2-${alarmName}-JVMMemoryUsage --alarm-description "Alarm when EC2 JVM.MemoryUsage total.used exceeds 1.5G" --metric-name "JVM.MemoryUsage" --namespace "Gaia-SM App" --statistic Average --period 300 --threshold 1610612736 --comparison-operator GreaterThanThreshold --evaluation-periods 1 --alarm-actions ${alarmSubscriber} --unit None --dimensions Name=type,Value=gauge Name=category,Value=total.used Name=machine,Value=${ec2NodeName} Name=environment,Value=${environment}
}

putRDSAlarms() {
	alarmSubscriber=$1
	alarmPrefix=$2
	rdsId=$3
	aws cloudwatch put-metric-alarm --alarm-name ${alarmPrefix}-RDS-CPUUtilization --alarm-description "Alarm when RDS CPU exceeds 75 percent" --metric-name CPUUtilization --namespace AWS/RDS --statistic Average --period 300 --threshold 75 --comparison-operator GreaterThanThreshold --evaluation-periods 1 --alarm-actions ${alarmSubscriber} --unit Percent --dimensions  Name=DBInstanceIdentifier,Value=${rdsId} 
	aws cloudwatch put-metric-alarm --alarm-name ${alarmPrefix}-RDS-ReadLatency --alarm-description "Alarm when RDS read latency over 5 seconds" --metric-name ReadLatency --namespace AWS/RDS --statistic Average --period 60 --threshold 5 --comparison-operator GreaterThanOrEqualToThreshold --evaluation-periods 1 --alarm-actions ${alarmSubscriber} --unit Seconds --dimensions  Name=DBInstanceIdentifier,Value=${rdsId} 
	aws cloudwatch put-metric-alarm --alarm-name ${alarmPrefix}-RDS-WriteLatency --alarm-description "Alarm when RDS write latency over 5 seconds" --metric-name WriteLatency --namespace AWS/RDS --statistic Average --period 60 --threshold 5 --comparison-operator GreaterThanOrEqualToThreshold --evaluation-periods 1 --alarm-actions ${alarmSubscriber} --unit Seconds --dimensions  Name=DBInstanceIdentifier,Value=${rdsId} 
	aws cloudwatch put-metric-alarm --alarm-name ${alarmPrefix}-RDS-FreeStorageSpace --alarm-description "Alarm when RDS left space less than 10G" --metric-name FreeStorageSpace --namespace AWS/RDS --statistic Average --period 60 --threshold 10737418240 --comparison-operator LessThanThreshold --evaluation-periods 1 --alarm-actions ${alarmSubscriber} --unit Bytes --dimensions  Name=DBInstanceIdentifier,Value=${rdsId} 
}

putELBAlarms() {
	alarmSubscriber=$1
	alarmPrefix=$2
	alarmName=$3
	elbName=$4
	aws cloudwatch put-metric-alarm --alarm-name ${alarmPrefix}-ELB-${alarmName}-Latency --alarm-description "Alarm when ELB latency exceeds 10 seconds" --metric-name Latency --namespace AWS/ELB --statistic Average --period 300 --threshold 10 --comparison-operator GreaterThanThreshold --evaluation-periods 1 --alarm-actions ${alarmSubscriber} --unit Seconds --dimensions  Name=LoadBalancerName,Value=${elbName}
	aws cloudwatch put-metric-alarm --alarm-name ${alarmPrefix}-ELB-${alarmName}-HealthyHostCount --alarm-description "Alarm when ELB healtyHostCount less than 1" --metric-name HealthyHostCount --namespace AWS/ELB --statistic Minimum --period 300 --threshold 1 --comparison-operator LessThanThreshold --evaluation-periods 1 --alarm-actions ${alarmSubscriber} --unit Count --dimensions  Name=LoadBalancerName,Value=${elbName} 
	aws cloudwatch put-metric-alarm --alarm-name ${alarmPrefix}-ELB-${alarmName}-UnHealthyHostCount --alarm-description "Alarm when ELB UnHealthyHostCount greater than 0" --metric-name UnHealthyHostCount --namespace AWS/ELB --statistic Maximum --period 300 --threshold 1 --comparison-operator GreaterThanOrEqualToThreshold --evaluation-periods 1 --alarm-actions ${alarmSubscriber} --unit Count --dimensions  Name=LoadBalancerName,Value=${elbName}
}

#Setup alarms for GaiaSM-Prod stack
putProdAlarms() {
	SUBSCRIBER="arn:aws:sns:us-east-1:805787733156:Gaia-Prod-Admin"
	ALARM_PREFIX=GaiaSM-Prod
	
	putELBAlarms $SUBSCRIBER $ALARM_PREFIX Primary GaiaSM-Prod-ELB1
	putELBAlarms $SUBSCRIBER $ALARM_PREFIX Secondary GaiaSM-Prod-ELB2
	
	putEC2Alarms $SUBSCRIBER $ALARM_PREFIX Node1 GaiaSM-Prod-Node1-us-east-1a Prod
	putEC2Alarms $SUBSCRIBER $ALARM_PREFIX Node2 GaiaSM-Prod-Node2-us-east-1d Prod
	
	putRDSAlarms $SUBSCRIBER $ALARM_PREFIX gaiasm-production	
}

#Setup alarms for GaiaSM-Prod stack
putStagingAlarms() {
	SUBSCRIBER="arn:aws:sns:us-east-1:805787733156:Gaia-Staging-Admin"
	ALARM_PREFIX=GaiaSM-Staging
	
	putELBAlarms $SUBSCRIBER $ALARM_PREFIX Primary GaiaSM-Staging-ELB1
	putELBAlarms $SUBSCRIBER $ALARM_PREFIX Secondary GaiaSM-Staging-ELB2
	
	putEC2Alarms $SUBSCRIBER $ALARM_PREFIX Node1 GaiaSM-Staging-Node1-us-east-1a Staging
	putEC2Alarms $SUBSCRIBER $ALARM_PREFIX Node2 GaiaSM-Staging-Node2-us-east-1d Staging
	
	putRDSAlarms $SUBSCRIBER $ALARM_PREFIX gaiastagingdb
}

putProdAlarms
putStagingAlarms

