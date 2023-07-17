terraform {
  required_providers {
    vsphere = {
      source = "hashicorp/vsphere"
    }
  }
  required_version = ">=1.5"
}

provider "vsphere" {
  allow_unverified_ssl = true
}