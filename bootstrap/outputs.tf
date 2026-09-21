output "control_node_ip" {
  value = proxmox_virtual_environment_container.control_guest.ipv4["eth0"]
}