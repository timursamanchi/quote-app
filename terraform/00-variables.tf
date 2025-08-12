#######################################
# EKS vpc settings
#######################################
variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/24"
}

variable "aws_region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "eu-west-1"
}

variable "max_azs" {
  description = "Number of availability zones to use"
  type        = number
  default     = 3
}

variable "project_name" {
  description = "Name prefix for tagging resources"
  type        = string
  default     = "quote-app"
}

variable "eks_admin_access_entries" {
  description = "IAM users to be granted access to the EKS cluster via aws-auth configmap"
  type = map(object({
    principal_arn       = string
    kubernetes_username = string
    kubernetes_groups   = list(string)
  }))
  default = {}
}
