#!/bin/bash
RED='\e[31m'
GREEN='\e[1;32m'
Normal="\e[0m"
user_id=$(id -u)
logs_folder="/var/log/Shell-RoboShop-V1"
logs_file="$logs_folder/$0"
script_path=$(dirname $(realpath ${0}))
domain_name=teram.store

if [ $user_id -ne 0 ]; then
    echo "Please run this script with sudo access.."
    exit 1
fi

mkdir -p $logs_folder

echo $script_path
# echo " catalogue server configuration is started========="
# echo "started time = $(date +"%Y%m%d_%H%M%S")"
# validate() {
#     if [ $1 -eq 0 ]; then 
#         echo -e " ${2} is ${GREEN}success$Normal" | tee -a  $logs_file
    
#     else
#         echo -e " ${2} is ${RED}Failed$Normal"  | tee -a  $logs_file
#         exit 1
    
#     fi 
# }

# dnf module disable nodejs -y &>> $logs_file
# validate $? "nodejs old version disabled"

# dnf module enable nodejs:24 -y  &>> $logs_file
# validate $? "nodejs version:24 enabled" 

# echo "[info]installation started=============="
# dnf install nodejs -y   &>> $logs_file
# validate $? "installing nodejs package "

# id roboshop  &>> $logs_file
# if [ $? -ne 0 ]; then
#     echo "[INFO]creating new user================="
#     useradd --system --shell /sbin/nologin --home /app --comment "roboshop user creation" roboshop  &>> $logs_file
#     validate $? "creating system user "

# else
#     echo "[INFO]deleting old user================="
#     userdel -r roboshop &>> $logs_file
#     echo "[INFO]creating new user================="
#     useradd --system --shell /sbin/nologin --home /app --comment "roboshop user creation" roboshop  &>> $logs_file
#     validate $? "creating system user "
# fi 

# rm -rf /app
# mkdir -p /app
# validate $? "app directory created"

# curl -L -o /tmp/catalogue.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/catalogue-v4.zip  &>> $logs_file
# validate $? "downloading catalogue app"

# cd /app
# unzip /tmp/catalogue.zip  &>> $logs_file
# validate $? "unzip the application file"

# echo "[info] Installing Dependencies is started============="
# npm install  &>> $logs_file
# validate $? "installing application dependencies"


# sed -i "s/DOMAIN_NAME/$domain_name/" "$script_path/catalogue.service"
# validate $? "configuration file update "


# cp "$script_path/catalogue.service" /etc/systemd/system/catalogue.service
# validate $? "service file copied"


