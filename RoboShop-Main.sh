#!/bin/bash
RED='\e[31m'
GREEN='\e[1;32m'
logs_folder="/var/log/Shell-practice"
logs_file="$logs_folder/$0"

mkdir -p $logs_folder

validate() {
    if [ $1 -eq 0 ]; then 
        echo -e " ${2} is ${GREEN}success"
    
    else
        echo -e " ${2} is ${RED}Failed "
    
    fi 
}
echo "Launching EC2 instance..."
for instance in $@
do 

instanceId=$(aws ec2 run-instances \
    --region "us-east-1" \
    --image-id "ami-0055977a6e828a4f4" \
    --count 1 \
    --instance-type "t3.micro" \
    --security-group-ids "roboshop-$instance" \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=RoboShop-$instance}]")
 validate $? "instance $instance creation"
done


