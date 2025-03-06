variable "aws_config" {
  description = "The AWS config to deploy resources with."
  type = object({
    region = optional(string, "us-west-2")
  })
}

variable "config" {
  description = "The configuration for the Terraform deployment."
  type = object({
    name = optional(string, null)
  })
}

variable "state_storage_config" {
  description = "The configuration for the state storage backend."
  type = object({
    acl            = optional(string, "private")
    bucket         = string
    dynamodb_table = optional(string, null)
    encrypt        = optional(bool, true)
    key            = string
    region         = optional(string, null)
  })
}
