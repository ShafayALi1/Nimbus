variable "name" {
  description = "Name prefix for every resource"
  type        = string
}

variable "cidr" {
  description = "VPC address range"
  type        = string
  default     = "10.0.0.0/16"
}

variable "enable_nat" {
  description = "Give private subnets outbound internet (costs money on real AWS)"
  type        = bool
  default     = false
}
