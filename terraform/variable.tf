variable "created_by" {
  type        = string
  description = "Will be added a tag in the resources."
}

variable "region" {
  type        = string
  description = "AWS Region where the resource creation has to happen."
  default     = "ap-south-1"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC."
}

variable "project" {
  type        = string
  description = "Name for the Project for which resources are being created"
  default     = "aws-terraform"
}

variable "additional_default_tags" {
  type        = map(string)
  description = "These will be the default tags for the resources."
}

variable "public_subnet_count" {
  type    = number
  default = 1
  validation {
    condition     = var.public_subnet_count <= 3
    error_message = "Maximum Allowed Public Subnet Count is 3."
  }
}

variable "private_subnet_count" {
  type    = number
  default = 1
  validation {
    condition     = var.private_subnet_count <= 3
    error_message = "Maximum Allowed Private Subnet Count is 3."
  }
}

variable "enable_nat_gateway" {
  type    = bool
  default = true
}

variable "additional_public_ingress_nacl_rules" {
  type        = list(any)
  description = "List of Public NACL Rules.NACL Rule can be of format: { from_port : 443, to_port : 443, rule_no : 100, cidr : \"0.0.0.0/0\", action : \"allow\", protocol: \"tcp\" }"
}

variable "additional_public_egress_nacl_rules" {
  type        = list(any)
  description = "List of Public NACL Rules.NACL Rule can be of format: { from_port : 443, to_port : 443, rule_no : 100, cidr : \"0.0.0.0/0\", action : \"allow\", protocol: \"tcp\" }"
}

variable "additional_private_ingress_nacl_rules" {
  type        = list(any)
  description = "List of private NACL Rules.NACL Rule can be of format: { from_port : 443, to_port : 443, rule_no : 100, cidr : \"0.0.0.0/0\", action : \"allow\", protocol: \"tcp\" }"
}

variable "additional_private_egress_nacl_rules" {
  type        = list(any)
  description = "List of Private NACL Rules.NACL Rule can be of format: { from_port : 443, to_port : 443, rule_no : 100, cidr : \"0.0.0.0/0\", action : \"allow\", protocol: \"tcp\" }"
}

variable "ecs-task-memory" {
  type        = number
  description = "Memory for an ECS Container(in GB)."
  default     = 1
}

variable "ecs-task-cpu" {
  type        = number
  description = "vCPU for an ECS Container"
  default     = 1
}

variable "database_instance_type" {
  type        = string
  description = "Database Instance Type"
  default     = "t2.micro"
}

variable "db_private_ip" {
  type        = string
  description = "Private IP for the database."
  default     = "10.0.48.255"
}

variable "db_ec2_key_pair" {
  type        = string
  description = "EC2 Key Pair for DB."
  default     = "my-keypair"
}

variable "database_service_name" {
  type        = string
  description = "Database Service Name"
  default     = "database"
}

variable "database_message" {
  type        = string
  description = "Database Message"
  default     = "Hello from the database"
}

variable "consul_server_count" {
  type        = number
  description = "Number of consul servers"
  default     = 3
}

variable "consul_server_instance_type" {
  type        = string
  description = "Consul Server Instance Type"
  default     = "t2.micro"
}

variable "consul_server_allowed_cidr_blocks" {
  type        = list(string)
  description = "List of valid IPv4 CIDR blocks that can access the consul servers from the public internet."
  default     = ["0.0.0.0/0"]
}