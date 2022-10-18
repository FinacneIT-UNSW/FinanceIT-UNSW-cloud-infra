variable "tags" {
  type = map(any)
}

variable "name_suffix" {
  description = "Suffix to append to all ressource names."
  type        = string
}

variable "table_name" {
  description = "Name of the main Table"
  type        = string
}

variable "read_capacity" {
  description = "Read capacity for the table"
  type        = number
}

variable "write_capacity" {
  description = "Write capacity for the table"
  type        = number
}

variable "hash_key_name" {
  description = "Name of the hash key"
  type        = string
}

variable "hash_key_type" {
  description = "Type of the hash key"
  type        = string
}

variable "sort_key_name" {
  description = "Name of the sort key"
  type        = string
}

variable "sort_key_type" {
  description = "Type of the sort key"
  type        = string
}

variable "isstream" {
  description = "Activate the stream or not (for websocket module)"
  type        = bool
}

variable "stream_type" {
  description = "Stream type"
  type        = string
  default     = null
}
