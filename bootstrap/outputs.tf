output "control_node_ip" {
  value = proxmox_virtual_environment_container.control_guest.ipv4["eth0"]
}

output "control_node_vmid" {
  description = "control node's id."
  value       = proxmox_virtual_environment_container.control_guest.vm_id
}