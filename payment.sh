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

dnf install python3 gcc python3-devel -y &>>$log_file
VALIDATE $? "installing the python "


id roboshop
if [ $? -ne 0 ]
then
 useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$log_file
 VALIDATE $? "creating a payment"
else 
 echo -e "system payment roboshop is present"
fi

mkdir -p /app 
VALIDATE $? "creating app directory"

curl -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>>$log_file
VALIDATE $? "downloading payment"

rm -rf /app/*
cd /app 
unzip /tmp/payment.zip &>>$log_file
VALIDATE $? "unzip the payment file"

pip3 install -r requirements.txt &>>$log_file
VALIDATE $? "installing dependencies"

cp $script_dir/payment.service /etc/systemd/system/payment.service &>>$log_file
VALIDATE $? "copied the payment service"

systemctl daemon-reload &>>$log_file
VALIDATE $? "daemon reload payment "

systemctl enable payment  &>>$log_file
systemctl start payment
VALIDATE $? "start the payment service"
