variable "datacenter" {
  type        = string
  description = "Name of the virtual datacenter"
}

variable "datastore" {
  type        = string
  description = "Name of the datastore"
}

variable "cluster" {
  type        = string
  description = "Name of the compute cluster"
}

variable "network" {
  type        = string
  description = "Name of the default port group"
}

variable "folder" {
  type = string
  description = "Folder of the VMs"
  default = null
}

variable "template" {
  type        = string
  description = "Name of the virtual machine template"
}

variable "windows_image" {
  type        = bool
  description = "Set to true if the template is a windows image"
  default     = false
}

variable "vm_config" {
  type = map(object({
    size            = optional(string)
    disks           = list(number)
    ip              = optional(list(string))
    domain          = optional(string, "")
    gateway         = optional(string, "")
    dns_servers     = optional(list(string), [])
    hot_add_enabled = optional(bool, false)
  }))
  description = "Configuration of the virtual machines"
}