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

id roboshop
if [ $? -ne 0 ]
then
 useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$log_file
 VALIDATE $? "creating a user"
else 
 echo -e "system user roboshop is present"
fi

mkdir -p /app 
VALIDATE $? "creating app directory"

curl -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip &>>$log_file
VALIDATE $? "downloading cart"

rm -rf /app/*
cd /app 
unzip /tmp/cart.zip &>>$log_file
VALIDATE $? "unzip the cart file"

npm install  &>>$log_file
VALIDATE $? "download the dependency"

cp $script_dir/cart.service /etc/systemd/system/cart.service
VALIDATE $? "copied the cart service file"

systemctl daemon-reload &>>$log_file
systemctl enable cart  &>>$log_file
systemctl start cart
VALIDATE $? "start the cart service"

