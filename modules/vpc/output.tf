output "vpc" {
  description = "vpc"
  value       = aws_vpc.PR-TEST-VPC.id
}

output "public_subnets" {
  description = "public subnets"
  value       = aws_subnet.PR-TEST-PUBSUB.*.id
}

output "private_subnets" {
  description = "private subnets"
  value       = aws_subnet.PR-TEST-PRISUB.*.id
}

output "default_acl" {
  description = "defaults acl"
  value       = aws_default_network_acl.PR-TEST-ACL.id
}

output "default_sg" {
  description = "default sg"
  value       = aws_default_security_group.PR-TEST-SG.id
}

output "IGW" {
  description = "igw"
  value       = aws_internet_gateway.PR-TEST-IGW.id
}

output "eip" {
  description = "EIP"
  value       = aws_eip.EIP.*.id
}

output "nat_gateway" {
  description = "nat gateway"
  value       = aws_nat_gateway.PR-TEST-NG.*.id
}

output "public_route_tables" {
  description = "public route tables"
  value       = aws_route_table.PR-TEST-PUBROUTE.*.id
}

output "private_route_tables" {
  description = "private route tables"
  value       = aws_route_table.PR-TEST-PRIROUTE.*.id
}