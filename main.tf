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

resource "yandex_compute_instance" "vm" {
  count = 2

  name        = "vm${count.index}"
  platform_id = "standard-v3"

  resources {
    cores  = "1"
    memory = "2"
    core_fraction = "20"
  }

  boot_disk {
    initialize_params {
      image_id = "${var.image_id_ya}"
      size = 3
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-1.id}"
    nat       = true
  }

  metadata = {
    user-data = file("./main.yaml")
  }

  scheduling_policy {
    preemptible = true #Создание прерываемой ВМ для экономии баланса при обучении
  }
}

resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-a"
  v4_cidr_blocks = ["192.168.10.0/24"]
  network_id     = "${yandex_vpc_network.network-1.id}"
}

#Создание целевой группы Network Load Balancer
resource "yandex_lb_target_group" "target-1" {
  name      = "target1"
  target {
    subnet_id = "yandex_vpc_subnet.subnet-1.id"
    address   = "yandex_compute_instance.vm[0].network_interface.0.ip_address"
  }
  target {
    subnet_id = "yandex_vpc_subnet.subnet-1.id"
    address   = "yandex_compute_instance.vm[1].network_interface.0.ip_address"
  }
}

#Создание сетевого балансировщика
resource "yandex_lb_network_load_balancer" "lb-1" {
  name = "lb1"
  listener {
    name = "my-list"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }
  attached_target_group {
    target_group_id = "yandex_lb_target_group.target-1.id"
    healthcheck {
      name = "http"
      http_options {
        port = 80
        path = "/"
      }
    }
  }
}

#Создание снимка
resource "yandex_compute_snapshot" "snapshot-1" {
  name           = "disk-snapshot1"
  source_disk_id = "yandex_compute_instance.vm[0].boot_disk[0].disk_id"
}