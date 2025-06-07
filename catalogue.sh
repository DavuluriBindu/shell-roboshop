#!/bin/bash

userid=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
logs_folder="/var/log/shellscript-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
log_file="$logs_folder/$SCRIPT_NAME.log"
script_dir=$PWD

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

dnf module disable nodejs -y &>>$log_file
VALIDATE $? "disabling the nodejs"

dnf module enable nodejs:20 -y &>>$log_file
VALIDATE $? "enable the nodejs:20"

dnf install nodejs -y &>>$log_file
VALIDATE $? "installing the nodejs"

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$log_file
VALIDATE $? "creating a user"

mkdir /app 
VALIDATE $? "creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$log_file
VALIDATE $? "downloading catalogue"

cd /app 
unzip /tmp/catalogue.zip &>>$log_file
VALIDATE $? "unzip the catalogue file"

npm install  &>>$log_file
VALIDATE $? "download the dependency"

cp $script_dir/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "copied the catalogue service file"

systemctl daemon-reload &>>$log_file
systemctl enable catalogue  &>>$log_file
systemctl start catalogue
VALIDATE $? "start the catalogue service"

cp $script_dir/mongo.repo /etc/yum.repos.d/mongodb.repo
VALIDATE $? "coping mongo repo file"

dnf install mongodb-mongosh -y &>>$log_file
mongosh --host mongodb.devops84s.site </app/db/master-data.js &>>$log_file
