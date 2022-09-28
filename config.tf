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

variable "resource_tags" {
  description = "Tags to set for all resources"
  type        = map(string)
  default     = {}
}
