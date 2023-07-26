#!/bin/bash

# This script takes 2 parameters CLUSTER_NAME and ENVIRONMENT (dev or prod)
cd $BASE_PROJECT_PATH
ENV=$2
ROOT_DIR="$(pwd)"
rm -rf .terraform
if [[ $2 == "dev" ]]
then
	# DEV cluster deployment with 2 AZ and 2 nodes
        terraform init -backend-config="prefix=$ENV"
        terraform validate
	terraform plan -var "cluster_name=$1" -var-file "$ROOT_DIR/vars/$ENV.tfvars" -out=".$ENV.plan" 
        terraform apply ".$ENV.plan"  
elif [[ $2 == "prod" ]]
then 
	# PROD cluster deployment with 3 AZ and 3 nodes
	terraform init -backend-config="prefix=$ENV"
	terraform validate
	terraform plan -var "cluster_name=$1" -var-file "$ROOT_DIR/vars/$ENV.tfvars" -out=".$ENV.plan"  
        terraform apply ".$ENV.plan"
else
	echo "Please enter DEV or PROD as input to 2nd paramater"
fi

