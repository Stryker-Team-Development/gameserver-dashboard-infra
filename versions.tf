terraform {
  backend "s3" {
    bucket = "new-aleochoam-terraform-states"
    key    = "valheim-dashboard/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "new-aleochoam"
  version = "~> 3.29.0"
}
