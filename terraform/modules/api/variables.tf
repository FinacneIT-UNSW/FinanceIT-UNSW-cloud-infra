data "aws_caller_identity" "current" {}

variable "tags" {
  type = map(any)
}

variable "name_suffix" {
  type = string
}

variable "table" {
  type = map(any)
}

variable "ressource_name" {
  type = string
}

variable "stage_name" {
  type = string
}

variable "get" {
  type = map
} 

variable "post" {
  type = map
}
