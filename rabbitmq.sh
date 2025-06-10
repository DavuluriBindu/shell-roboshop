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

echo "enter the rabbitmq password"
read -s Rabbitmq_pasw

VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo -e " $2 is ... $G success $N" | tee -a $log_file
    else 
        echo -e " $2 is ... $R failure $N" | tee -a $log_file
    fi
}

cp $script_dir/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>>$log_file
VALIDATE $? "copying the repo of rabbitmq"

dnf install rabbitmq-server -y &>>$log_file
VALIDATE $? "installing the rabbitmq"

systemctl enable rabbitmq-server &>>$log_file
VALIDATE $? "enabling the rabbitmq"
systemctl start rabbitmq-server &>>$log_file
VALIDATE $? "starting the rabbitmq"

rabbitmqctl add_user roboshop $Rabbitmq_pasw
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"