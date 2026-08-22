resource "proxmox_virtual_environment_container" "ilk_guest" {
  node_name    = "pve"
  vm_id        = 200
  unprivileged = true

  initialization {
    hostname = "ilk-guest"
    ip_config {
      ipv4 { address = "dhcp" }
    }
    # user_account { password = "gecici-parola" }
  }

  cpu {
    cores = 1
  }

  memory {
    dedicated = 512
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