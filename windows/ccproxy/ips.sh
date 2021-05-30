#!/bin/bash
UserNO=`cat ip.txt | wc -l`
echo 
echo [System] >Accinfo
echo UserCount=$UserNO >>Accinfo
echo AuthModel=1 >>Accinfo
echo AuthType=2 >>Accinfo
echo WebFilterCount=0 >>Accinfo
echo TimeScheduleCount=0 >>Accinfo
while read line
    do
    ipaddress=$(echo $line | awk -F ' ' '{print $1}')
    user=$(echo $line | awk -F ' ' '{print $3}')
    echo [$user] >>Accinfo
    echo UserName=$user >>Accinfo
    echo Password=877951949951896877 >>Accinfo
    echo MACAddress= >>Accinfo
    echo IPAddressLow=255.255.255.255 >>Accinfo
    echo IPAddressHigh=255.255.255.255 >>Accinfo
    echo ServiceMask=254 >>Accinfo
    echo MaxConn=-1 >>Accinfo
    echo BandWidth=-1 >>Accinfo
    echo BandWidth2=-1 >>Accinfo
    echo WebFilter=-1 >>Accinfo
    echo TimeSchedule=-1 >>Accinfo
    echo EnableUserPassword=1 >>Accinfo
    echo EnableIPAddress=0 >>Accinfo
    echo EnableMACAddress=0 >>Accinfo
    echo Enable=1 >>Accinfo
    echo BelongsGroup=0 >>Accinfo
    echo BelongsGroupName= >>Accinfo
    echo IsGroup=0 >>Accinfo
    echo AutoDisable=0 >>Accinfo
    echo DisableDateTime=2020-12-23 12:03:50 >>Accinfo
    echo EnableLeftTime=0 >>Accinfo
    echo EnableBandwidthQuota=0 >>Accinfo
    echo BandwidthQuota=0 >>Accinfo
    echo BandwidthQuotaPeriod=1 >>Accinfo
    echo OutgoingIP=$ipaddress >>Accinfo
    done < ip.txt

