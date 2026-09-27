variable "node_specifications" {
  description = "all minimum specifications required to work on a node."
  type = object({
    name                   = string
    lvmthin_storage_name   = optional(string, "local-lvm")
    directory_storage_name = optional(string, "local")
    network_bridge_name    = optional(string, "vmbr0")
  })
}

variable "control_plane_pubkey_path" {
  description = "public key of control node. terraform should only run from control node."
  type        = string
  default     = "~/.ssh/id_ed25519.pub"

  validation {
    condition = try(
      endswith(trimspace(file(pathexpand(var.control_plane_pubkey_path))), "control-plane@node-control"),
      false
    )
    error_message = "Okunan public key kontrol duzlemine ait degil (etiket 'control-plane@node-control' degil) ya da dosya yok. terraform/ yalnizca control node'dan calistirilir."
  }
}

variable "guest_specs" {
  description = "pre-defined specs for required host types."
  type = map(object({
    memory = number
    cores  = number
  }))
}

variable "guests" {
  description = "list of all guests. the value should point to a guest_specs value."
  type        = map(string)
  validation {
    condition = alltrue([for rol in values(var.guests) : contains(keys(var.guest_specs), rol)])
    error_message = "every guest should point to a defined guest spec."
  }
}

