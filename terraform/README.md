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
