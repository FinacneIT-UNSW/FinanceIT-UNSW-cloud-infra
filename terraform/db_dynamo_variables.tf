// DATABASES VARIABLES
// Dynamo

variable "db_dynamo_table_name" {
  type = string
}

variable "db_dynamo_read_capacity" {
  type = number
}

variable "db_dynamo_write_capacity" {
  type = number
}

variable "db_dynamo_hash_key_name" {
  type = string
}

variable "db_dynamo_hash_key_type" {
  type = string
}

variable "db_dynamo_sort_key_name" {
  type = string
}

variable "db_dynamo_sort_key_type" {
  type = string
}

variable "db_dynamo_stream" {
  type = bool
}

variable "db_dynamo_stream_type" {
  type = string
  default = null
}
