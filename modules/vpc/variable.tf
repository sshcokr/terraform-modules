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

variable "ec2_endpoint_subnet_ids" {
  description = "The ID of one or more subnets in which to create a network interface for EC2 endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used."
  type        = list(string)
  default     = []
}

variable "aws_azs" {
  description = "가용영역 정의"
}

variable "ec2_vpc_endpoint_policy" {
  description = "S3 VPC endpoint gateway policy document. Bucket and IAM policies still apply."
  default     = <<POLICY
{
    "Statement": [
        {
            "Sid": "FullAccess",
            "Action": "*",
            "Effect": "Allow",
            "Resource": "*",
            "Principal": "*"
        }
    ],
    "Version": "2008-10-17"
}
POLICY

}

# Naming
variable "global_tags" {
  description = "리소스 맨앞에 붙는 이름을 정의"
  type = map(string)
}


variable "aws_vpc_name" {
  description = "VPC의 이름을 정의"
  default = "EKS-VPC"
}

variable "aws_igw_name" {
  description = "IGW의 이름을 정의"
  default = "EKS-IGW"
}

variable "aws_nat_gw_name" {
  description = "Nat Gateway의 이름을 정의"
  default = "EKS-Nat-Gateway"
}

variable "aws_public_route_table_name" {
  description = "퍼블릭 라우트 테이블의 이름을 정의"
  default = "EKS-Public-Route-Table"
}

variable "aws_private_route_table_name" {
  description = "프라이빗 라우트 테이블의 이름을 정의"
  default = "EKS-Private-Route-Table"
}



