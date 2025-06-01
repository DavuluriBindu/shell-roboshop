#!/bin/bash

AMI_ID=ami-09c813fb71547fc4f
SG_ID=sg-0897c394fc2d256af
Instance=("mongodb" "cart" "catalogue" "mysql" "frontend" "payment" "shipping" "redis" "dispatch" "user" "rabbitmq")
Zone_Id=Z04547231YPUT2HMMPAFC
Domain_Name="devops84.site"

for instance in ${Instance[@]}
do
  Instance_ID=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t2.micro --security-group-ids sg-0897c394fc2d256af --tag-specifications "ResourceType=instance,Tags=[{Key=Name, Value=$instance}]" --query "Instances[0].InstanceId" --output text)

  if [ $instance != "frontend" ]
  then 
  Ip=$(aws ec2 describe-instances --instance-ids $Instance_ID --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)
  else
  Ip=$(aws ec2 describe-instances --instance-ids $Instance_ID --query "Reservations[0].Instances[0].publicIpAddress" --output text)
  echo $Ip
  fi
  echo $instance Ip adress : $Ip
  

done