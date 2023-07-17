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

variable "template" {
  type        = string
  description = "Name of the virtual machine template"
}

variable "windows_image" {
  type        = bool
  description = "Set to true if the template is a windows image"
  default     = false
}

variable "hot_add_enabled" {
  type        = bool
  description = "Set to true if cpu and memory hot add should be enabled"
  default     = false
}

variable "vm_config" {
  type        = map(object({size = string, disks = list(number), ip = list(string)}))
  description = "Configuration of the virtual machines"
}

variable "dns_servers" {
  type        = list(string)
  description = "List of DNS servers"
  default     = []
}

variable "gateway" {
  type        = string
  description = "Default gateway for the virtual machines"
  default     = ""
}

variable "domain" {
  type        = string
  description = "Domain of the virtual machines"
  default     = ""
}