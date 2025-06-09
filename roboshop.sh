#!/bin/bash

AMI_ID=ami-09c813fb71547fc4f
SG_ID=sg-0897c394fc2d256af
Instance=("mongodb" "cart" "catalogue" "mysql" "frontend" "payment" "shipping" "redis" "dispatch" "user" "rabbitmq")
Zone_Id=Z04547231YPUT2HMMPAFC
Domain_Name="devops84.site"

for instance in $@
do
   INSTANCE_ID=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t3.micro --security-group-ids sg-0897c394fc2d256af --tag-specifications "ResourceType=instance,Tags=[{Key=Name, Value=$instance}]" --query "Instances[0].InstanceId" --output text)
    if [ $instance != "frontend" ]
    then
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)
        Record_name="$instance.$Domain_Name"
    else
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
        Record_name="$Domain_Name"
    fi
    echo "$instance IP address: $IP"
    aws route53 change-resource-record-sets \
  --hosted-zone-id $Zone_Id \
  --change-batch '
  {
    "Comment": "Creating a record set for cognito endpoint"
    ,"Changes": [{
    "Action"              : "UPSERT"
    ,"ResourceRecordSet"  : {
        "Name"              : "'$Record_name'"
        ,"Type"             : "A"
        ,"TTL"              : 1
        ,"ResourceRecords"  :cd  [{
            "Value"         : "'$IP'"
        }]
     }
    }]
  }'
  

done