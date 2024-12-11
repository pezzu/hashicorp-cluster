variable "cluster_name" {
  type        = string
  description = "Name of the Hashicorp cluster"
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
