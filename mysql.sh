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

echo " mongodb server configuration is started========="
echo "started time = $(date +"%Y%m%d_%H%M%S")"
validate() {
    if [ $1 -eq 0 ]; then 
        echo -e " ${2} is ${GREEN}success$Normal" | tee -a  $logs_file
    
    else
        echo -e " ${2} is ${RED}Failed$Normal"  | tee -a  $logs_file
        exit 1
    
    fi 
}

dnf module enable mysql:8.4 -y &>> $logs_file
validate $? "Enable mysql:8.4 "
echo "installation started ========"
dnf install mysql-server -y  &>> $logs_file
validate $? "install mysql server " 

systemctl enable mysqld &>> $logs_file
validate $? "enable mysqld service"

systemctl start mysqld  &>> $logs_file
validate $? "start mysql "


mysql_secure_installation --set-root-pass RoboShop@1 
validate $? "mysql user creation "

echo "configuration endtime = $(date +"%Y%m%d_%H%M%S")"
echo "time taken : $SECONDS"

