# state-storage

Unfortunately, there is a large order of operations problem with setting up an
AWS S3 driven backend for Terraform.

In order to do this, first you must login to your AWS account and add a policy to
the user you are using to run Terraform (i.e. `z_terraform`). Call that policy
`mosher_labs_requisite_permissions`, and give it a policy similiar to:

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
              "iam:DetachUserPolicy",
              "iam:Get*",
              "iam:List*",
              "s3:PutBucketVersioning"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
```

This will then get imported into your Terraform via the import block in `iam.tf`.

Then, you can run the following commands to set up the S3 bucket and DynamoDB table:
