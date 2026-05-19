// https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
data "aws_ami" "server_ami" {
  most_recent = true
  owners = ["amazon"]
  filter {
      name = "owner-alias"
      values = ["amazon"]
  }
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*-x86_64-gp2"]
  }
}

// Resource referencing from another file i.e networking.tf
resource "aws_instance" "terraform_test_ec2" {
  count         = var.instance_count
  instance_type = var.instance_type
  ami           = data.aws_ami.server_ami.id
  key_name      = var.instance_key_name

  vpc_security_group_ids = [aws_security_group.terraform_test_sg.id]
  subnet_id              = aws_subnet.terraform_public_test_subnet[count.index].id

  root_block_device {
    volume_size = var.vol_size
  }

  tags = var.instance_tags
  // Optionally, static tags can also be defined
  /*
  tags = {
    Name = "terraform_test_ec2_${count.index}"
  }
  */

}

output "instance_info" {
  value = {
    instance_id = aws_instance.terraform_test_ec2[*].id
    public_ip   = aws_instance.terraform_test_ec2[*].public_ip
  }
}