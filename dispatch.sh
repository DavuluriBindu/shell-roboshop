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

dnf install golang -y  &>>$log_file
VALIDATE $? "installing golang"

id roboshop
if [ $? -ne 0 ]
then
 useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$log_file
 VALIDATE $? "creating a dispatch"
else 
 echo -e "system dispatch roboshop is present"
fi

mkdir -p /app 
VALIDATE $? "creating app directory"

curl -o /tmp/dispatch.zip https://roboshop-artifacts.s3.amazonaws.com/dispatch-v3.zip &>>$log_file
VALIDATE $? "downloading dispatch"

rm -rf /app/*
cd /app 
unzip /tmp/dispatch.zip &>>$log_file
VALIDATE $? "unzip the dispatch file"

go mod init dispatch &>>$log_file
go get  &>>$log_file
go build &>>$log_file
VALIDATE $? "build the golang"

cp $script_dir/dispatch.service /etc/systemd/system/dispatch.service  &>>$log_file
VALIDATE $? "copied the dispatch service"

systemctl daemon-reload &>>$log_file
VALIDATE $? "daemon reload dispatch "

systemctl enable dispatch  &>>$log_file
systemctl start dispatch
VALIDATE $? "start the dispatch "
