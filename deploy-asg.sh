#!/bin/bash

# Function to display the help message
usage() {
  echo "Usage: $0 -n <name> -s <instance_count> [-h]"
  echo "  -n <name>          : Base name for resources (e.g., 'awesome' for 'awesome-ASG')"
  echo "  -s <instance_count>: Desired number of instances in the ASG"
  echo "  -h                 : Display help message"
  exit 1
}

# Parse command-line arguments
while getopts ":n:s:h" opt; do
  case $opt in
    n) BASE_NAME=$OPTARG ;;
    s) INSTANCE_COUNT=$OPTARG ;;
    h) usage ;;
    \?) echo "Invalid option -$OPTARG" >&2; usage ;;
  esac
done

# Validate required arguments
if [ -z "$BASE_NAME" ] || [ -z "$INSTANCE_COUNT" ]; then
  echo "Both -n <name> and -s <instance_count> are required."
  usage
fi

# Define the CloudFormation stack name
STACK_NAME="${BASE_NAME}-stack"

# Deploy the CloudFormation template
aws cloudformation deploy \
  --stack-name "$STACK_NAME" \
  --template-file launch-template-asg.yml \
  --parameter-overrides BaseName="$BASE_NAME" DesiredCapacity="$INSTANCE_COUNT" \
  --capabilities CAPABILITY_NAMED_IAM

if [ $? -eq 0 ]; then
  echo "CloudFormation stack $STACK_NAME created successfully."
else
  echo "Failed to create CloudFormation stack."
fi
