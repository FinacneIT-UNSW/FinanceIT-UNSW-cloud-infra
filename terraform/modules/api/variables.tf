data "aws_caller_identity" "current" {}

variable "tags" {
  type = map(any)
}

variable "name_suffix" {
  description = "Append a suffix at the end of all ressource names"
  type        = string
}

variable "table" {
  description = "Table name, arn and stream"
  type        = map(any)
}

variable "ressource_name" {
  description = "Name of the ressource (exemple: /data)"
  type        = string
}

variable "stage_name" {
  description = "Name of the stage (exemple: v1)"
  type        = string
}

variable "get" {
  description = "Configuration for Get endpoint"
  type        = map(any)
}

variable "post" {
  description = "Configuration for Post endpoint"
  type        = map(any)
}
