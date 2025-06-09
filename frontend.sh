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

dnf module disable nginx -y &>>$log_file
VALIDATE $? "disabling the nginx"

dnf module enable nginx:1.24 -y &>>$log_file
VALIDATE $? "enabling the nginx"

dnf install nginx -y &>>$log_file
VALIDATE $? "installing the nginx"

systemctl enable nginx  &>>$log_file
systemctl start nginx  
VALIDATE $? "starting the nginx"

rm -rf /usr/share/nginx/html/* &>>$log_file
VALIDATE $? "removing the default content in nginx"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$log_file
VALIDATE $? "downloading the frontent content"

cd /usr/share/nginx/html 
unzip /tmp/frontend.zip &>>$log_file
VALIDATE $? "unzipping the content "

rm -rf /etc/nginx/nginx.conf &>>$log_file
VALIDATE $? "removing the default conf in nginx"

cp $script_dir/nginx.conf /etc/nginx/nginx.conf 
VALIDATE $? "copying to this path nginx conf"

systemctl restart nginx 
VALIDATE $? "restarting the nginx "