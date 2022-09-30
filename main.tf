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

locals {
  tags = {
    project     = var.project_name,
    environment = var.environment
  }

  name_suffix = "-${var.project_name}-${var.environment}"
}

module "api" {
  source = "./modules/api"

  tags                 = local.tags
  name_suffix          = local.name_suffix
  lambda_archives_path = var.lambda_archives_path
  table                = module.dynamodb.table
}

module "dynamodb" {
  source = "./modules/database"

  tags        = local.tags
  name_suffix = local.name_suffix
  table_name  = var.table_name
}


resource "aws_resourcegroups_group" "indoor-air-rg" {
  name = "RG${local.name_suffix}"

  resource_query {
    query = <<JSON
{
  "ResourceTypeFilters": [
    "AWS::AllSupported"
  ],
  "TagFilters": [
    {
      "Key": "project",
      "Values": ["${var.project_name}"]
    }
  ]
}
JSON
  }
}
