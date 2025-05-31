#!/bin/bash

AMI_ID=ami-09c813fb71547fc4f
SG_ID=sg-0897c394fc2d256af
Instance=("mongodb" "cart" "catalogue" "mysql" "frontend" "payment" "shipping" "redis" "dispatch" "user" "rabbitmq")
Zone_Id=Z04547231YPUT2HMMPAFC
Domain_Name="devops84.site"

for instance in $@
do

done