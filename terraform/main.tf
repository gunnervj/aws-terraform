terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.57.0"
    }
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = merge(local.common_tags, var.additional_default_tags)
  }
}






