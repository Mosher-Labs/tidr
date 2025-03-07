# state-storage

Unfortunately, there is a large order of operations problem with setting up an
AWS S3 driven backend for Terraform.

In order to do this, first you must login to your AWS account and add a customer
inline policy to the user you are using to run Terraform (i.e. `z_terraform`).
Call that policy `requisite_permissions`, and give it a policy similiar to:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
              "iam:AttachUserPolicy",
              "iam:CreatePolicy",
              "iam:DeletePolicy",
              "iam:DeletePolicyVersion",
              "iam:DetachUserPolicy",
              "iam:Get*",
              "iam:List*",
              "s3:PutBucketTagging",
              "s3:PutBucketVersioning"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
```

Then run `terraform apply` to create all of the IAM policies. At this point you
can delete the inline policy that you created earlier. Now run `terraform apply`
again to have it create the AWS S3 bucket required for state storage.
