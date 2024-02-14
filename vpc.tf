resource "aws_vpc" "vpc_Ohio" {
  cidr_block = var.ohio_cidr
  tags = {
    "Name" = "Vpc_ohio-${local.sufix}"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc_Ohio.id
  cidr_block              = var.subnets[0]
  map_public_ip_on_launch = true
  tags = {
    "Name" = "Public Subnet-${local.sufix}"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.vpc_Ohio.id
  cidr_block = var.subnets[1]
  tags = {
    "Name" = "Private Subnet-${local.sufix}"
  }
  depends_on = [
    aws_subnet.public_subnet
  ]
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_Ohio.id

  tags = {
    Name = "igw vpc ohio-${local.sufix}"
  }
}

# resource "aws_internet_gateway" "name" {
#   vpc_id = var.vpc_id
#   tags = {
#     Name = "igw vpc ohio"
#   }
# }

resource "aws_route_table" "public_crt" {
  vpc_id = aws_vpc.vpc_Ohio.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public crt-${local.sufix}"
  }
}

resource "aws_route_table_association" "crta_public_subnet" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_crt.id
}

resource "aws_security_group" "sg_public_instance" {
  name        = "Public Instance SG"
  description = "Allow SSH inbound traffic and ALL egress traffic"
  vpc_id      = aws_vpc.vpc_Ohio.id

  /* ingress {
    description = "SSH over Internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.sg_ingress_cidr]
  } */


  dynamic "ingress" {
    for_each = var.ingress_ports_list
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = [var.sg_ingress_cidr]
    }
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Public Instance SG-${local.sufix}"
  }
}

/* resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  description       = "SSH over Internet"
  security_group_id = aws_security_group.sg_public_instance.id
  cidr_ipv4         = var.sg_ingress_cidr
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.sg_public_instance.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
} */
