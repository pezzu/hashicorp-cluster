variable "cluster_name" {
  type        = string
  description = "Name of the Hashicorp cluster"
}

variable "nomad_version" {
  type        = string
  description = "Version of Nomad to install"
  default     = "1.9.3"
}

variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

#  Network
variable "vpc_cidr" {
  default     = "10.0.0.0/16"
  description = "VPC cidr"
}

variable "vpc_private_subnets" {
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  description = "VCP private subnets"
}

variable "vpc_public_subnets" {
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  description = "VCP public subnets"
}

variable "allowlist_ip" {
  description = "IP to allow access for the security groups (set 0.0.0.0/0 for world)"
  default     = "0.0.0.0/0"
}

#Compute
variable "server_count" {
  type        = number
  default     = 3
  description = "Number of nodes in the control plane"
}

variable "server_instance_type" {
  type        = string
  default     = "t3.small"
  description = "Instance type for the control plane"
}

variable "server_root_block_device_size" {
  type        = number
  default     = 20
  description = "Size of the root block device for the control plane nodes"
}

variable "client_count" {
  type        = number
  default     = 2
  description = "Number of worker nodes"
}

variable "client_instance_type" {
  type        = string
  default     = "t3.small"
  description = "Instance type for the worker nodes"
}

