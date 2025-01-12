output "instance_external_ip" {
  description = "External IP address of the GPU instance"
  value       = nebius_compute_v1_instance.gpu_instance.status.network_interfaces[0].public_ip_address.address
}

output "instance_internal_ip" {
  description = "Internal IP address of the GPU instance"
  value       = nebius_compute_v1_instance.gpu_instance.status.network_interfaces[0].ip_address.address
}
