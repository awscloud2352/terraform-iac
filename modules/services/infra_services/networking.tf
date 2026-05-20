data "aws_availability_zones" "available" {}

resource "random_id" "random" {
  byte_length = 2
}

resource "aws_vpc" "terraform_test_vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.cloud_env}_terraform_test_vpc"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_internet_gateway" "terraform_test_internet_gateway" {
  vpc_id = aws_vpc.terraform_test_vpc.id

  tags = {
    Name = "${var.cloud_env}_terraform_test_internet_gateway"
  }
}

resource "aws_route_table" "terraform_public_rt" {
  vpc_id = aws_vpc.terraform_test_vpc.id

  tags = {
    Name = "${var.cloud_env}_terraform_public_route_table"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.terraform_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.terraform_test_internet_gateway.id
}

resource "aws_default_route_table" "terraform_private_rt" {
  default_route_table_id = aws_vpc.terraform_test_vpc.default_route_table_id

  tags = {
    Name = "${var.cloud_env}_terraform_private_rt"
  }
}

resource "aws_subnet" "terraform_public_test_subnet" {
  count                   = 2
  //count                   = length(var.public_cidrs)
  vpc_id                  = aws_vpc.terraform_test_vpc.id
  cidr_block              = var.public_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.cloud_env}_terraform_public_test_subnet"
  }
}

resource "aws_subnet" "terraform_private_test_subnet" {
  count                   = 2
  //count                   = length(var.private_cidrs)
  vpc_id     = aws_vpc.terraform_test_vpc.id
  cidr_block = var.private_cidrs[count.index]
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.cloud_env}_terraform_private_test_subnet"
  }
}

resource "aws_route_table_association" "terraform_public_subnet_association" {
  count                   = 2
  subnet_id      = aws_subnet.terraform_public_test_subnet.*.id[count.index]
  route_table_id = aws_route_table.terraform_public_rt.id
}

resource "aws_route_table_association" "terraform_private_subnet_association" {
  count                   = 2
  subnet_id      = aws_subnet.terraform_private_test_subnet.*.id[count.index]
  route_table_id = aws_default_route_table.terraform_private_rt.id
}

resource "aws_security_group" "terraform_test_sg" {
  name        = "terraform_test_sg"
  description = "Security group for public instances"
  vpc_id      = aws_vpc.terraform_test_vpc.id

  # Dynamic Egress Rules
  dynamic "egress" {
    for_each = var.security_group_rules.egress
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  # Dynamic Ingress Rules
  dynamic "ingress" {
    for_each = var.security_group_rules.ingress
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
}

resource "aws_eip" "terraform_test_eip" {
    instance = "${element(aws_instance.terraform_test_ec2.*.id,count.index)}"
    count    = var.add_eip ? var.instance_count : 0
    domain   = "vpc"
}

output "vpc_id" {
  value = aws_vpc.terraform_test_vpc.id
}