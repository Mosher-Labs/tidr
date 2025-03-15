variable "config" {
  description = "The configuration for the application."
  type = object({
    name = string
  })
}
