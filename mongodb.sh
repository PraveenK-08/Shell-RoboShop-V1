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
cp mongo.repo /etc/yum.repos.d &>> $logs_file
validate $? "creating repo file" 

dnf install mongodb-org -y  &>> $logs_file
validate $? "Installing mongodb"

systemctl enable mongod &>> $logs_file
validate $? "package enabled  "
systemctl start mongod &>> $logs_file
validate $? "package started "

sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf &>> $logs_file
validate $? "Configuration update "

systemctl restart mongod &>> $logs_file
validate $? "package restarted "

echo "configuration endtime = $(date +"%Y%m%d_%H%M%S")"
echo "time taken : $SECONDS"