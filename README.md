
# Terraform vSphere VM


This module creates one or more vSphere virtual machines in your target environment.



## Usage

Create your project directory and change your present working directory
```bash
mkdir <directory-name> && cd <directory-name>
```

Export your vSphere credentials as environment variables
```bash
export VSPHERE_SERVER="<VCENTER-IP>"
export VSPHERE_USER="<VCENTER-USER>"
export VSPHERE_PASSWORD="<VCENTER-PASSWORD>"
export VSPHERE_ALLOW_UNVERIFIED_SSL=false
```

Create main.tf in your project directory
```bash
touch main.tf
```

Inside main.tf, create the following configuration
```
module "module_name" {    # Module name can be anything you want
  datacenter      = (Required) The virtual datacenter where the VM will reside in.
  datastore       = (Required) The datastore where the VM files will be stored.
  cluster         = (Required) The cluster where the VM will reside in.
  network         = (Required) The port group where the VM nics will be attached to by default.
  template        = (Required) The name of the virtual machine template.
  windows_image   = (Optional) Set this variable to true if the template is a windows image. Defaults to false.
  folder          = (Optional) The folder where the virtual machines will be stored.
  vm_config       = (Required) The configuration of each virtual machine. 

###########################################################################################################################################
##  vm_config parameters:                                                                                                                ##
##  disks           = (Required) List of virtual disks sizes.                                                                            ##
##  size            = (Optional) The size of the virtual machine. Defaults to small if not set.                                          ##
##  ip              = (Optional) List of ip addresses and subnet mask in cidr notation. Defaults to 1 network interface if not set.      ##
##  hot_add_enabled = (Optional) Set this parameter to true if cpu and memory hot-add should be enabled. Defaults to false if not set.   ##
##  dns_servers     = (Optional) List of DNS servers which the VMs will use. Defaults to an empty list [] if not set.                    ##
##  gateway         = (Optional) The default IPv4 gateway for your VMs. Defaults to "" if not set.                                       ##
##  domain          = (Optional) The domain of the VM. Defaults to "" if not set.                                                        ##
###########################################################################################################################################

}
```

Example vm_config block with all parameters defined
```
vm_config = {
  vm01 = {
    size            = "medium"                              # Size of the VM
    disks           = [50, 100]                             # List of disks sizes
    ip              = ["192.168.200.170/24", ""]            # List of IP addresses, set to "" for dhcp
    domain          = "automation.com"                      # Domain of the VM
    gateway         = "192.168.200.1"                       # Default gateway of the VM
    dns_servers     = ["192.168.200.200", "8.8.8.8"]        # List of DNS servers for the VM
    hot_add_enabled = true                                  # Enable cpu and memory hot-add for the VM
  }
}
```

Example usage with optional values configured
```
module "module_name" {
  datacenter      = "AutomationDC"
  datastore       = "Prod-Datastore01"
  cluster         = "AutomationCluster"
  network         = "VM Network"
  folder          = "terraform-managed"
  template        = "RHLSLAB"
  windows_image   = false
  vm_config       = {
    rhelvm01 = {
      size            = "medium"                              # Size of the VM
      disks           = [50, 100]                             # List of disks sizes
      ip              = ["192.168.200.170/24", ""]            # List of IP addresses, set to "" for dhcp
      domain          = "automation.com"                      # Domain of the VM
      gateway         = "192.168.200.1"                       # Default gateway of the VM
      dns_servers     = ["192.168.200.200", "8.8.8.8"]        # List of DNS servers for the VM
      hot_add_enabled = true                                  # Enable cpu and memory hot-add for the VM
    }
    rhelvm01 = {
      size            = "large"                               # Size of the VM
      disks           = [100, 200]                            # List of disks sizes
      ip              = ["", ""]                              # List of IP addresses, set to "" for dhcp
      domain          = "automation.com"                      # Domain of the VM
      gateway         = "192.168.200.1"                       # Default gateway of the VM
      dns_servers     = ["192.168.200.200", "8.8.8.8"]        # List of DNS servers for the VM
      hot_add_enabled = true                                  # Enable cpu and memory hot-add for the VM
    }
  }
}
```

Example usage with minimal configuration and no ip address set
```
module "module_name" {
  datacenter      = "AutomationDC"
  datastore       = "Prod-Datastore01"
  cluster         = "AutomationCluster"
  network         = "VM Network"
  template        = "RHLSLAB"
  vm_config       = {
    rhelvm01 = {       # Small VM with 1 disk and 1 network interface
      disks = [50]     
    }
    rhelvm01 = {       # Small VM with 1 disk and 2 network interfaces
      disks = [100]    
      ip    = ["", ""]
    }
  }
}
```

Available sizes
```
small  = 1 vcpu 2gb memory
medium = 2 vcpu 4gb memory
large  = 4 vcpu 8gb memory
```

## Authors

- [@rainierteope](https://www.github.com/rainierteope)

