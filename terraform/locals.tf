locals {
  common_tags = {
    "created_by"        = var.created_by
    "created_by_script" = "aws-terraform"
    "project"           = var.project
  }
  public_cidr_blocks  = [for i in range(var.public_subnet_count) : cidrsubnet(var.vpc_cidr, 4, i)]
  private_cidr_blocks = [for i in range(var.private_subnet_count) : cidrsubnet(var.vpc_cidr, 4, i + var.public_subnet_count)]
  server_private_ips  = [for i in local.private_cidr_blocks : cidrhost(i, 250)]

  is_nat_gateway_enabled = var.enable_nat_gateway ? 1 : 0
  default_ingress_nacl_rules_public = setunion(var.additional_public_ingress_nacl_rules, [
    { from_port : 443, to_port : 443, rule_no : 100, cidr : "0.0.0.0/0", action : "allow", protocol : "tcp" },
    { from_port : 80, to_port : 80, rule_no : 110, cidr : "0.0.0.0/0", action : "allow", protocol : "tcp" },
    { from_port : 22, to_port : 22, rule_no : 120, cidr : "0.0.0.0/0", action : "allow", protocol : "tcp" }
  ])

  default_egress_nacl_rules_public = setunion(var.additional_public_egress_nacl_rules, [
    { from_port : 0, to_port : 0, rule_no : 100, cidr : "0.0.0.0/0", action : "allow", protocol : "-1" }
  ])

  default_egress_nacl_rules_private = setunion(var.additional_private_egress_nacl_rules, [
    { from_port : 0, to_port : 0, rule_no : 100, cidr : "0.0.0.0/0", action : "allow", protocol : "-1" }
  ])

  default_ingress_nacl_rules_private = setunion(var.additional_private_egress_nacl_rules, [
    { from_port : 0, to_port : 0, rule_no : 100, cidr : var.vpc_cidr, action : "allow", protocol : "-1" },
    { from_port : 1024, to_port : 65535, rule_no : 110, cidr : "0.0.0.0/0", action : "allow", protocol : "tcp" }
  ])
}