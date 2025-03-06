terraform {
  backend "local" {
    # path = "keybase://private/benniemosher/z/terraform.tfstate"
    path = "/Volumes/Keybase (benniemosher)/private/benniemosher/z/terraform.tfstate"
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

