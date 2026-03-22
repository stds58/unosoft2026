
variable "zone" {
  description = "Use specific availability zone"
  type        = string
  default     = "ru-central1-a"
}

variable "subnet_name" {
  description = "Имя подсети"
  type        = string
}

variable "v4_cidr_blocks" {
  description = "CIDR блоки для подсети"
  type        = list(string)
}

variable "network_id" {
  description = "ID of the VPC network"
  type        = string
}
