#!/bin/bash
RED='\e[31m'
GREEN='\e[1;32m'
logs_folder="/var/log/Shell-practice"
logs_file="$logs_folder/$0"

mkdir -p $logs_folder

echo " mongodb server configuration is started========="
echo "started time = $(date +"%Y%m%d_%H%M%S")"
validate() {
    if [ $1 -eq 0 ]; then 
        echo -e " ${2} is ${GREEN}success" | tee -a  $logs_file
    
    else
        echo -e " ${2} is ${RED}Failed "  | tee -a  $logs_file
        exit 1
    
    fi 
}
cp mongo.repo vim /etc/yum.repos.d/mongo.repo &>> $logs_file
validate $? "copied the mongo repo " 

dnf install mongodb-org -y  &>> $logs_file
validate $? "Installing mongodb server package "

systemctl enable mongod &>> $logs_file
validate $? "package enabled "

systemctl start mongod &>> $logs_file
validate $? "package started "

sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf &>> $logs_file
validate $? "Configuration updation "

systemctl restart mongod &>> $logs_file
validate $? "package restarted "

echo "configuration endtime = $(date +"%Y%m%d_%H%M%S")"
echo "time taken : $SECONDS"