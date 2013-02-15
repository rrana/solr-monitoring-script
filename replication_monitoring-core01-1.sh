#!/bin/bash

#Solr master slave replication lag monitoring script. Compatible with cloudkick custom plugin

#Usage: sh script-name.sh master-ip:port slave-ip:port threshold
#       sh replication_monitoring-core-01-1.sh 192.168.2.4:8080 192.168.2.5:8080 2



if [ $# -lt 2 ]; then
 echo Usage: `basename $0` SolrMasterIP[:port] SolrSlaveIP[:port] [AlertThreshold]
 exit 1
fi

# read command params
MASTER=$1
SLAVE=$2
THRESHOLD=${3:-1}


#Change the url if necessary 
MASTER_INDEX=`wget -qO - http://$1/solr/core-01/admin/replication/index.jsp | grep -Po "(?<=Index Version: )\d+"` 
[ -z "$MASTER_INDEX" ] && echo status err Error reading Master index && exit 2
SLAVE_INDEX=`wget -qO - http://$2/solr/core-01/admin/replication/index.jsp | grep -Po "(?<=Index Version: )\d+"`
[ -z "$SLAVE_INDEX" ] && echo status err Error reading Master index && exit 3
 
# Replication lag calculation
REPLICATION_STATUS=$((MASTER_INDEX - SLAVE_INDEX))

#Test
#echo "REPLICATION_STATUS: $REPLICATION_STATUS  Master-Index: $MASTER_INDEX   Slave-Index: $SLAVE_INDEX    Threshold: $THRESHOLD"


if [ $REPLICATION_STATUS -gt $THRESHOLD ]
then
	echo "status warn Slave ($SLAVE_INDEX) is behind master ($MASTER_INDEX)" && exit 4
else 
	echo "status ok Slave ($SLAVE_INDEX) synched with master ($MASTER_INDEX)"
fi
exit
