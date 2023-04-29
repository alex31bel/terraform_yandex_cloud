output "internal-vm-1" {
  value = "${yandex_compute_instance.vm[0].network_interface.0.ip_address}"
}
output "internal-vm-2" {
  value = "${yandex_compute_instance.vm[1].network_interface.0.ip_address}"
}