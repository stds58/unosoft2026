module "network" {
  source = "./modules/network"

  name = "uno_network"
}

module "subnetwork" {
  source = "./modules/subnet"

  subnet_name    = "uno_subnetwork"
  zone           = "ru-central1-a"
  v4_cidr_blocks = ["192.168.1.0/24"]
  network_id     = module.network.network_id
}

module "sg_bastion" {
  source = "./modules/security-groups"

  network_id          = module.network.network_id
  security_group_name = "sg-bastion"
  ingress_rules       = local.sg_bastion_ingress_rules
  egress_rules        = local.sg_bastion_egress_rules
}

module "sg_cassandra_cluster" {
  source = "./modules/security-groups"

  network_id          = module.network.network_id
  security_group_name = "sg-cassandra-nodes"
  ingress_rules       = local.sg_cassandra_ingress_rules
  egress_rules        = local.sg_cassandra_egress_rules

}

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2404-lts"
}

module "vm-a" {
  source = "./modules/instance"

  name               = "a_server"
  platform_id        = "standard-v3"
  zone               = "ru-central1-a"
  cores              = 2
  memory             = 8
  core_fraction      = 100
  image_id           = data.yandex_compute_image.ubuntu.id
  disk_size          = 20
  disk_type          = "network-ssd"
  network_interfaces = local.cassandra_interfaces
  ssh_key_path       = format("%s/%s.pub", pathexpand(var.ssh_base_path), var.cluster_key_name)
  role               = "cassandra"
}

module "vm-b" {
  source = "./modules/instance"

  name               = "b_server"
  platform_id        = "standard-v3"
  zone               = "ru-central1-a"
  cores              = 2
  memory             = 8
  core_fraction      = 100
  image_id           = data.yandex_compute_image.ubuntu.id
  disk_size          = 20
  disk_type          = "network-ssd"
  network_interfaces = local.bastion_interfaces
  ssh_key_path       = format("%s/%s.pub", pathexpand(var.ssh_base_path), var.bastion_key_name)
  role               = "bastion"
}

resource "null_resource" "copy_private_key_to_vm1" {
  depends_on = [module.vm-b]

  connection {
    type        = "ssh"
    host        = module.vm-b.external_ip_address
    user        = "ubuntu"
    private_key = file(format("%s/%s", pathexpand(var.ssh_base_path), var.bastion_key_name))
  }

  provisioner "file" {
    source      = format("%s/%s", pathexpand(var.ssh_base_path), var.cluster_key_name)
    destination = "/home/ubuntu/.ssh/${var.cluster_key_name}"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 600 /home/ubuntu/.ssh/${var.cluster_key_name}",
      "chown ubuntu:ubuntu /home/ubuntu/.ssh/${var.cluster_key_name}"
    ]
  }
}
