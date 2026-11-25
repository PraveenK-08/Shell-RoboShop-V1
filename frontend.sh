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

dnf module disable nginx -y  &>> $logs_file
validate $? "Disable nginx default version"
dnf module enable nginx:1.26 -y &>> $logs_file
validate $? "Enable nginx 1.26 version"
dnf install nginx -y &>> $logs_file
validate $? "Install Nginx" 

systemctl enable nginx
validate $? "service enable"
systemctl start nginx
validate $? "start service"

rm -rf /usr/share/nginx/html/*
validate $? "Remove Default file"

curl -L -o /tmp/frontend.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/frontend-v4.zip  &>> $logs_file
validate $? "downloading frontend app"

cd /usr/share/nginx/html/
unzip /tmp/frontend.zip  &>> $logs_file
validate $? "unzip the application file"

sed -i "s/domainName/$domain_name/g" "$script_path/frontend.conf" &>> $logs_file
validate $? "configuration file update "

cp "$script_path/frontend.conf" /etc/nginx/default.d/roboshop.conf &>> $logs_file
validate $? "configuration file copied"

systemctl restart nginx &>> $logs_file
validate $? "Restart Nginx"
