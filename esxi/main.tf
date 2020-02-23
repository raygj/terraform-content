provider "esxi" {
  esxi_hostname = "${var.host}"
  esxi_hostport = "22"
  esxi_username = "root"
  esxi_password = "${var.admin_password}"
}

resource "esxi_guest" "homelab" {
  guest_name = "${var.guest_name}"
  disk_store = "${var.disk_store}"
  memsize    = "${var.memsize}"
  numvcpus   = "4"
  power      = "on"
  notes      = "consul minikube node ${var.guest_number}"

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
}

provisioner "file" {
  source      = "/templates/bootstrap.sh"
  destination = "/tmp/bootstrap.sh"

  connection {
    type        = "ssh"
    user        = "jray"
    private_key = "${var.private_key}"
    host        = "esxi_guest.homelab.ipaddress" // not sure ipaddress is correct here
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "./tmp/hashistack_setup.sh",
    ]
  }
}
