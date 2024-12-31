packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }
}

source "amazon-ebs" "hashistack" {
    region        = "us-east-1"
    instance_type = "t2.medium"
    ssh_username  = "ubuntu"
    ami_name      = "hashistack {{timestamp}}"

    source_ami_filter {
      filters = {
        virtualization-type              = "hvm"
        architecture                     = "x86_64"
        name                             = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
        root-device-type                 = "ebs"
      }
      owners      = ["099720109477"] # Canonical
      most_recent = true
    }
}

build {
  sources = [
    "source.amazon-ebs.hashistack"
  ]

  provisioner "shell" {
    inline = [
      "sudo mkdir /ops",
      "sudo chmod 777 /ops"
    ]
  }

  provisioner "file" {
    source      = "../shared"
    destination = "/ops"
  }

  provisioner "shell" {
    script = "../shared/scripts/setup.sh"
  }
}
