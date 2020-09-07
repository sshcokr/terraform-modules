variable "bucket_name" {
  description = "Define the bucket name to use remote_state"
  default = "testing"
}

variable "dynamo_db_name" {
  description = "Define the DynamoDB name to use"
  default = "tflock"
}