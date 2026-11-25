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

alternatives --set java "/usr/lib/jvm/java-25-openjdk/bin/java"
validate $? "Setting Java 25 as default Java version"

echo "export JAVA_HOME=$(dirname $(dirname $(readlink -f /usr/bin/java)))" > /etc/profile.d/java.sh
source /etc/profile.d/java.sh
echo $JAVA_HOME
validate $? "Setting JAVA_HOME for maven"

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

curl -L -o /tmp/shipping.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/shipping-v4.zip  &>> $logs_file
validate $? "downloading shipping app"

cd /app
unzip /tmp/shipping.zip  &>> $logs_file
validate $? "unzip the application file"

mvn clean package  &>> $logs_file
validate $? "Installing Dependencies"

mv target/shipping.jar shipping.jar  &>> $logs_file
validate $? "Moving Shipping Jar file"

dnf install mysql -y  &>> $logs_file
validate $? "Installing mysql client"

count=$(mysql -h mysql.$domain_name -uroot  -pRoboShop@1 -D cities -N -s -e "SELECT COUNT(*) FROM cities";)

if [ $count -eq 0 ] || [ -z $count ]; then
    mysql -h mysql.$domain_name -uroot -pRoboShop@1 < /app/db/master-data.sql 
    validate $? "Loading cities data"
else
    echo "Data already loaded , so Skipping==========="
fi

mysql -h mysql.$domain_name -uroot -pRoboShop@1 < /app/db/app-user.sql
validate $? "Creating app user"

sed -i "s/domainName/$domain_name/g" "$script_path/shipping.service"
validate $? "configuration file update "


cp "$script_path/shipping.service" /etc/systemd/system/shipping.service
validate $? "service file copied"

systemctl daemon-reload
validate $? "Reloading the service"
systemctl enable shipping
validate $? "Enable shipping service"
systemctl start shipping
validate $? "start shipping service"

