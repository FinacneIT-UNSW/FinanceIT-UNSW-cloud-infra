variable "tags" {
  type = map(any)
}

variable "name_suffix" {
  type = string
}

variable "table_name" {
  type = string
}

variable "read_capacity" {
  type = number
}

variable "write_capacity" {
  type = number
}

variable "hash_key_name" {
  type = string
}

variable "hash_key_type" {
  type = string
}

variable "sort_key_name" {
  type = string
}

variable "sort_key_type" {
  type = string
}

variable "isstream" {
  type = bool
}

variable "stream_type" {
  type = string
}
