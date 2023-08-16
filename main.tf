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

resource "vsphere_folder" "folder" {
  count         = var.folder != null ? 1 : 0
  path          = var.folder
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "vm" {
  for_each = var.vm_config
  depends_on = [ vsphere_folder.folder ]

  name     = each.key
  num_cpus = each.value.size != null ? lookup(local.sizes, each.value.size, "small").cpu : lookup(local.sizes, "small").cpu
  memory   = each.value.size != null ? lookup(local.sizes, each.value.size, "small").memory : lookup(local.sizes, "small").memory

  resource_pool_id = data.vsphere_compute_cluster.clus.resource_pool_id
  datastore_id     = data.vsphere_datastore.ds.id
  folder           = var.folder

  firmware                   = data.vsphere_virtual_machine.template.firmware
  hardware_version           = data.vsphere_virtual_machine.template.hardware_version
  guest_id                   = data.vsphere_virtual_machine.template.guest_id
  efi_secure_boot_enabled    = data.vsphere_virtual_machine.template.efi_secure_boot_enabled
  wait_for_guest_net_timeout = each.value.ip == null ? 0 : 5

  cpu_hot_add_enabled    = each.value.hot_add_enabled
  memory_hot_add_enabled = each.value.hot_add_enabled

  dynamic "disk" {
    for_each = each.value.disks
    content {
      label       = "disk${disk.key}"
      size        = disk.value
      unit_number = disk.key
    }
  }

  dynamic "network_interface" {
    for_each = each.value.ip != null ? each.value.ip : [1]
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
          host_name = each.key
          domain    = each.value.domain
        }
      }

      dynamic "windows_options" {
        for_each = var.windows_image == true ? [1] : []
        content {
          computer_name = upper(each.key)
        }
      }

      ipv4_gateway    = each.value.gateway
      dns_server_list = each.value.dns_servers

      dynamic "network_interface" {
        for_each = each.value.ip != null ? each.value.ip : [1]
        iterator = network
        content {
          ipv4_address = each.value.ip != null ? network.value != "" ? split("/", network.value)[0] : null : null
          ipv4_netmask = each.value.ip != null ? network.value != "" ? split("/", network.value)[1] : null : null
        }
      }
    }
  }
}
