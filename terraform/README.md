# z

## TODO

- Setup Zoom Client ID, Secret, and URL envs

## Setup

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

1. Create certificates

  ```bash
  brew install certbot
  sudo certbot certonly --manual --preferred-challenges dns \
    -d 'z.benniemosher.dev' -d '*.z.benniemosher.dev'
  ```

1. Copy certs to useable location:

  ```bash
  sudo cp -r /etc/letsencrypt/ ~/certs/
  sudo chown -R benniemosher ~/certs
  ```

1. Upload Certs to ACM:

  ```bash
  aws acm import-certificate \
      --certificate fileb://~/certs/live/z.benniemosher.dev/cert.pem \
      --private-key fileb://~/certs/live/z.benniemosher.dev/privkey.pem \
      --certificate-chain fileb://~/certs/live/z.benniemosher.dev/chain.pem \
      --region us-west-2 \
      --tags '[{"Key": "Name", "Value": "mosher_labs_z"}]'
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
