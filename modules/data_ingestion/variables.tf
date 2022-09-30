variable "project_name" {}

variable "environment" {}

variable "lambda_archives_path" {}

variable "resource_tags" {}

data "aws_caller_identity" "current" {}
