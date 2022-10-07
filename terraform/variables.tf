variable "project_name" {
  description = "Name of the project."
  type        = string
}

variable "environment" {
  description = "Name of the environment."
  type        = string
}

variable "aws_profil" {
  description = "AWS Profil to use (/.aws/creds)"
  type        = string
}
