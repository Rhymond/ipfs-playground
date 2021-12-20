terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "2.70.0"
    }
  }

  backend "s3" {
    bucket = "ipfs-state"
    key    = "terraform_state.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  region = var.aws_region
}



