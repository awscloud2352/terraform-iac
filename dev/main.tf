provider "aws" {
    region = "ap-south-1"
}

module "infra_services" {
  source = "../modules/services/infra_services"
  cloud_env = "dev"
  vpc_tag_name = "dev_vpc"
  instance_count = "1"
  instance_type = "t3.micro"
  vpc_cidr = "172.31.0.0/16"
  public_cidrs = ["172.31.3.0/24","172.31.4.0/24"]
  private_cidrs = ["172.31.5.0/24","172.31.6.0/24"]
  public_cidr = "172.31.1.0/24"
  private_cidr = "172.31.2.0/24"
  bucket_name = "scoop-testing-terraform-s3-bucket-data-2026"
  instance_key_name = "custom-keypair"
  add_eip = false
}
