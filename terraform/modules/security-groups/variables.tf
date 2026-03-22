variable "network_id" {
  description = "ID of the VPC network."
  type        = string
}

variable "security_group_name" {
  description = "Name of the security group."
  type        = string
}

variable "ingress_rules" {
  description = "List of ingress rules for the security group."
  type = list(object({
      protocol       = string
      port           = number
      description    = string
      v4_cidr_blocks = list(string)
    }))
  default = []
}
