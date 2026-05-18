resource "aws_vpc" "terraform_test_vpc" {
  # cidr_block           = 172.31.0.0/16
  cidr_block         = "172.31.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
 
  tags = {
    Name = "terraform_test_vpc"
  }
}

