variable "cidr" {
  description = "vpc의 cidr을 정의"
}

variable "public_subnets" {
  description = "퍼블릭 서브넷들을 정의"
}

variable "private_subnets" {
  description = "프라이빗 서브넷들을 정의"
//  type = "list"
}

variable "azs" {
  description = "가용영역 정의"
//  type = "list"
}

variable "name" {
  description = "리소스 기본 name을 정의"
//  type = "string"
}