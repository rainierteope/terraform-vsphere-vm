
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
```hcl
module "module_name" {    # Module name can be anything you want
  datacenter      = (Required) The virtual datacenter where the VM will reside in.
  datastore       = (Required) The datastore where the VM files will be stored.
  cluster         = (Required) The cluster where the VM will reside in.
  network         = (Required) The port group where the VM nics will be attached to by default.
  template        = (Required) The name of the virtual machine template.
  vm_config       = (Required) The configuration of each virtual machine. The parameters are size, disks, and ip.

  windows_image   = (Optional) Set this variable to true if the template is a windows image. Defaults to false.
  hot_add_enabled = (Optional) Set this variable to true if cpu and memory hot-add should be enabled. Defaults to false.
  dns_servers     = (Optional) List of DNS servers which the VMs will use. Defaults to an empty list [].
  gateway         = (Optional) The default IPv4 gateway for your VMs.
  domain          = (Optional) The domain of the VM.
}
```

Example vm_config block
```hcl
vm_config = {
  vm01 = {                         # VM Name
    size = "medium"                # Size of the VM. Check the available sizes below.
    disks = [50, 200]              # A list of disks sizes
    ip    = ["192.168.0.1/24"]     # A list of ip addresses with subnet mask in cidr notation
  }
}
```

Example usage with optional values configured
```hcl
module "module_name" {
  datacenter      = "AutomationDC"
  datastore       = "Prod-Datastore01"
  cluster         = "AutomationCluster"
  network         = "VM Network"
  template        = "RHLSLAB"
  vm_config       = {
    rhelvm01 = {
      size  = "small"
      disks = [50, 100]                                       # 2 disks
      ip    = ["192.168.200.171/24", "192.168.200.172/24"]    # 2 network interfaces
    }
    rhelvm02 = {
      size  = "medium"
      disks = [100]                                            # 1 disk
      ip    = ["192.168.200.173/24"]                           # 1 network interface 
    }
  }

  windows_image   = false
  hot_add_enabled = true
  dns_servers     = ["192.168.200.200", "8.8.8.8"]
  gateway         = "192.168.200.1"
  domain          = "automation.com"
}
```

Example usage with minimal configuration and no ip address set
```hcl
module "module_name" {
  datacenter      = "AutomationDC"
  datastore       = "Prod-Datastore01"
  cluster         = "AutomationCluster"
  network         = "VM Network"
  template        = "RHLSLAB"
  vm_config       = {
    rhelvm01 = {    
      size  = "small"
      disks = [50, 100]    # 2 disks
      ip    = ["", ""]     # 2 network interfaces
    }
    rhelvm02 = {
      size  = "medium"
      disks = [100]        # 1 disk
      ip    = [""]         # 1 network interface
    }
  }
}
```

Available sizes
```hcl
small  = 1 vcpu 2gb memory
medium = 2 vcpu 4gb memory
large  = 4 vcpu 8gb memory
```

## Authors

- [@rainierteope](https://www.github.com/rainierteope)

