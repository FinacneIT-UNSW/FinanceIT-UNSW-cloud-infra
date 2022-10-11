data "aws_caller_identity" "current" {}

variable "tags" {
  type = map(any)
}

variable "name_suffix" {
  type = string
}

variable "stage_name" {
  description = "Stage name for API."
  type        = string
}

variable "table" {
  description = "Data Table reference for Streaming."
  type        = map(any)
}

variable "message" {
  description = "Lambda configuration for message lambda."
  type        = map(any)
}

variable "manager" {
  description = "Lambda configuration for manager lambda."
  type        = map(any)
}
