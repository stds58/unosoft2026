resource "yandex_compute_instance" "vm" {
  name        = var.name
  platform_id = var.platform_id
  zone        = var.zone

  resources {
    cores         = var.cores
    memory        = var.memory
    core_fraction = var.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = var.disk_size
      type     = var.disk_type
    }
  }

  dynamic "network_interface" {
    for_each = var.network_interfaces
    iterator = iface

    content {
      subnet_id          = iface.value.subnet_id
      ip_address         = iface.value.ip_address
      nat                = iface.value.nat
      security_group_ids = iface.value.security_group_ids
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_key_path)}"
  }

  labels = {
    environment = "develop"
    terraform   = "true"
    role        = var.role
  }

}