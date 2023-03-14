data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "ec2_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20230208"]
  }
}
