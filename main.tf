data "vsphere_datacenter" "dc" {
  name = var.datacenter
}

data "vsphere_datastore" "ds" {
  name          = var.datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_compute_cluster" "clus" {
  name          = var.cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "pg" {
  name          = var.network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.template
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "vm" {
  for_each = var.vm_config

  name     = upper(each.key)
  num_cpus = lookup(local.sizes, each.value.size, "small").cpu
  memory   = lookup(local.sizes, each.value.size, "small").memory

  resource_pool_id = data.vsphere_compute_cluster.clus.resource_pool_id
  datastore_id     = data.vsphere_datastore.ds.id

  firmware                   = data.vsphere_virtual_machine.template.firmware
  hardware_version           = data.vsphere_virtual_machine.template.hardware_version
  guest_id                   = data.vsphere_virtual_machine.template.guest_id
  efi_secure_boot_enabled    = data.vsphere_virtual_machine.template.efi_secure_boot_enabled
  wait_for_guest_net_timeout = each.value.ip == [] ? 0 : 5

  cpu_hot_add_enabled    = var.hot_add_enabled
  memory_hot_add_enabled = var.hot_add_enabled

  dynamic "disk" {
    for_each = each.value.disks
    content {
      label       = "disk${disk.key}"
      size        = disk.value
      unit_number = disk.key
    }
  }

  dynamic "network_interface" {
    for_each = each.value.ip == [] ? [1] : each.value.ip
    content {
      network_id = data.vsphere_network.pg.id
    }
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.uuid
    customize {
      dynamic "linux_options" {
        for_each = var.windows_image == false ? [1] : []
        content {
          host_name = upper(each.key)
          domain    = var.domain
        }
      }

      dynamic "windows_options" {
        for_each = var.windows_image == true ? [1] : []
        content {
          computer_name = upper(each.key)
        }
      }

      ipv4_gateway    = var.gateway
      dns_server_list = var.dns_servers

      dynamic "network_interface" {
        for_each = each.value.ip
        iterator = network
        content {
          ipv4_address = network.value == "" ? null : split("/", each.value.ip[network.key])[0]
          ipv4_netmask = network.value == "" ? null : split("/", each.value.ip[network.key])[1]
        }
      }
    }
  }
}
