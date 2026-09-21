variable "template_file" {
  description = "the complete path to the LXC template that will be used to create the control node."
  type        = string
}

variable "node_specifications" {
  description = "all minimum specifications required to work on a node."
  type = object({
    name                   = string
    lvmthin_storage_name   = optional(string, "local-lvm")
    directory_storage_name = optional(string, "local")
    network_bridge_name    = optional(string, "vmbr0")
  })
}

variable "ssh_public_key_path" {
  type        = string
  description = "path to the operator device public key."
  default     = "~/.ssh/id_ed25519_homelab.pub"
}