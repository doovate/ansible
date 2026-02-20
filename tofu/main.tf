# DATA SOURCES - Get data from NetBox
# Get the virtual machine
data "netbox_virtual_machines" "base_vm" {
  name_regex = var.hostname
}

locals {
  vm_exists = length(data.netbox_virtual_machines.base_vm.vms) > 0
}

# Validate if the selected host exists
resource "null_resource" "vm_validation" {
  lifecycle {
    precondition {
      condition     = local.vm_exists
      error_message = "Virtual machine '${var.hostname}' not found in Netbox. Please verify the hostname is correct."
    }
  }
}

# Get the cluster this vm is in
data "netbox_cluster" "vm_cluster" {
  count = local.vm_exists ? 1 : 0
  id    = data.netbox_virtual_machines.base_vm.vms[0].cluster_id
}

data "netbox_tags" "vm_tags" {
  for_each = local.vm_exists ? toset([for id in data.netbox_virtual_machines.base_vm.vms[0].tag_ids : tostring(id)]) : toset([])

  filter {
    name  = "id"
    value = tonumber(each.value)
  }
}

# Set needed variables
locals {
  vm_name        = local.vm_exists ? data.netbox_virtual_machines.base_vm.vms[0].name : null
  vm_cluster     = local.vm_exists ? data.netbox_cluster.vm_cluster[0].name : null
  vm_description = local.vm_exists ? data.netbox_virtual_machines.base_vm.vms[0].description : null
  vm_cpu_type = local.vm_exists ? data.netbox_virtual_machines.base_vm.vms[0].custom_fields["cpu_type"] : null
  vm_vcpus   = local.vm_exists ? data.netbox_virtual_machines.base_vm.vms[0].vcpus : null
  vm_memory  = local.vm_exists ? ceil(data.netbox_virtual_machines.base_vm.vms[0].memory_mb / 1024) * 1024 : null
  vm_disk_gb = local.vm_exists ? data.netbox_virtual_machines.base_vm.vms[0].disk_size_mb / 1000 : null
  vm_ip4     = local.vm_exists ? data.netbox_virtual_machines.base_vm.vms[0].primary_ip4 : null
  vm_tag_names = local.vm_exists ? [
    for ds in data.netbox_tags.vm_tags :
    ds.tags[0].name
  ] : []
}


resource "proxmox_vm_qemu" "vm" {
  lifecycle {
    prevent_destroy = true
  }

  name        = local.vm_name
  description = local.vm_description
  target_node = local.vm_cluster

  agent = 1
  clone = var.template

  cpu {
    type    = local.vm_cpu_type
    cores   = local.vm_vcpus
    sockets = var.cpu_sockets
    numa    = var.numa
  }

  memory  = local.vm_memory
  balloon = local.vm_memory / 2
  hotplug = "disk,network,usb"
  onboot  = var.onboot
  tags    = join(";", local.vm_tag_names)

  network {
    id       = 0
    bridge   = "vmbr1"
    model    = "virtio"
    firewall = false
  }

  disks {
    scsi {
      scsi2 {
        disk {
          size    = "${local.vm_disk_gb}G"
          storage = var.datastore
          cache   = "writeback"
          discard = true
        }
      }
      scsi1 {
        cloudinit {
          storage = var.datastore
        }
      }
    }
  }

  bootdisk     = "scsi0"
  boot         = "order=scsi2"
  os_type      = var.os_type
  ipconfig0    = "ip=${local.vm_ip4},gw=${var.gateway}"
  nameserver   = join(",", var.dns_servers)
  searchdomain = join(" ", var.search_domains)
  ciuser       = var.tsg_user
  cipassword   = var.tsg_password
  sshkeys      = <<EOF
${var.tsg_key}
EOF

  connection {
    type     = "ssh"
    host     = split("/", local.vm_ip4)[0]
    user     = var.tsg_user
    password = var.tsg_password
    timeout  = "10m"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Esperando a que cloud-init termine...'",
      "sudo cloud-init status --wait || sudo bash -c 'while [ ! -f /var/lib/cloud/instance/boot-finished ]; do sleep 2; done'",
      "echo 'cloud-init finalizado.'"
    ]
  }

  provisioner "file" {
    source      = "scripts/install.sh"
    destination = "/tmp/install.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install.sh",
      "sudo /tmp/install.sh"
    ]
  }
}