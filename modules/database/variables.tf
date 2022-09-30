variable "tags" {
    type = map
}

variable "name_suffix" {
  type = string
}

variable "table_name" {
  type = string
}

variable "read_capacity" {
  type = number
  default = 20
}

variable "write_capacity" {
  type = number
  default = 20
}
