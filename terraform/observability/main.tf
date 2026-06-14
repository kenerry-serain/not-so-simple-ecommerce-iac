terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    opensearch = {
      source  = "opensearch-project/opensearch"
      version = "~> 2.3"
    }
  }
  backend "s3" {
    bucket         = "nsse-terraform-state-files"
    key            = "observability/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "nsse-terraform-state-locking"
  }
}

provider "aws" {
  region = var.region
  assume_role {
    role_arn    = var.assume_role.role_arn
    external_id = var.assume_role.external_id
  }
}

provider "opensearch" {
  url               = "https://${aws_opensearch_domain.logs.endpoint}"
  username          = "admin"
  password          = var.opensearch_master_password
  healthcheck       = false
  sign_aws_requests = false
}
