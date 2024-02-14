terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.32.0, <5.34.0, !=5.33.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }

  }
  required_version = "~>1.7.2"
}

provider "aws" {
  region = "us-east-2"
  default_tags {
    tags = var.tags
  }
}
