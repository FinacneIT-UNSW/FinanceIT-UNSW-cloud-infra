variable "project_name" {
  description = "Name of the project."
  type        = string
}

variable "environment" {
  description = "Name of the environment."
  type        = string
}

variable "lambda_archives_path" {
  description = "Relative path to lambda archives"
  type        = string
}

variable "resource_tags" {
  description = "Tags to set for all resources"
  type        = map(string)
  default     = {}
}

variable "aws_profil" {
  description = "AWS Profil to use (/.aws/creds)"
  type        = string
}
