echo "Launching EC2 instance..."

domain_name="teram.store"
for instance in $@
do 

instanceId=$(aws ec2 run-instances \
    --region "us-east-1" \
    --image-id "ami-0055977a6e828a4f4" \
    --count 1 \
    --instance-type "t3.micro" \
    --security-group-ids "roboshop-$instance" \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=RoboShop-$instance}]" \
    --query "Instances[0].InstanceId" \
    --output text)

echo "$instance instance is created "
echo "instance running up....."

aws ec2 wait instance-running --region "us-east-1" --instance-ids $instanceId

echo "retriving Ip address for $instance"

if [ "$instance" != "frontend" ]; then

   ip=$(aws ec2 describe-instances \
   --region "us-east-1" \
   --instance-ids $instanceId \
   --query 'Reservations[0].Instances[0].PrivateIpAddress' \
   --output text)
else
    ip=$(aws ec2 describe-instances \
  --instance-ids $instanceId \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text)
fi  

echo "$instance : $ip"
echo "creating R53 record to the instance"
# aws route53 change-resource-record-sets \
#     --hosted-zone-id "Z0271784QT4RL9L1ZC5R" \
#     --change-batch {
#   "Changes": '[
#     {
#       "Action": "UPSERT",
#       "ResourceRecordSet": {
#          "Name": "$instance.$domain_name",
#          "Type": "A",
#          "TTL": 1,
#          "ResourceRecords": [{"Value": $ip}]
#         }
#     }
#   ]
# }'

# Construct the JSON payload using a heredoc
CHANGE_BATCH=$(cat <<EOF
{
  "Comment": "Automated DNS update via shell script",
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "$instance.$domain_name",
        "Type": "A",
        "TTL": 1,
        "ResourceRecords": [
          {
            "Value": "$ip"
          }
        ]
      }
    }
  ]
}
EOF
)

# Execute the AWS CLI command
aws route53 change-resource-record-sets \
  --hosted-zone-id "Z0271784QT4RL9L1ZC5R" \
  --change-batch "$CHANGE_BATCH"
done



