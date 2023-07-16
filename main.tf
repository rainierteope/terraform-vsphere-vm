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
  for_each = var.virtual_machines

  name     = upper(each.key)
  num_cpus = lookup(local.sizes, var.size, "small").cpu
  memory   = lookup(local.sizes, var.size, "small").memory

  resource_pool_id = data.vsphere_compute_cluster.clus.resource_pool_id
  datastore_id     = data.vsphere_datastore.ds.id

  firmware                = data.vsphere_virtual_machine.template.firmware
  hardware_version        = data.vsphere_virtual_machine.template.hardware_version
  guest_id                = data.vsphere_virtual_machine.template.guest_id
  efi_secure_boot_enabled = data.vsphere_virtual_machine.template.efi_secure_boot_enabled

  cpu_hot_add_enabled    = each.value.hot_add_enabled != null ? each.value.hot_add_enabled : false
  memory_hot_add_enabled = each.value.hot_add_enabled != null ? each.value.hot_add_enabled : false

  dynamic "disk" {
    for_each = each.value.disks
    content {
      label       = "disk${disk.key}"
      size        = disk.value
      unit_number = disk.key
    }
  }

  dynamic "network_interface" {
    for_each = each.value.ip_address != null ? each.value.ip_address : [1]
    content {
      network_id = data.vsphere_network.pg.id
    }
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.uuid
    customize {
      dynamic "linux_options" {
        for_each = each.value.windows_image == false ? [1] : []
        content {
          host_name = upper(each.key)
          domain    = each.value.domain != null ? each.value.domain : "domain.local"
        }
      }

      dynamic "windows_options" {
        for_each = each.value.windows_image == true ? [1] : []
        content {
          computer_name = upper(each.key)
        }
      }

      ipv4_gateway    = each.value.gateway != null ? each.value.gateway : null
      dns_server_list = each.value.dns_servers != null ? each.value.dns_servers : null

      dynamic "network_interface" {
        for_each = each.value.ip_address != null ? each.value.ip_address : []
        iterator = network
        content {
          ipv4_address = each.value.ip_address != null ? split("/", each.value.ip_address[network.key])[0] : null
          ipv4_netmask = each.value.ip_address != null ? split("/", each.value.ip_address[network.key])[1] : null
        }
      }
    }
  }
}
