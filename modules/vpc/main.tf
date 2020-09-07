# Create VPC
resource "aws_vpc" "PR-TEST-VPC" {
  //  count = 2
  cidr_block           = var.cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags = {
    "Name" = "PR-TEST-VPC"
  }
}

# Set Default ACL
resource "aws_default_network_acl" "PR-TEST-ACL" {
  default_network_acl_id = aws_vpc.PR-TEST-VPC.default_network_acl_id

  ingress {
    action     = "allow"
    protocol   = "-1"
    rule_no    = 100
    from_port  = 0
    to_port    = 0
    cidr_block = "0.0.0.0/0"
  }

  egress {
    action     = "allow"
    protocol   = "-1"
    rule_no    = 100
    from_port  = 0
    to_port    = 0
    cidr_block = "0.0.0.0/0"
  }

  subnet_ids = concat(aws_subnet.PR-TEST-PUBSUB.*.id, aws_subnet.PR-TEST-PRISUB.*.id)

  tags = {
    "Name" = "PR-TEST-ACL"
  }
}

# Set Default SG
resource "aws_default_security_group" "PR-TEST-SG" {
  vpc_id = aws_vpc.PR-TEST-VPC.id
# Allow SSH
  ingress {
    protocol  = "tcp"
    from_port = 22
    to_port   = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
# Allow HTTP
  ingress {
    protocol  = "tcp"
    from_port = 80
    to_port   = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "PR-TEST-SG"
  }
}

# Create Public Subnet
resource "aws_subnet" "PR-TEST-PUBSUB" {
  count             = length(var.public_subnets)
  cidr_block        = var.public_subnets[count.index]
  vpc_id            = aws_vpc.PR-TEST-VPC.id
  availability_zone = var.azs[count.index]

  tags = {
    "Name" = "PR-TEST-PUBSUB"
  }
}

# Create Private Subnet
resource "aws_subnet" "PR-TEST-PRISUB" {
  count             = length(var.private_subnets)
  cidr_block        = var.private_subnets[count.index]
  vpc_id            = aws_vpc.PR-TEST-VPC.id
  availability_zone = var.azs[count.index]

  tags = {
    "Name" = "PR-TEST-PRISUB"
  }
}

# Create IGW
resource "aws_internet_gateway" "PR-TEST-IGW" {
  vpc_id = aws_vpc.PR-TEST-VPC.id

  tags = {
    Name = "PR-TEST-IGW"
  }
}

# Create EIP for Nat Gateway
resource "aws_eip" "EIP" {
  count = length(var.azs)
  vpc   = true
}

# Create Nat Gateway
resource "aws_nat_gateway" "PR-TEST-NG" {
  count = length(var.azs)

  allocation_id = aws_eip.EIP.*.id[count.index]
  subnet_id     = aws_subnet.PR-TEST-PRISUB.*.id[count.index]

  tags = {
    "Name" = "PR-TEST-NG"
  }
}


# Create Public Route Table
resource "aws_route_table" "PR-TEST-PUBROUTE" {
  vpc_id = aws_vpc.PR-TEST-VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.PR-TEST-IGW.id
  }

  tags = {
    "Name" = "PR-TEST-PUBROUTE"
  }
}

# Create Private Route Table
resource "aws_route_table" "PR-TEST-PRIROUTE" {
  count = length(aws_nat_gateway.PR-TEST-NG)

  vpc_id = aws_vpc.PR-TEST-VPC.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.PR-TEST-NG.*.id[count.index]
  }

  tags = {
    "Name" = "PR-TEST-PRIROUTE"
  }
}

# Create Public Route Table Routing
resource "aws_route_table_association" "PR-TEST-PUBROUTING" {
  count = length(aws_subnet.PR-TEST-PUBSUB)

  route_table_id = aws_route_table.PR-TEST-PUBROUTE.id
  subnet_id      = aws_subnet.PR-TEST-PUBSUB.*.id[count.index]

}

# Create Private Route Table Routing
resource "aws_route_table_association" "PR-TEST-PRIROUTING" {
  count = length(aws_subnet.PR-TEST-PRISUB)

  route_table_id = aws_route_table.PR-TEST-PRIROUTE.*.id[count.index]
  subnet_id      = aws_subnet.PR-TEST-PRISUB.*.id[count.index]

}