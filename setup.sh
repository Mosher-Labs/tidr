#!/bin/bash

projectDir=$HOME/Code/z

cd $projectDir/terraform/state-storage
terraform init -upgrade
terraform apply

cd $projectDir/terraform/
terraform init -upgrade
terraform apply -target='aws_iam_policy_attachment.terraform_manipulation'
terraform apply

terraform output
