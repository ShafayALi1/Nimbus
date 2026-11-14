variable "name" {
  type = string
}

variable "db_secret_arn" {
  description = "The only secret the app may read"
  type        = string
}

variable "oidc_provider_arn" {
  description = "EKS OIDC provider for IRSA. Leave null outside EKS."
  type        = string
  default     = null
}
