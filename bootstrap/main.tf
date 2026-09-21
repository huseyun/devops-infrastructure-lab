resource "proxmox_virtual_environment_container" "control_guest" {
  node_name    = local.node_name
  unprivileged = true

  features {
    nesting = true
  }

  initialization {
    hostname = "node-control"
    ip_config {
      ipv4 { address = "dhcp" }
    }

    user_account {
      keys = [trimspace(file(pathexpand(var.ssh_public_key_path)))]
    }
  }



  cpu {
    cores = 1
  }

  memory {
    dedicated = 1024
  }

  disk {
    datastore_id = local.lvmthin_storage_name
    size         = 10
  }

  network_interface {
    name   = "eth0"
    bridge = local.network_bridge_name
  }

  operating_system {
    template_file_id = var.template_file
    type             = "debian"
  }
}

locals {
  lvmthin_storage_name = var.node_specifications.lvmthin_storage_name
  network_bridge_name  = var.node_specifications.network_bridge_name
  node_name            = var.node_specifications.name
}