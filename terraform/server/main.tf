provider "aws" {
  region = var.region
  assume_role {
    role_arn    = var.assume_role.role_arn
    external_id = var.assume_role.external_id
  }
}

terraform {
  backend "s3" {
    bucket = "nsse-terraform-state-files"
    key    = "server/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "nsse-terraform-state-locking"
  }
}
