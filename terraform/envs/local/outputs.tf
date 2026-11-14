output "vpc_id" {
  value = module.network.vpc_id
}

output "private_subnet_ids" {
  value = module.network.private_subnet_ids
}

output "db_secret_arn" {
  value = module.secrets.db_secret_arn
}

output "orders_api_role_arn" {
  value = module.iam.orders_api_role_arn
}
