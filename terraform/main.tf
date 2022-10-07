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

  tags        = local.tags
  name_suffix = local.name_suffix
  table       = module.db.table

  ressource_name = var.api_db_rest_ressource_name
  stage_name     = var.api_db_rest_stage_name
  get = {
    file_path   = var.api_db_rest_get_file_path
    handler     = var.api_db_rest_get_handler
    runtime     = var.api_db_rest_get_runtime
    memory_size = var.api_db_rest_get_memory_size
    timeout     = var.api_db_rest_get_timeout
  }
  post = {
    file_path   = var.api_db_rest_post_file_path
    handler     = var.api_db_rest_post_handler
    runtime     = var.api_db_rest_post_runtime
    memory_size = var.api_db_rest_post_memory_size
    timeout     = var.api_db_rest_post_timeout
  }
}

module "db" {
  source = "./modules/db_dynamo"

  tags        = local.tags
  name_suffix = local.name_suffix

  table_name     = var.db_dynamo_table_name
  read_capacity  = var.db_dynamo_read_capacity
  write_capacity = var.db_dynamo_write_capacity
  hash_key_name  = var.db_dynamo_hash_key_name
  hash_key_type  = var.db_dynamo_hash_key_type
  sort_key_name  = var.db_dynamo_sort_key_name
  sort_key_type  = var.db_dynamo_sort_key_type
  isstream       = var.db_dynamo_stream
  stream_type    = var.db_dynamo_stream_type
}

/* module "websocket" {
  source = "./modules/websocket"

  tags                 = local.tags
  name_suffix          = local.name_suffix
  table                = module.dynamodb.table
  lambda_archives_path = var.lambda_archives_path
} */


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
