#!/bin/bash
for instance in $@
do 

instanceId=$(aws ec2 run-instances \
    --region "us-east-1" \
    --image-id "ami-0055977a6e828a4f4" \
    --count 1 \
    --instance-type "t3.micro" \
    --security-group-ids "RoboShop-$instance" \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=RoboShop-$instance}]")
 echo "instanceId "
done

