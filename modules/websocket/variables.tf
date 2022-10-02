data "aws_caller_identity" "current" {}

variable "tags" {
    type = map
}

variable "name_suffix" {
  type = string
}

variable "lambda_archives_path" {
    type = string
}

variable "table" {
  type = map
}