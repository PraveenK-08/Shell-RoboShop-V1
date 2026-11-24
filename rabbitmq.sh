#!/bin/bash
RED='\e[31m'
GREEN='\e[1;32m'
Normal="\e[0m"
user_id=$(id -u)
logs_folder="/var/log/Shell-RoboShop-V1"
logs_file="$logs_folder/$0"

if [ $user_id -ne 0 ]; then
    echo "Please run this script with sudo access.."
    exit 1
fi

mkdir -p $logs_folder

echo " Redis server configuration is started========="
echo "started time = $(date +"%Y%m%d_%H%M%S")"
validate() {
    if [ $1 -eq 0 ]; then 
        echo -e " ${2} is ${GREEN}success$Normal" | tee -a  $logs_file
    
    else
        echo -e " ${2} is ${RED}Failed$Normal"  | tee -a  $logs_file
        exit 1
    
    fi 
}

cp rabbitmq.repo /etc/yum.repos.d &>> $logs_file
validate $? "created rabbitmq repo "

echo "installation started ========"
dnf install erlang rabbitmq-server -y &>> $logs_file
validate $? "install rabbitmq server "

systemctl enable rabbitmq-server &>> $logs_file
validate $? "enable rabbitmq server "

systemctl start rabbitmq-server &>> $logs_file
validate $? "start rabbitmq server "

rabbitmqctl list_users | grep -q roboshop
if [ $? -ne 0 ]; then
   rabbitmqctl add_user roboshop roboshop123 &>> $logs_file
   validate $? "Add rabbitmq user "
else
   echo "user already exist, skipping===="
fi 

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"  &>> $logs_file
validate $? "set permissions to rabbitmq user "

echo "configuration endtime = $(date +"%Y%m%d_%H%M%S")"
echo "time taken : $SECONDS"