# VPC 
resource "aws_vpc" "my-vpc" {
  cidr_block                       = var.vpc_cidr
  assign_generated_ipv6_cidr_block = true
  instance_tenancy                 = "default"
  enable_dns_support               = true
  enable_dns_hostnames             = true
  
  tags = {
    "Name" = "${var.project}-vpc"
  }
}

# internet gateway

resource "aws_internet_gateway" "my-internet-gateway" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    "Name" = "${var.project}-igw"
  }
}

# public subnet
resource "aws_subnet" "my-public-subnet" {
  vpc_id = aws_vpc.my-vpc.id
  # 10.255.0.0/20 -> 10.255.0.0/24
  cidr_block                      = cidrsubnet(aws_vpc.my-vpc.cidr_block, 4, 0)
  ipv6_cidr_block                 = cidrsubnet(aws_vpc.my-vpc.ipv6_cidr_block, 8, 0)
  assign_ipv6_address_on_creation = true
  map_public_ip_on_launch         = true
  availability_zone               = data.aws_availability_zones.available.names[0]

  tags = {
    "Name" = "${var.project}-public-${data.aws_availability_zones.available.names[0]}"
  }
}

# public route table and routes
resource "aws_route_table" "my-public-route-table" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    "Name" = "${var.project}-public-rt"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-internet-gateway.id
  }

}

resource "aws_route_table_association" "my-public-route-table-asso" {
  route_table_id = aws_route_table.my-public-route-table.id
  subnet_id      = aws_subnet.my-public-subnet.id
}

# private subnet

# private route tables and routes

# NAT gateway