#!/bin/bash
RED='\e[31m'
GREEN='\e[1;32m'
Normal="\e[0m"

_id=$(id -u)
logs_folder="/var/log/Shell-RoboShop-V1"
logs_file="$logs_folder/$0"
script_path=$(dirname $(realpath ${0}))
domain_name=teram.store

if [ $user_id -ne 0 ]; then
    echo "Please run this script with sudo access.."
    exit 1
fi

mkdir -p $logs_folder


echo " cart server configuration is started========="
echo "started time = $(date +"%Y%m%d_%H%M%S")"
validate() {
    if [ $1 -eq 0 ]; then 
        echo -e " ${2} is ${GREEN}success$Normal" | tee -a  $logs_file
    
    else
        echo -e " ${2} is ${RED}Failed$Normal"  | tee -a  $logs_file
        exit 1
    
    fi 
}

dnf module enable maven:3.9 -y &>> $logs_file
validate $? "Enable maven3.9 "

echo "[INFO] installing maven and java packages"
dnf install maven java-25-openjdk-devel -y &>> $logs_file
validate $? " Maven and Java Installation"

