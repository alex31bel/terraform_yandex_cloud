output "instance_external_ip" {
  value = "${data.yandex_compute_instance_group.ig-1.instances.*.network_interface.0.nat_ip_address}"
}