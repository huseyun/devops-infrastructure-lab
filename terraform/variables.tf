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
    condition = alltrue([for rol in values(guests) : contains(keys(var.guest_specs), rol)])
    error_message = "every guest should point to a defined guest spec."
  }
}