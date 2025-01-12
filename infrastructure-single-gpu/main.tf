data "nebius_vpc_v1_subnet" "default" {
  parent_id = var.project_id
  name      = "default-subnet-jvzrrihy"
}

# Boot disk for GPU instance
resource "nebius_compute_v1_disk" "gpu_boot" {
  parent_id        = var.project_id
  type             = "NETWORK_SSD"
  block_size_bytes = 4096
  name             = "gpu-vm-disk"
  size_bytes       = 214748364800 # 200 GiB
  source_image_family = {
    image_family = "ubuntu22.04-cuda12"
  }
}

# Filesystem for data storage
resource "nebius_compute_v1_filesystem" "gpu_fs" {
  parent_id        = var.project_id
  name             = "gpu-vm-filesystem"
  type             = "NETWORK_SSD"
  block_size_bytes = 4096
  size_bytes       = 107374182400 # 100 GiB
}

# GPU instance
resource "nebius_compute_v1_instance" "gpu_instance" {
  name      = "gpu-instance"
  parent_id = var.project_id

  network_interfaces = [
    {
      name              = "eth0"
      subnet_id         = data.nebius_vpc_v1_subnet.default.id
      ip_address        = {}
      public_ip_address = {}
    }
  ]

  resources = {
    platform = "gpu-h100-sxm"
    preset   = "1gpu-16vcpu-200gb"
  }

  boot_disk = {
    attach_mode = "READ_WRITE"
    existing_disk = {
      id = nebius_compute_v1_disk.gpu_boot.id
    }
  }

  filesystems = [
    {
      attach_mode = "READ_WRITE"
      mount_tag   = "data"
      existing_filesystem = {
        id = nebius_compute_v1_filesystem.gpu_fs.id
      }
    }
  ]

  cloud_init_user_data = templatefile("${path.module}/scripts/cloud-init.tftpl", {
    vm_username    = var.vm_username
    ssh_public_key = file(var.vm_ssh_public_key_path)
    fs_device_name = "data"
  })
}
