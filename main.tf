provider "vsphere" {
  user                = "administrator@vsphere.local"
  password            = "Admin@345!"
  vsphere_server      = "https://10.0.1.6"
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = "Datacenter-01"
}

data "vsphere_datastore" "datastore" {
  name          = "vsanDatastore"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_compute_cluster" "cluster" {
  name          = "Management Cluster"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "network" {
  name          = "VM Network"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_virtual_machine" "template" {
  name          = "Gan_ubuntu"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

# Resource block to create the virtual machine
resource "vsphere_virtual_machine" "vm" {
  name             = "testga-vm"
  resource_pool_id = "${data.vsphere_compute_cluster.cluster.resource_pool_id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"

  num_cpus   = 2
  memory     = 8192
  guest_id   = "${data.vsphere_virtual_machine.template.guest_id}"
  scsi_type  = "${data.vsphere_virtual_machine.template.scsi_type}"

  network_interface {
    network_id   = "${data.vsphere_network.network.id}"
    adapter_type = "${data.vsphere_virtual_machine.template.network_interface_types[0]}"
  }

  disk {
    label = "disk0"
    size  = "${data.vsphere_virtual_machine.template.disks.0.size}"
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"

  }
}

