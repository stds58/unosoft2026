locals {
  sg_bastion_ingress_rules = [
    {
      protocol       = "tcp"
      port           = 22
      description    = "SSH from Admin PC"
      v4_cidr_blocks = ["0.0.0.0/0"]
    },
    {
      protocol       = "tcp"
      port           = 3128
      description    = "HTTP Proxy from Internal Network"
      v4_cidr_blocks = ["192.168.1.0/24"]
    }
  ]
}