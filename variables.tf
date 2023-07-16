variable "datacenter" {
  type = string
  description = "Name of the virtual datacenter"
}

variable "datastore" {
  type = string
  description = "Name of the datastore"
}

variable "cluster" {
  type = string
  description = "Name of the compute cluster"
}

variable "network" {
  type = string
  description = "Name of the default port group"
}

variable "template" {
  type = string
  description = "Name of the virtual machine template"
}

variable "virtual_machines" {
  type = map(map(any))
  description = "Configuration of the virtual machines"
}