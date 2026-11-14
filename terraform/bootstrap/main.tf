# Run once, first. Creates the S3 bucket that stores Terraform state and the DynamoDB table that locks it.
# Its own state stays local (the chicken-and-egg problem: the backend can't store the state that creates it).
terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 6.0" }
  }
}

provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    dynamodb       = "http://localhost:4566"
    ec2            = "http://localhost:4566"
    iam            = "http://localhost:4566"
    s3             = "http://localhost:4566"
    secretsmanager = "http://localhost:4566"
    sts            = "http://localhost:4566"
  }

  default_tags {
    tags = { project = "nimbus", env = "local", managed_by = "terraform" }
  }
}

resource "aws_s3_bucket" "state" {
  bucket        = "nimbus-tfstate"
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id
  versioning_configuration {
    status = "Enabled" # every state change is kept: you can roll the state back
  }
}

resource "aws_dynamodb_table" "lock" {
  name         = "nimbus-tflock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}
