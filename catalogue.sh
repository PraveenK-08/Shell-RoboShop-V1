#!/bin/bash
RED='\e[31m'
GREEN='\e[1;32m'
Normal="\e[0m"
user_id=$(id -u)
logs_folder="/var/log/Shell-RoboShop-V1"
logs_file="$logs_folder/$0"
domain_name=teram.store

if [ $user_id -ne 0 ]; then
    echo "Please run this script with sudo access.."
    exit 1
fi

mkdir -p $logs_folder

echo " catalogue server configuration is started========="
echo "started time = $(date +"%Y%m%d_%H%M%S")"
validate() {
    if [ $1 -eq 0 ]; then 
        echo -e " ${2} is ${GREEN}success$Normal" | tee -a  $logs_file
    
    else
        echo -e " ${2} is ${RED}Failed$Normal"  | tee -a  $logs_file
        exit 1
    
    fi 
}

dnf module disable nodejs -y
validate $? "nodejs old version disabled"

dnf module enable nodejs:24 -y
validate $? "nodejs version:24 enabled" 

echo "[info]installation started=============="
dnf install nodejs -y
validate $? "installing nodejs package "

useradd --system --shell /sbin/nologin --home /app "roboshop user creation" roboshop
validate $? "creating system user "

mkdir /app
validate $? "app directory created"

curl -L -o /tmp/catalogue.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/catalogue-v4.zip
validate $? "downloading catalogue app"

cd /app
unzip /tmp/catalogue.zip
validate $? "unzip the application file"

echo "[info] Installing Dependencies is started============="
npm install
validate $? "installing application dependencies"


# sed -i "s/DOMAIN_NAME/$domain_name" catalogue.sh
