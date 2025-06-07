#!/bin/bash

userid=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
logs_folder="/var/log/shellscript-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
log_file="$logs_folder/$SCRIPT_NAME.log"

mkdir -p $logs_folder
echo "script started executing at:$(date)" | tee -a $log_file

if [ $userid -ne 0 ]
then 
     echo -e "$R error:: please run the script with root user $N" | tee -a $log_file
     exit 1
else
    echo "you are running with root user" | tee -a $log_file
fi
VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo -e " $2 is ... $G success $N" | tee -a $log_file
    else 
        echo -e " $2 is ... $R failure $N" | tee -a $log_file
    fi
}

cp mongo.repo /etc/yum.repos.d/mongodb.repo
VALIDATE $? " copying the mongo file " &>>$log_file

dnf install mongodb-org -y 
VALIDATE $? "intalling mongodb server" &>>$log_file

systemctl enable mongod
VALIDATE $? "enabling mongodb server" &>>$log_file
  
systemctl start mongod 
VALIDATE $? "starting the mongodb server" &>>$log_file

sed -i "s/127.0.0.1/0.0.0.0/g" /etc/mongod.conf
VALIDATE $?  " replacing the port " &>>$log_file

systemctl restart mongod
VALIDATE $? "restarted the mongodb server" &>>$log_file