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

echo "enter the mysql password"
read -s Mysql_root_pasw
VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo -e " $2 is ... $G success $N" | tee -a $log_file
    else 
        echo -e " $2 is ... $R failure $N" | tee -a $log_file
    fi
}

dnf install maven -y
VALIDATE $? "installing maven "

id roboshop
if [ $? -ne 0 ]
then
 useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$log_file
 VALIDATE $? "creating a user"
else 
 echo -e "system user roboshop is present"
fi

mkdir /app 
VALIDATE $? "make an app directory"

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip 
VALIDATE $? "download shipping file"

rm -rf /app/*
cd /app 
unzip /tmp/shipping.zip
VALIDATE $? "unzip the user file"

mvn clean package 
VALIDATE $? "packaging the shipping application"
mv target/shipping-1.0.jar shipping.jar 
VALIDATE $? "moving and renaming the jar file"

cp $script_dir/shipping.service /etc/systemd/system/shipping.service
VALIDATE $? "adding shipping service "

systemctl daemon-reload
VALIDATE $? "daemon reload "

systemctl enable shipping 
systemctl start shipping
VALIDATE $? "starting the shipping process"

dnf install mysql -y 
VALIDATE $? "instal mysql into shipping"

mysql -h mysql.devops84.site -u root -p$Mysql_root_pasw -e 'use cities'
if [ $? -ne 0 ]
then 
  mysql -h mysql.devops84.site -uroot -p$Mysql_root_pasw < /app/db/schema.sql.sql 
  mysql -h mysql.devops84.site -uroot -p$Mysql_root_pasw < /app/db/app-user.sql 
  mysql -h mysql.devops84.site -uroot -p$Mysql_root_pasw  < /app/db/master-data.sql
 VALIDATE $? "loading data to mysql"
else
   echo -e "data already present "
fi

systemctl restart shipping
VALIDATE $? "restarting shipping"
