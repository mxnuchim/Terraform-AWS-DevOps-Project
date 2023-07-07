terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region     = "eu-west-1"
  access_key = "AKIAXH6VHYU3XN4D35D7"
  secret_key = "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"
}
