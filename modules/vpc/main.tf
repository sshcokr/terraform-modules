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
    "Name" = format("%s/%s", var.global_tags, "VPC")
  }
}


# Setting Subnet
# Create Public Subnet
resource "aws_subnet" "PR-TEST-PUBSUB" {
  count             = length(var.aws_public_subnets)
  cidr_block        = var.aws_public_subnets[count.index]
  vpc_id            = aws_vpc.PR-TEST-VPC.id
  # EKS node group에 자동으로 IP 할당을 해주기위함.
  map_public_ip_on_launch = true

  availability_zone = var.aws_azs[count.index]
  tags = {
    "Name" = format("%s/%s", var.global_tags, "public${count.index + 1}")
    "kubernetes.io/role/elb"= 1
  }
}

# Create Private Subnet
resource "aws_subnet" "PR-TEST-PRISUB" {
  count             = length(var.aws_private_subnets)
  cidr_block        = var.aws_private_subnets[count.index]
  vpc_id            = aws_vpc.PR-TEST-VPC.id
  availability_zone = var.aws_azs[count.index]
  tags = {
    "Name" =  format("%s, %s", var.global_tags, "private${count.index + 1}")
    "kubernetes.io/role/internal-elb"= 1
  }
}

# Create IGW
resource "aws_internet_gateway" "PR-TEST-IGW" {
  vpc_id = aws_vpc.PR-TEST-VPC.id

  tags = {
    "Name" = format("%s, %s", var.global_tags, "IGW")
  }
}

# Create EIP for Nat Gateway
resource "aws_eip" "EIP" {
  count = length(var.aws_azs)
  vpc   = true
}

# Create Nat Gateway
resource "aws_nat_gateway" "PR-TEST-NG" {
  count = length(var.aws_public_subnets)
  allocation_id = element(aws_eip.EIP.*.id, count.index)
  subnet_id     = element(aws_subnet.PR-TEST-PUBSUB.*.id, count.index)

  tags = {
    "Name" = format("%s, %s", var.global_tags, "Nat-Gateway")
  }

  depends_on = [
    aws_internet_gateway.PR-TEST-IGW,
    aws_eip.EIP,
    aws_subnet.PR-TEST-PUBSUB
  ]
}



## Route Table
# Create Public Route Table
resource "aws_route_table" "PR-TEST-PUBROUTE" {
  vpc_id = aws_vpc.PR-TEST-VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.PR-TEST-IGW.id
  }

  tags = {
    "Name" = format("%s, %s", var.global_tags, "Public-Route-Table")
  }
}
# Create Private Route Table !!!
resource "aws_route_table" "PR-TEST-PRIROUTE" {
  count = length(var.aws_azs)

  vpc_id = aws_vpc.PR-TEST-VPC.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.PR-TEST-NG.*.id[count.index]
  }

  tags = {
    "Name" = format("%s, %s", var.global_tags, "Private-Route-Table")
  }
}


## Route Table Routing
# Create Public Route Table Routing
resource "aws_route_table_association" "PR-TEST-PUBROUTING" {
  count = length(var.aws_azs)

  route_table_id = aws_route_table.PR-TEST-PUBROUTE.id
  subnet_id      = aws_subnet.PR-TEST-PUBSUB.*.id[count.index]

  depends_on = [aws_subnet.PR-TEST-PUBSUB]
}
# Create Private Route Table Routing
resource "aws_route_table_association" "PR-TEST-PRIROUTING" {
  count = length(var.aws_azs)

  route_table_id = aws_route_table.PR-TEST-PRIROUTE.*.id[count.index]
  subnet_id      = aws_subnet.PR-TEST-PRISUB.*.id[count.index]
}