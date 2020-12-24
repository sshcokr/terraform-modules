variable "aws_vpc_cidr" {
  description = "vpc의 cidr을 정의"
}

variable "aws_public_subnets" {
  description = "퍼블릭 서브넷들을 정의"
}

variable "aws_private_subnets" {
  description = "프라이빗 서브넷들을 정의"
}

variable "aws_region" {
  description = "리소스 생성할 지역 정의"
  type = string
}

variable "aws_azs" {
  description = "가용영역 정의"
}

# Naming
variable "global_tags" {
  description = "EKS 생성을 위한 태깅"
  type = map(string)
}

variable "aws_default_name" {
  type = string
  description = "리소스에 붙을 고유한 default 이름을 정의"
}