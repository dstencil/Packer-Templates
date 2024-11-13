packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.3"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}
variable "proxmox_url" {
  type    = string
  default = "https://ipaddress/api2/json"
}

variable "proxmox_username" {
  type    = string
  default = "root@pam"
}

variable "proxmox_password" {
  type    = string
  default = "password"
}

variable "node" {
  description = "Proxmox node to create the template on"
  type        = string
  default     = "pve"
}

variable "vm_id" {
  type    = string
  default = "9001"
}

variable "lab_username" {
    type    = string
    default = "ubuntu"
}

variable "lab_password" {
    type    = string
    default = "ubuntu"
}
variable "storage_name" {
  type = string
  default = "local-lvm"
}

variable "netbridge" {
  type = string
  default = "vmbr0"
}
source "proxmox-iso" "ubuntu-22" {
  proxmox_url             = var.proxmox_url
  node                    = var.node
  username                = var.proxmox_username
  password                = var.proxmox_password
  communicator            = "ssh"
  ssh_username            = var.lab_username
  ssh_password            = var.lab_password
  ssh_timeout             = "30m"
  qemu_agent              = true
  cores                   = 6
  cpu_type                = "host"
  memory                  = 8192
  vm_name                 = "ubuntu-22-template"
  template_description    = "Ubuntu Server Template"
  insecure_skip_tls_verify = true
  task_timeout            = "30m"
  http_directory          = "server"
  scsi_controller         = "virtio-scsi-single"
  boot_wait               = "10s"

  boot_iso {
    type             = "ide"
    iso_file         = "local:iso/ubuntu-22.04.5-live-server-amd64.iso"
    #iso_checksum     = "sha256:9bc6028870aef3f74f4e16b900008179e78b130e6b0b9a140635434a46aa98b0"
    unmount          = true
    iso_storage_pool = "local"
  }

  additional_iso_files {
    cd_files = [
      "./server/meta-data",
      "./server/user-data"
    ]
    cd_label         = "cloudinit"
    iso_storage_pool = "local"
    unmount          = true
  }

  network_adapters {
    bridge = var.netbridge
  }

  disks {
    disk_size    = "30G"
    storage_pool = var.storage_name
    type         = "scsi"
    discard      = true
    io_thread    = true
    format       = "raw"
  }

  boot_command = [
    "<esc><esc><esc><esc>e<wait>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del><del>",
    "linux /casper/vmlinuz --- autoinstall s=/cloudinit/<enter><wait>",
    "initrd /casper/initrd<enter><wait>",
    "boot<enter>",
    "<enter><f10><wait>"
  ]
}

build {
  sources = ["sources.proxmox-iso.ubuntu-22"]
}
