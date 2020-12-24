variable "create_key_pair" {
  description = "If Value is true. Create New Key Pair."
  type = bool
  default = true
}

variable "key_name" {
  type = string
}

variable "prefix" {
  type = string
  default = null
}

variable "public_key" {
  type = string
}

variable "tags" {
  type = map(string)
  default = {}
}