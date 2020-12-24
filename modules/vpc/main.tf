# ########### #
# Setting VPC #
# ########### #

# Create VPC
resource "aws_vpc" "PR-TEST-VPC" {
  cidr_block           = var.aws_vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags = {
    "Name" = format("%s-%s", var.aws_default_name, "EKS-VPC")
  }
}


# Setting Subnet
# Create Public Subnet
resource "aws_subnet" "PR-TEST-PUBSUB" {
  count             = length(var.aws_public_subnets)
  cidr_block        = var.aws_public_subnets[count.index]
  vpc_id            = aws_vpc.PR-TEST-VPC.id
  map_public_ip_on_launch = true

  availability_zone = var.aws_azs[count.index]
  tags = {
    "Name" = format("%s-%s", var.aws_default_name, "EKS-PUBLIC${count.index + 1}")
  }
}

# Create Private Subnet
resource "aws_subnet" "PR-TEST-PRISUB" {
  count             = length(var.aws_private_subnets)
  cidr_block        = var.aws_private_subnets[count.index]
  vpc_id            = aws_vpc.PR-TEST-VPC.id
  availability_zone = var.aws_azs[count.index]
  tags = {
    "Name" = format("%s-%s", var.aws_default_name, "PRIVATE${count.index + 1}")
  }
}


# Create IGW
resource "aws_internet_gateway" "PR-TEST-IGW" {
  vpc_id = aws_vpc.PR-TEST-VPC.id

  tags = {
    "Name" = format("%s-%s", var.aws_default_name, "IGW")
  }
}

#
# Create EIP for Nat Gateway
resource "aws_eip" "EIP" {
  vpc   = true
}

# Create Nat Gateway
resource "aws_nat_gateway" "PR-TEST-NG" {
  allocation_id = aws_eip.EIP.id
  subnet_id     = aws_subnet.PR-TEST-PUBSUB.0.id

  tags = {
    "Name" = format("%s-%s", var.aws_default_name, "NATGW")
  }
}



## Route Table
# Create Public Route Table
resource "aws_route_table" "PR-TEST-PUBROUTE" {
  vpc_id = aws_vpc.PR-TEST-VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.PR-TEST-IGW.id
  }

  tags =
  {
    "Name" = format("%s-%s", var.aws_default_name, "PUBLIC-ROUTE")
  }
}
# Create Private Route Table
resource "aws_route_table" "PR-TEST-PRIROUTE" {
  vpc_id = aws_vpc.PR-TEST-VPC.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.PR-TEST-NG.id
  }

  tags = {
    "Name" = format("%s-%s", var.aws_default_name, "PRIVATE-ROUTE")
  }
}


## Route Table Routing
# Create Public Route Table Routing
resource "aws_route_table_association" "PR-TEST-PUBROUTING" {
  count = length(var.aws_public_subnets)

  route_table_id = aws_route_table.PR-TEST-PUBROUTE.id
  subnet_id      = aws_subnet.PR-TEST-PUBSUB.*.id[count.index]
}
# Create Private Route Table Routing
resource "aws_route_table_association" "PR-TEST-PRIROUTING" {
  count = length(var.aws_private_subnets)

  route_table_id = aws_route_table.PR-TEST-PRIROUTE.id
  subnet_id      = aws_subnet.PR-TEST-PRISUB.*.id[count.index]
}