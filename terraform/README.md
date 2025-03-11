# z

To properly apply this, you must follow some steps.

1. Setup state storage:

  ```bash
  cd state-storage
  tf init
  tf plan
  tf apply
  ```

1. Setup Terraform manipulation permissions:

  ```bash
  cd ../
  tf init
  tf apply -target='aws_iam_policy_attachment.terraform_manipulation'
  ```

1. Setup the rest of the application infrastructure:

  ```bash
  tf apply
  ```


## To get the public IP

```bash
aws ecs list-tasks --cluster mosher_labs_z --query 'taskArns[0]' --output text --region us-west-2
aws ecs describe-tasks --cluster mosher_labs_z --tasks <TASK_ARN> --query 'tasks[0].attachments[0].details[?name==`networkInterfaceId`].value' --output text --region us-west-2
aws ec2 describe-network-interfaces --network-interface-ids <ENI_ID> --query 'NetworkInterfaces[0].Association.PublicIp' --output text --region us-west-2
```
