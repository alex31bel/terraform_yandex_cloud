output "internal-group-ig-1" {
  value = "${yandex_compute_instance_group.ig-1.network_interface.0.nat_ip_address}"
}