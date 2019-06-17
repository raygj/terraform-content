# Objective
- Use TF OSS and community ESXi provider to provision VMs on my local ESXi box. 
- Why? Having a local “DC” is awesome and manually installing an OS on a VM is time consuming (free ESXi does not support templates).

# Components
- HP z220 workstation with Xeon 3.4GHz | 24 GB RAM | 232GB SSD and 300GB SATA
- VMware ESXi 6.7 (or better, freeware license)
	- Existing VMs with VMware-Tools or Open-VM-Tools installed as source for cloning operation
- 
Mac with Terraform OSS 11.14 binary and terraform set in the user path


# Terraform ESXi Provider
https://github.com/josenk/terraform-provider-esxi
- Community provider, recently updated for TF 0.12 with a large number of resources

# Walkthrough

## Download VMware OVF tool
https://my.vmware.com/group/vmware/details?downloadGroup=OVFTOOL430&productId=742

- run Mac installer
- test install
`ovftool --help`

***NOTE** _if help output does not display, you need to set the path to the ovftool_

```
nano ~/.bash_profile

#vmwware ovftool
export PATH=$PATH:/Applications/VMware\ OVF\ Tool/
complete -C /Applications/VMware\ OVF\ Tool/ovftool ovftool
```

***NOTE*** _if you receive this message during terraform apply, the resolution is to set the ovftool path_

```
Error: Error applying plan:

1 error occurred:
	* esxi_guest.vmtest: 1 error occurred:
	* esxi_guest.vmtest: There was an ovftool Error:
exit status 127
```

## Install go
`brew install go`

### Set go path
`nano ~/.bash_profile`

`export GOPATH=$HOME/go`

## Clone repo
`git clone https://github.com/josenk/terraform-provider-esxi.git $GOPATH/src/github.com/terraform-providers/terraform-provider-esxi`

## Compile Provider

```
cd $GOPATH/src/github.com/josenk/terraform-provider-esxi

go get -u -v golang.org/x/crypto/ssh

go get -u -v github.com/hashicorp/terraform

go get -u -v github.com/josenk/terraform-provider-esxi

cd $GOPATH/src/github.com/josenk/terraform-provider-esxi

CGO_ENABLED=0 GOOS=darwin GOARCH=amd64 go build -a -ldflags '-w -extldflags "-static"' -o terraform-provider-esxi_`cat version`

sudo cp terraform-provider-esxi_`cat version` /Users/jray/hashi/terraform/esxi-sandbox
```

***NOTE*** _GOOS= value should match destination operating system; such as linux,darwin_
https://github.com/golang/go/blob/master/src/go/build/syslist.go

### Copy compiled provider to the terraform directory

`cd /Users/jray/go/src/github.com/terraform-providers/terraform-provider-esxi`

# Test provider with terraform

`terraform init`

## Possible error messages

- you used the pre-compiled version of provider and it does not match your local OS
`* provider.esxi: fork/exec /home/jray/terraform/terraform-provider-esxi_v1.4.3: permission denied`

- you compiled a version of the provider but specified the wrong GOOS value
`* provider.esxi: fork/exec /Users/jray/hashi/terraform/esxi-sandbox/terraform-provider-esxi_v1.4.3: exec format error`

## Create main.tf for test run
- There are many resource options, this is a basic config
- Note that the `nic_type` value should match your ESXi installation

```
cat << EOF > ~/terraform/main.tf

provider "esxi" {
  esxi_hostname = "192.168.1.228"
  esxi_hostport = "22"
  esxi_username = "root"
  esxi_password = "< root password>"
}

resource "esxi_guest" "vmtest" {
  guest_name = "tf-nginx"
  disk_store = "SSD"
  memsize    = "1024"
  numvcpus   = "4"
  power      = "on"
  notes      = "ubuntu 18.04 LTS"

  #
  #  Specify an existing guest to clone, an ovf source, or neither to build a bare-metal guest vm.
  #
  #ovf_source        = "/local_path/centos-7.vmx"

  clone_from_vm = "nginx" # just provide source VM name, VM should be powered off
  network_interfaces = [
    {
      virtual_network = "VM Network"
      nic_type          = "vmxnet3"
    },
  ]
}
EOF
```

***NOTE*** _if you get this error after committing terraform apply_

- the source VM is probably on/running
	- the source VM should be powered off
- the _Export VM_ task will start, but no the _Import VApp_ task
	- cancel the _Export VM_ task and make sure the source VM is powered off before attempting another `terraform apply`

```
Error: Error applying plan:

1 error occurred:
	* esxi_guest.vmtest: 1 error occurred:
	* esxi_guest.vmtest: There was an ovftool Error: Opening VI source: vi://root@192.168.1.228:443/vaultmon
Error: Fault cause: vim.fault.TaskInProgress

Completed with errors

exit status 1
```
# Next Steps
- Create vanilla VMs for Ubuntu and CentOS that can be used as source templates
- Use Packer to create custom VMs that can be used as source templates
- Play with 
