resource "proxmox_virtual_environment_container" "dev_guests" {
  for_each = local.guest_configuration

  node_name    = local.node_name
  unprivileged = true

  features {
    nesting = true
  }

  initialization {
    hostname = each.value.hostname
    ip_config {
      ipv4 { address = "dhcp" }
    }
    # user_account { password = "gecici-parola" }
  }

  cpu {
    cores = each.value.cores
  }

  memory {
    dedicated = each.value.memory
  }

  disk {
    datastore_id = "local-lvm"
    size         = 8
  }

  network_interface {
    name   = "eth0"
    bridge = "vmbr0"
  }

  operating_system {
    template_file_id = "local:vztmpl/debian-13-standard_13.6-1_amd64.tar.zst"
    type             = "debian"
  }
}

locals {
  node_name = data.proxmox_virtual_environment_nodes.tum_nodelar.names[0]
  guest_configuration = {
    for guest_name, guest_spec in var.guests : guest_name => {
      hostname = "test-${guest_name}"
      cores    = var.guest_specs[guest_spec].cores
      memory   = var.guest_specs[guest_spec].memory
    }
  }
}