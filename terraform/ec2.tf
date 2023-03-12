
data "aws_ami" "ec2_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20230208"]
  }
}

resource "aws_instance" "database" {
  ami                    = data.aws_ami.ec2_ami.id
  instance_type          = var.database_instance_type
  vpc_security_group_ids = [aws_security_group.private-databases-sg.id]
  private_ip             = var.db_private_ip
  key_name               = var.db_ec2_key_pair
  subnet_id              = aws_subnet.my-private-subnet[0].id

  user_data = base64encode(templatefile("${path.module}/scripts/database.sh", {
    DATABASE_SERVICE_NAME = var.database_service_name,
    DATABASE_MESSAGE      = var.database_message
  }))

  tags = {
    "Name" = "${var.project}-database"
  }
}

