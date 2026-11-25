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

dnf install python3.14 python3.14-pip -y &>> $logs_file
validate $? "Install python "

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

curl -L -o /tmp/payment.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/payment-v4.zip  &>> $logs_file
validate $? "downloading payment app"

cd /app
unzip /tmp/payment.zip  &>> $logs_file
validate $? "unzip the application file"

python3.14 -m venv /app/.venv &>> $logs_file
/app/.venv/bin/pip install -r requirements.txt &>> $logs_file
validate $? "creating and installing virtual Environment and Dependencies"


sed -i "s/domainName/$domain_name/g" "$script_path/payment.service"
validate $? "configuration file update "


cp "$script_path/payment.service" /etc/systemd/system/payment.service
validate $? "service file copied"

systemctl daemon-reload &>> $logs_file
validate $? "Reloading the service"
systemctl enable shipping
validate $? "Enable shipping service"
systemctl start shipping
validate $? "start shipping service"


