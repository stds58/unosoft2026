terraform {
  required_version = ">= 1.10.5"
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.193"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.7"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

provider "yandex" {
  service_account_key_file = file("authorized_key.json")
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zone
}
