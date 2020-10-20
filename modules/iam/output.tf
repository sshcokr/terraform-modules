output "aws_iam_arn" {
  value = aws_iam_user.admin_user.*.arn
}