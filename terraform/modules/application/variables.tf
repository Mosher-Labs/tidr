variable "config" {
  description = "The configuration for the application."
  type = object({
    name                = string
    acm_certificate_arn = optional(string, "")
  })
}
