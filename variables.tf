variable "project_name" {
  description = "Name of the project."
  type        = string
  default     = "unsw-cse-brew"
}

variable "environment" {
  description = "Name of the environment."
  type        = string
  default     = "dev"
}

variable "lambda_archives_path" {
  description = "Relative path to lambda archives"
  type        = string
  default     = "./lambdas_archives"
}

variable "resource_tags" {
  description = "Tags to set for all resources"
  type        = map(string)
  default     = {}
}
