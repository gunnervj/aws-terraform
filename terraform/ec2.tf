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

  depends_on = [
    aws_nat_gateway.my_nat_gateway
  ]
}

resource "aws_instance" "consul-server" {
  count                       = var.consul_server_count
  ami                         = data.aws_ami.ec2_ami.id
  instance_type               = var.consul_server_instance_type
  subnet_id                   = aws_subnet.my-private-subnet[count.index].id
  key_name                    = var.db_ec2_key_pair
  associate_public_ip_address = false
  private_ip                  = local.server_private_ips[count.index]

  vpc_security_group_ids = [aws_security_group.consul-server-sg.id]

  iam_instance_profile = aws_iam_instance_profile.consul_instance_profile.name

  tags = {
    "Name" = "${var.project}-consul-server-${count.index}"
  }

  user_data = base64encode(templatefile("${path.module}/scripts/server.sh", {

  }))

  depends_on = [
    aws_nat_gateway.my_nat_gateway
  ]
}

