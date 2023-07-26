#!/bin/bash

# This script is password protected and accepts 2 parameters, name of the cluster and the environment (DEV or PROD) on which the cluster has to be deleted.
ACTUAL="QWthc2hAMTIz"
read -s -p "Password: " enteredpass
cd $BASE_PROJECT_PATH
ENV=$2
ROOT_DIR="$(pwd)"
rm -rf .terraform
if [[ $2 == "DEV" || $2 == "dev" ]]
then
	  terraform init -backend-config="prefix=$ENV"
	  terraform destroy -var "cluster_name=$1" -var-file "$ROOT_DIR/vars/$ENV.tfvars"
elif [[ $2 == "PROD" || $2 == "prod" ]]
then
          terraform init -backend-config="prefix=$ENV"
          terraform destroy -var "cluster_name=$1" -var-file "$ROOT_DIR/vars/$ENV.tfvars"	  
else
		echo "Please enter DEV or PROD as input to 2nd paramater"
fi
