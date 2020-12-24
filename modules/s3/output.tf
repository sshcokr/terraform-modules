output "aws_s3_bucket_name" {
  value = aws_s3_bucket.tfstate.bucket
}

output "aws_dynamodb_name" {
  value = aws_dynamodb_table.tfstate_lock.name
}