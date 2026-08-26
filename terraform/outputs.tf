output "coklu_guest_ipadresleri" {
  value = {
    // k anahtar, guest anahtar içindeki tüm vm özellikleri
    for k, guest in proxmox_virtual_environment_container.dev_guests :
    k => guest.ipv4
  }
}

output "node_isimleri" {
  value = data.proxmox_virtual_environment_nodes.tum_nodelar.names
}