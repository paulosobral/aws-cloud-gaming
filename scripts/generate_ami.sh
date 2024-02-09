#!/bin/bash

# Specify instance ID and AMI details
INSTANCE_ID=i-1234567890abcdef0  
AMI_NAME="MyWindowsAMI"

# Create AMI
aws ec2 create-image \
  --instance-id $INSTANCE_ID \
  --name $AMI_NAME

# Get AMI ID
ami_id=$(aws ec2 describe-images --filters "Name=name,Values=$AMI_NAME" --query 'Images[0].ImageId' --output text)

# Loop to check AMI status  
while true; do
  status=$(aws ec2 describe-images --image-ids $ami_id --query 'Images[0].State' --output text)

  if [[ $status == "available" ]]; then
    echo "AMI $AMI_NAME creation completed successfully!"
    break
  fi

  echo "AMI $AMI_NAME status is $status...waiting..."
  sleep 15
done

# Enable fast boot for AMI
aws ec2 modify-image-attribute --image-id $ami_id --launch-permission "{\"Add\":[{\"Group\":\"all\"}]}
aws ec2 enable-fast-launch --image-id $ami_id
