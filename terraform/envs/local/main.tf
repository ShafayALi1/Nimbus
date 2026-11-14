# Nimbus infrastructure on LocalStack (free). Same modules as envs/aws-dev; only the provider differs.
terraform {
  required_version = ">= 1.6"
  required_providers {
    aws    = { source = "hashicorp/aws", version = "~> 6.0" }
    random = { source = "hashicorp/random", version = "~> 3.6" }
  }

  backend "s3" {
    bucket         = "nimbus-tfstate"
    key            = "envs/local/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "nimbus-tflock" # two people running apply at once: the second waits for the lock
    access_key     = "test"
    secret_key     = "test"
    use_path_style = true

    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_region_validation      = true

    endpoints = {
      s3       = "http://localhost:4566"
      dynamodb = "http://localhost:4566"
      sts      = "http://localhost:4566"
    }
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

module "network" {
  source = "../../modules/network"
  name   = "nimbus-local"
}

module "secrets" {
  source = "../../modules/secrets"
  name   = "nimbus-local"
}

module "iam" {
  source        = "../../modules/iam"
  name          = "nimbus-local"
  db_secret_arn = module.secrets.db_secret_arn
}

# ECR, RDS and EKS are paid LocalStack features, so they only exist in envs/aws-dev.
