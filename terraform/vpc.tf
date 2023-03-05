locals {
  is_nat_gateway_enabled = var.enable_nat_gateway ? 1 : 0
  default_ingress_nacl_rules_public = setunion(var.additional_public_ingress_nacl_rules, [
    { from_port : 443, to_port : 443, rule_no : 100, cidr : "0.0.0.0/0", action : "allow", protocol : "tcp" },
    { from_port : 80, to_port : 80, rule_no : 110, cidr : "0.0.0.0/0", action : "allow", protocol : "tcp" },
    { from_port : 22, to_port : 22, rule_no : 120, cidr : "0.0.0.0/0", action : "allow", protocol : "tcp" }
  ])

  default_egress_nacl_rules_public = setunion(var.additional_public_egress_nacl_rules, [
    { from_port : 443, to_port : 443, rule_no : 100, cidr : "0.0.0.0/0", action : "allow", protocol : "tcp" },
    { from_port : 80, to_port : 80, rule_no : 110, cidr : "0.0.0.0/0", action : "allow", protocol : "tcp" },
    { from_port : 22, to_port : 22, rule_no : 120, cidr : "0.0.0.0/0", action : "allow", protocol : "tcp" }
  ])

  default_egress_nacl_rules_private = setunion(var.additional_private_egress_nacl_rules, [
    { from_port : 0, to_port : 0, rule_no : 100, cidr : var.vpc_cidr, action : "allow", protocol : "-1" }
  ])

  default_ingress_nacl_rules_private = setunion(var.additional_private_egress_nacl_rules, [
    { from_port : 0, to_port : 0, rule_no : 100, cidr : var.vpc_cidr, action : "allow", protocol : "-1" }
  ])
}


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
  cidr_block                      = cidrsubnet(aws_vpc.my-vpc.cidr_block, 8, count.index)
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

resource "aws_network_acl" "my-public-nacl" {
  vpc_id = aws_vpc.my-vpc.id

  dynamic "ingress" {
    for_each = [for rule in local.default_ingress_nacl_rules_public : {
      from_port  = rule.from_port
      to_port    = rule.to_port
      rule_no    = rule.rule_no
      cidr_block = rule.cidr
      action     = rule.action
      protocol   = rule.protocol
    }]
    content {
      protocol   = ingress.value["protocol"]
      rule_no    = ingress.value["rule_no"]
      action     = ingress.value["action"]
      cidr_block = ingress.value["cidr_block"]
      from_port  = ingress.value["from_port"]
      to_port    = ingress.value["to_port"]
    }
  }

  dynamic "egress" {
    for_each = [for rule in local.default_egress_nacl_rules_public : {
      from_port  = rule.from_port
      to_port    = rule.to_port
      rule_no    = rule.rule_no
      cidr_block = rule.cidr
      action     = rule.action
      protocol   = rule.protocol
    }]
    content {
      protocol   = egress.value["protocol"]
      rule_no    = egress.value["rule_no"]
      action     = egress.value["action"]
      cidr_block = egress.value["cidr_block"]
      from_port  = egress.value["from_port"]
      to_port    = egress.value["to_port"]
    }
  }

  tags = {
    "Name" = "${var.project}-public-nacl"
  }
}

resource "aws_network_acl_association" "public-nacl-asso" {
  count          = var.public_subnet_count
  network_acl_id = aws_network_acl.my-public-nacl.id
  subnet_id      = element(aws_subnet.my-public-subnet[*].id, count.index)
}

# private subnet
resource "aws_subnet" "my-private-subnet" {
  count             = var.private_subnet_count
  vpc_id            = aws_vpc.my-vpc.id
  cidr_block        = cidrsubnet(aws_vpc.my-vpc.cidr_block, 4, count.index + var.public_subnet_count)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    "Name" = "${var.project}-private-${data.aws_availability_zones.available.names[count.index]}"
  }
}

resource "aws_network_acl" "my-private-nacl" {
  vpc_id = aws_vpc.my-vpc.id

  dynamic "ingress" {
    for_each = [for rule in local.default_ingress_nacl_rules_private : {
      from_port  = rule.from_port
      to_port    = rule.to_port
      rule_no    = rule.rule_no
      cidr_block = rule.cidr
      action     = rule.action
      protocol   = rule.protocol
    }]
    content {
      protocol   = ingress.value["protocol"]
      rule_no    = ingress.value["rule_no"]
      action     = ingress.value["action"]
      cidr_block = ingress.value["cidr_block"]
      from_port  = ingress.value["from_port"]
      to_port    = ingress.value["to_port"]
    }
  }

  dynamic "egress" {
    for_each = [for rule in local.default_egress_nacl_rules_private : {
      from_port  = rule.from_port
      to_port    = rule.to_port
      rule_no    = rule.rule_no
      cidr_block = rule.cidr
      action     = rule.action
      protocol   = rule.protocol
    }]
    content {
      protocol   = egress.value["protocol"]
      rule_no    = egress.value["rule_no"]
      action     = egress.value["action"]
      cidr_block = egress.value["cidr_block"]
      from_port  = egress.value["from_port"]
      to_port    = egress.value["to_port"]
    }
  }

  tags = {
    "Name" = "${var.project}-private-nacl"
  }
}

resource "aws_network_acl_association" "private-nacl-asso" {
  count          = var.private_subnet_count
  network_acl_id = aws_network_acl.my-private-nacl.id
  subnet_id      = element(aws_subnet.my-private-subnet[*].id, count.index)
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

