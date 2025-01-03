locals {
  retry_join = "provider=aws tag_key=NomadJoinTag tag_value=auto-join"
}



resource "aws_security_group" "allow_all_internal" {
  name   = "${var.cluster_name}-allow-all-internal"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }
}

resource "aws_security_group" "clients_ingress" {
  name   = "${var.cluster_name}-clients-ingress"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Add application ingress rules here
  # These rules are applied only to the client nodes

  # nginx example
  # ingress {
  #   from_port   = 80
  #   to_port     = 80
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "server" {
  ami                    = var.ami
  instance_type          = var.server_instance_type
  vpc_security_group_ids = [aws_security_group.server_ui_ingress.id, aws_security_group.ssh_ingress.id, aws_security_group.allow_all_internal.id]
  subnet_id              = module.vpc.public_subnets[count.index % length(module.vpc.public_subnets)]
  availability_zone      = module.vpc.azs[count.index % length(module.vpc.azs)]
  count                  = var.server_count

  # NomadJoinTag is necessary for nodes to automatically join the cluster
  tags = merge(
    {
      "Name" = "${var.cluster_name}-server-${count.index}"
    },
    {
      "NomadJoinTag" = "auto-join"
    },
    {
      "NomadType" = "server"
    }
  )

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.server_root_block_device_size
    delete_on_termination = "true"
  }

  user_data = templatefile("../../shared/scripts/server.sh", {
    cloud_env    = "aws"
    server_count = var.server_count
    retry_join   = local.retry_join
  })

  iam_instance_profile = aws_iam_instance_profile.instance_profile.name

  metadata_options {
    http_endpoint          = "enabled"
    instance_metadata_tags = "enabled"
  }
}

resource "aws_instance" "client" {
  ami                    = var.ami
  instance_type          = var.client_instance_type
  vpc_security_group_ids = [aws_security_group.server_ui_ingress.id, aws_security_group.ssh_ingress.id, aws_security_group.clients_ingress.id, aws_security_group.allow_all_internal.id]
  subnet_id              = module.vpc.public_subnets[count.index % length(module.vpc.public_subnets)]
  availability_zone      = module.vpc.azs[count.index % length(module.vpc.azs)]
  count                  = var.client_count

  # NomadJoinTag is necessary for nodes to automatically join the cluster
  tags = merge(
    {
      "Name" = "${var.cluster_name}-client-${count.index}"
    },
    {
      "NomadJoinTag" = "auto-join"
    },
    {
      "NomadType" = "client"
    }
  )

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.client_root_block_device_size
    delete_on_termination = "true"
  }

  ebs_block_device {
    device_name           = "/dev/xvdd"
    volume_type           = "gp3"
    volume_size           = var.client_data_block_device_size
    delete_on_termination = "true"
  }

  user_data = templatefile("../../shared/scripts/client.sh", {
    cloud_env  = "aws"
    retry_join = local.retry_join
  })
  iam_instance_profile = aws_iam_instance_profile.instance_profile.name

  metadata_options {
    http_endpoint          = "enabled"
    instance_metadata_tags = "enabled"
  }
}
