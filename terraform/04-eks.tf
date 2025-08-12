################################################################################
# 006-EKS-CLUSTER.TF
# ------------------------------------------------------------------------------
# Provisions an EKS cluster using EC2 worker nodes (managed node group)
# IAM roles are auto-managed by the EKS module
# Includes core add-ons (CoreDNS, kube-proxy, VPC CNI) and CloudWatch log group
################################################################################
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
 version = "~> 19.21.0" # 👈

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.private_subnets

  cluster_name    = "${var.project_name}-eks"
  cluster_version = "1.29"

  enable_irsa                    = true
  create_iam_role                = true
  create_cluster_security_group  = true
  cluster_endpoint_public_access = true  
  create_cloudwatch_log_group            = true
  cloudwatch_log_group_retention_in_days = 7


  manage_aws_auth_configmap = true

  aws_auth_users = [
    for entry in var.eks_admin_access_entries : {
      userarn  = entry.principal_arn
      username = entry.kubernetes_username
      groups   = entry.kubernetes_groups
    }
  ]

  cluster_security_group_additional_rules = {
    ingress_http = {
      description = "Allow HTTP"
      protocol    = "tcp"
      from_port   = 80
      to_port     = 80
      type        = "ingress"
      cidr_blocks = ["0.0.0.0/0"]
    }

    ingress_https = {
      description = "Allow HTTPS"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      type        = "ingress"
      cidr_blocks = ["0.0.0.0/0"]
    }

    ingress_app = {
      description = "Allow App Port 8080"
      protocol    = "tcp"
      from_port   = 8080
      to_port     = 8080
      type        = "ingress"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  # authentication_mode = "API"
  # access_entries      = var.eks_admin_access_entries

  eks_managed_node_groups = {
    quoteapp_nodes = {
      ami_type       = "AL2_x86_64"
      instance_types = ["t3.small"]
      disk_size      = 30
      min_size       = 1
      max_size       = 3
      desired_size   = 2

      labels = {
        role = "worker"
        app  = "quoteapp"
      }

      tags = {
        Name = "quoteapp-node"
      }
    }
  }

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {
      resolve_conflicts = "OVERWRITE"
    }
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }

  tags = {
    Project   = var.project_name
    Terraform = "true"
  }
}