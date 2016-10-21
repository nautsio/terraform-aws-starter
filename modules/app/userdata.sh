#!/bin/bash

# Set EC2 instance id
EC2_INSTANCE_ID=$(ec2metadata --instance-id)

# Set EC2 instance local IP
EC2_LOCAL_IP=$(ec2metadata --local-ipv4)

# Set EC2 instance hostname
EC2_HOSTNAME=$(ec2metadata --local-hostname)

#Gather env from tags
ENVIRONMENT=$(aws ec2 describe-tags --filters "Name=resource-id,Values=${EC2_INSTANCE_ID}" "Name=key,Values=env" --region "eu-west-1" --query "Tags[*].Value" --output=text)

#Gather master ips
MASTERS=$(aws ec2 describe-instances --filters "Name=tag:role,Values=master" --query 'Reservations[*].Instances[*].NetworkInterfaces[*].PrivateIpAddress' --region "eu-west-1" --output=text | xargs | sed 's/ /,/g')

#Create formatted zookeeper address string
ZOOKEEPERS="zk://$(echo $MASTERS | sed 's/\,/:2181,/g'):2181/mesos"

#Create formatted consul hosts string
CONSUL_HOSTS="[\"$(echo $MASTERS | sed 's/\,/\"\,\"/g')\"]"

sed -i "s~__ENVIRONMENT_PLACEHOLDER__~$ENVIRONMENT~g" /etc/default/mesos
sed -i "s~__ZOOKEEPERS_PLACEHOLDER__~$ZOOKEEPERS~g" /etc/default/mesos
sed -i "s~__ENVIRONMENT_PLACEHOLDER__~$ENVIRONMENT~g" /etc/default/mesos-slave
sed -i "s~__ZOOKEEPERS_PLACEHOLDER__~$ZOOKEEPERS~g" /etc/default/mesos-slave
sed -i "s~__CONSUL_HOSTS_PLACEHOLDER__~$CONSUL_HOSTS~g" /data/consul/config/00-defaults.json
sed -i "s~__CONSUL_ADVERTISE_ADDR_PLACEHOLDER__~$EC2_LOCAL_IP~g" /data/consul/config/00-defaults.json
sed -i "s~__CONSUL_NODE_NAME_PLACEHOLDER__~$EC2_HOSTNAME~g" /data/consul/config/00-defaults.json
