################################################################################
# EKS VPC MODULE CONFIGURATION
# ------------------------------------------------------------------------------
# Provisions a VPC tailored for EKS with:
#   - Public & private subnets across selected AZs
#   - NAT gateway (single, cost-effective) for private subnet internet access
#   - DNS support for service discovery and internal networking
#
# Notes & Tips:
#   ✅ `enable_dns_support` and `enable_dns_hostnames` are **required** for EKS
#      to support internal CoreDNS and service discovery.
#   ✅ `single_nat_gateway = true` saves cost (one NAT for all private subnets),
#      but is a **single point of failure**. For high availability, use one per AZ.
#   🚧 Ensure subnet CIDRs don't overlap with other VPCs if peering is planned.
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "eks-vpc"
  cidr = var.cidr_block

  azs             = local.selected_azs
  public_subnets  = local.public_subnet_cidrs
  private_subnets = local.private_subnet_cidrs

  enable_dns_hostnames = true
  enable_dns_support   = true

  # ✅ NAT for private subnets
  enable_nat_gateway = true
  single_nat_gateway = true # saves cost (1 NAT for all)

  tags = {
    Project   = "eks"
    Terraform = "true"
  }
}