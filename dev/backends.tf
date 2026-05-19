terraform {
  backend "s3" {
    bucket = "mum-iac-backend-bkt"
    key    = "terraform_states/dev.tfstate"
    region = "ap-south-1"
    use_lockfile = true
  }
}
