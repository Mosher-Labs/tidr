terraform {
  backend "s3" {
    bucket       = "mosher-labs-state-storage"
    key          = "z/terraform.tfstate"
    region       = "us-west-2"
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.89"
    }
  }

  required_version = "~> 1.11"
}

provider "aws" {
  region = var.aws_config.region
}

