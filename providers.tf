terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.37.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.0"
    }
  }

  # Best Practice: In a real company, you would uncomment the block below 
  # to save your state file in an S3 bucket instead of on your laptop.
  # backend "s3" {
  #   bucket         = "my-terraform-state-bucket"
  #   key            = "epicbook/terraform.tfstate"
  #   region         = "ap-south-1"
  #   dynamodb_table = "terraform-lock"
  # }
}

provider "aws" {
  region = var.aws_region
}
