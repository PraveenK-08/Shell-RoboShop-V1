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

dnf module disable redis -y &>> $logs_file
validate $? "Disable redis old version "
dnf module enable redis:7 -y &>> $logs_file
validate $? "Enable redis version 7 version "
echo "installation started ========"
dnf install redis -y &>> $logs_file
validate $? "Install redis"

sed -i -e 's/^bind 127.0.0.1/bind 0.0.0.0/' -e 's/^protected-mode yes/protected-mode no/' /etc/redis/redis.conf
validate $? "Configuration file updated"

systemctl enable redis
systemctl start redis
validate $? "enable and start redis server"

echo "configuration endtime = $(date +"%Y%m%d_%H%M%S")"
echo "time taken : $SECONDS"