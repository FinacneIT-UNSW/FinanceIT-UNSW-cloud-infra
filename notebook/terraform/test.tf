terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  profile = var.aws_profil
  region  = "ap-southeast-2"
}

variable "aws_profil" {
  description = "AWS Profil to use (/.aws/creds)"
  type        = string
}

resource "aws_dynamodb_table" "connections" {
  name           = "TEST"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "connectionId"

  attribute {
    name = "connectionId"
    type = "S"
  }
}