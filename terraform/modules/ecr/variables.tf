variable "services" {
  type    = list(string)
  default = ["web", "orders-api", "worker"]
}
