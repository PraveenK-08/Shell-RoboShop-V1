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

dnf module disable nodejs -y &>> $logs_file
validate $? "nodejs old version disabled"

dnf module enable nodejs:24 -y  &>> $logs_file
validate $? "nodejs version:24 enabled" 

echo "[info]installation started=============="
dnf install nodejs -y   &>> $logs_file
validate $? "installing nodejs package "

id roboshop  &>> $logs_file
if [ $? -ne 0 ]; then
    echo "[INFO]creating new user================="
    useradd --system --shell /sbin/nologin --home /app --comment "roboshop user creation" roboshop  &>> $logs_file
    validate $? "creating system user "

else
    echo "[INFO]deleting old user================="
    pkill -9 -u roboshop &>> $logs_file
    userdel -r roboshop &>> $logs_file
    echo "[INFO]creating new user================="
    useradd --system --shell /sbin/nologin --home /app --comment "roboshop user creation" roboshop  &>> $logs_file
    validate $? "creating system user "
fi 

rm -rf /app
mkdir -p /app
validate $? "app directory created"

curl -L -o /tmp/cart.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/cart-v4.zip  &>> $logs_file
validate $? "downloading cart app"

cd /app
unzip /tmp/cart.zip  &>> $logs_file
validate $? "unzip the application file"

echo "[info] Installing Dependencies is started============="
npm install  &>> $logs_file
validate $? "installing application dependencies"


sed -i "s/domainName/$domain_name/g" "$script_path/cart.service"
validate $? "configuration file update "


cp "$script_path/cart.service" /etc/systemd/system/cart.service
validate $? "service file copied"

systemctl daemon-reload &>> logs_file
validate $? "reloading service"
systemctl enable cart &>> logs_file
validate $? "service enable" 
systemctl start cart
validate $? "start service"