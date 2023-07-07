# Create a VPC
resource "aws_vpc" "manuchims_vpc" {
  cidr_block           = "10.123.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "dev"
  }
}

resource "aws_subnet" "dev_public_subnet" {
  vpc_id                  = aws_vpc.manuchims_vpc.id
  cidr_block              = "10.123.0.0/25"
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-1a"

  tags = {
    Name = "dev-public"
  }
}

resource "aws_internet_gateway" "dev_public_gateway" {
  vpc_id = aws_vpc.manuchims_vpc.id

  tags = {
    Name = "dev-public-internet-gateway"
  }
}

resource "aws_route_table" "dev_public_route_table" {
  vpc_id = aws_vpc.manuchims_vpc.id

  tags = {
    Name = "dev_public_route_table"
  }

}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.dev_public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.dev_public_gateway.id
}

resource "aws_route_table_association" "dev_route_table_association" {
  subnet_id      = aws_subnet.dev_public_subnet.id
  route_table_id = aws_route_table.dev_public_route_table.id
}

resource "aws_security_group" "sec_group" {
  name        = "dev_sec_group"
  description = "dev security group"
  vpc_id      = aws_vpc.manuchims_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "dev_auth" {
  key_name   = "dev-key"
  public_key = file("~/.ssh/devkey.pub")
}

resource "aws_instance" "dev_node" {
  ami                    = data.aws_ami.server_ami.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.dev_auth.id
  vpc_security_group_ids = [aws_security_group.sec_group.id]
  subnet_id              = aws_subnet.dev_public_subnet.id
  user_data              = file("userdata.tpl")

  tags = {
    Name = "dev-node"
  }

  root_block_device {
    volume_size = 10
  }

  provisioner "local-exec" {
    command = templatefile("${var.host_os}-ssh-config.tpl", {
      hostname     = self.public_ip,
      user         = "ubuntu",
      identityfile = "~/.ssh/devkey"
    })
    interpreter = var.host_os == "windows" ? ["Powershell", "-Command"] : ["bash", "-c"]
  }
}