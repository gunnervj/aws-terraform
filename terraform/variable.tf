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
