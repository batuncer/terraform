resource "aws_vpc" "cfyvpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "cfyvpc"
  }
}

resource "aws_internet_gateway" "vpcgateway" {
  vpc_id = aws_vpc.cfyvpc.id

  tags = {
    Name = "vpcgateway"
  }
}

resource "aws_subnet" "publicsubnet" {
  vpc_id                  = aws_vpc.cfyvpc.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "publicsubnet-1"
  }
}

resource "aws_subnet" "privatesubnet" {
  vpc_id            = aws_vpc.cfyvpc.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = "${var.region}b"

  tags = {
    Name = "privatesubnet-1b"
  }
}

resource "aws_route_table" "publicsubnetrt" {
  vpc_id = aws_vpc.cfyvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpcgateway.id
  }

  tags = {
    Name = "route table for PUBLIC"
  }
}

resource "aws_route_table_association" "associationforpublicsubnet" {
  subnet_id      = aws_subnet.publicsubnet.id
  route_table_id = aws_route_table.publicsubnetrt.id
}

resource "aws_route_table" "privatesubnetrt" {
  vpc_id = aws_vpc.cfyvpc.id

  route {
    cidr_block = var.vpc_cidr
    gateway_id = "local"
  }

  tags = {
    Name = "route table for PRIVATE"
  }
}

resource "aws_route_table_association" "associationforprivatesubnet" {
  subnet_id      = aws_subnet.privatesubnet.id
  route_table_id = aws_route_table.privatesubnetrt.id
}

resource "aws_default_security_group" "aws_default_security_group" {
  vpc_id = aws_vpc.cfyvpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Security group"
  }
}

resource "aws_instance" "publicec2" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.publicsubnet.id
  vpc_security_group_ids      = [aws_default_security_group.aws_default_security_group.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y docker.io
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo docker run -d -p 80:80 nginx
              EOF

  tags = {
    Name = "Public EC2"
  }
}
