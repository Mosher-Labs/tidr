variable "aws_config" {
  description = "The AWS config to deploy resources with."
  type = object({
    region = optional(string, "us-west-2")
  })
}

variable "config" {
  description = "The configuration for the state storage backend."
  type = object({
    encrypt = optional(bool, true)
    key     = string
    name    = string
    region  = optional(string, null)
  })
}
