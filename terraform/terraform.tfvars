created_by                            = "vj_nair"
vpc_cidr                              = "10.0.0.0/16"
additional_default_tags               = {}
public_subnet_count                   = 2
private_subnet_count                  = 2
enable_nat_gateway                    = true
additional_public_ingress_nacl_rules  = []
additional_public_egress_nacl_rules   = []
additional_private_ingress_nacl_rules = []
additional_private_egress_nacl_rules  = []
db_ec2_key_pair                       = "test"
db_private_ip                         = "10.0.47.253"