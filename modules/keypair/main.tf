resource "aws_key_pair" "shin" {
  key_name = var.key_name
  key_name_prefix = var.prefix

  public_key = var.public_key
  tags = var.tags
}