module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = ">= 5.16.0"

  name = "${var.cluster_name}-vpc"
  cidr = var.vpc_cidr

  azs             = [join("", [var.region, "a"]), join("", [var.region, "b"]), join("", [var.region, "c"])]
  private_subnets = var.vpc_private_subnets
  public_subnets  = var.vpc_public_subnets

  enable_dns_hostnames   = true
  enable_dns_support     = true
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  create_igw             = true
  enable_ipv6            = false

  tags = {
    Environment = var.cluster_name
  }

  vpc_tags = {
    Name        = "${var.cluster_name}-vpc"
    Environment = var.cluster_name
  }
}
