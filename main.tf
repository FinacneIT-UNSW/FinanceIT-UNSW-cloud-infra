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

module "data-ingestion" {
  source = "./modules/data_ingestion"

  project_name         = var.project_name
  environment          = var.environment
  lambda_archives_path = var.lambda_archives_path
  resource_tags        = var.resource_tags
}
