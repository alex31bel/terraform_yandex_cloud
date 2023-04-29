terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  token     = "${var.token_ya}"
  cloud_id  = "${var.cloud_id_ya}"
  folder_id = "${var.folder_id_ya}"
  zone      = "ru-central1-a"
}