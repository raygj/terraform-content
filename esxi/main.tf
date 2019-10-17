provider "esxi" {
  esxi_hostname = "192.168.1.228"
  esxi_hostport = "22"
  esxi_username = "root"
  esxi_password = "<password>"    //look into pulling this from a var
}

resource "esxi_guest" "homelab" {
  guest_name = "${var.guest_name}"
  disk_store = "${var.disk_store}"
  memsize    = "${var.memsize}"
  numvcpus   = "4"
  power      = "on"
  notes      = "hashistack node ${var.guest_number}"

  #
  #  Specify an existing guest to clone, an ovf source, or neither to build a bare-metal guest vm.
  #
  #ovf_source        = "/local_path/${var.os}.vmx"

  clone_from_vm = "${var.os}-template"
  network_interfaces = [
    {
      virtual_network = "VM Network"
      nic_type        = "vmxnet3"
    },
  ]
  provisioner "file" {
    source      = "/templates/hashistack_setup.sh"
    destination = "/tmp/hashistack_setup.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/hashistack_setup.sh",
      "./tmp/hashistack_setup.sh",
    ]
  }
}
