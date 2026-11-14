# REAL AWS. This costs money. Only for short, planned sessions on free credits:
#   1. set a budget alert first     2. terraform apply     3. do the exercise     4. terraform destroy (same day!)
# Needs the bootstrap bucket/table created on real AWS (copy ../../bootstrap, remove the LocalStack provider settings).
terraform {
  required_version = ">= 1.6"
  required_providers {
    aws    = { source = "hashicorp/aws", version = "~> 6.0" }
    random = { source = "hashicorp/random", version = "~> 3.6" }
  }
  backend "s3" {
    bucket       = "CHANGE-ME-nimbus-tfstate" # bucket names are global: add something unique
    key          = "envs/aws-dev/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true # Terraform 1.10+: S3 native locking, no DynamoDB table needed
  }
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = { project = "nimbus", env = "aws-dev", managed_by = "terraform" }
  }
}

module "network" {
  source     = "../../modules/network"
  name       = "nimbus-dev"
  enable_nat = false # EKS nodes in public subnets for the lab; set true for private nodes (+32 USD/month)
}

module "secrets" {
  source = "../../modules/secrets"
  name   = "nimbus-dev"
}

module "iam" {
  source        = "../../modules/iam"
  name          = "nimbus-dev"
  db_secret_arn = module.secrets.db_secret_arn
}

module "ecr" {
  source = "../../modules/ecr"
}

module "rds" {
  source             = "../../modules/rds"
  name               = "nimbus-dev"
  vpc_id             = module.network.vpc_id
  vpc_cidr           = module.network.vpc_cidr
  private_subnet_ids = module.network.private_subnet_ids
  password           = module.secrets.db_password
  multi_az           = false # true = production setting, double price
}

output "rds_endpoint" {
  value = module.rds.endpoint
}

output "ecr_repositories" {
  value = module.ecr.repository_urls
}
