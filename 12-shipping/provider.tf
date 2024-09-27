terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }


  backend "s3" {
    bucket         = "chandudaws76-state-dev"
    key            = "shipping"
    region         = "us-east-1"
    dynamodb_table = "chandudaws76-locking-dev"

  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}
