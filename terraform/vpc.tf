
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
  count                           = var.public_subnet_count
  vpc_id                          = aws_vpc.my-vpc.id
  cidr_block                      = local.public_cidr_blocks[count.index]
  ipv6_cidr_block                 = cidrsubnet(aws_vpc.my-vpc.ipv6_cidr_block, 8, count.index)
  assign_ipv6_address_on_creation = true
  map_public_ip_on_launch         = true
  availability_zone               = data.aws_availability_zones.available.names[count.index]

  tags = {
    "Name" = "${var.project}-public-${data.aws_availability_zones.available.names[count.index]}"
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
  count          = var.public_subnet_count
  route_table_id = aws_route_table.my-public-route-table.id
  subnet_id      = element(aws_subnet.my-public-subnet.*.id, count.index)
}



# private subnet
resource "aws_subnet" "my-private-subnet" {
  count             = var.private_subnet_count
  vpc_id            = aws_vpc.my-vpc.id
  cidr_block        = local.private_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    "Name" = "${var.project}-private-${data.aws_availability_zones.available.names[count.index]}"
  }
}


# Elastic IP for NAT
resource "aws_eip" "nat_gateway_eip" {
  vpc   = true
  count = local.is_nat_gateway_enabled
  tags = {
    "Name" = "${var.project}-nat-gateway-eip"
  }
}

# NAT gateway
resource "aws_nat_gateway" "my_nat_gateway" {
  count         = local.is_nat_gateway_enabled
  allocation_id = length(aws_eip.nat_gateway_eip[*]) == 0 ? "" : element(aws_eip.nat_gateway_eip[*].id, count.index)
  subnet_id     = aws_subnet.my-public-subnet[0].id

  tags = {
    "Name" = "${var.project}-nat-gateway"
  }
  depends_on = [
    aws_internet_gateway.my-internet-gateway
  ]
}

# private route tables and routes
resource "aws_route_table" "my-private-route-table" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    "Name" = "${var.project}-private-rt"
  }

}

resource "aws_route" "my-private-route-to-nat" {
  count                  = local.is_nat_gateway_enabled
  route_table_id         = aws_route_table.my-private-route-table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.my_nat_gateway[0].id
}

resource "aws_route_table_association" "my-private-route-table-asso" {
  count          = var.private_subnet_count
  route_table_id = aws_route_table.my-private-route-table.id
  subnet_id      = element(aws_subnet.my-private-subnet[*].id, count.index)
}

