variable "bucket_name" {
  description = "Define the bucket name to use remote_state"
}

variable "dynamo_db_name" {
  description = "Define the DynamoDB name to use"
  default = "tflock"
}

variable "remote_state_path" {
  description = "Define the remote_state Saving Path"
  default = "terraform"
}