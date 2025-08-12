#######################################
# Get available AZs
#######################################
data "aws_availability_zones" "available" {
  state = "available"
}

#######################################
# Subnet and AZ logic
#######################################
locals {
  # Pick first N availability zones
  selected_azs = slice(data.aws_availability_zones.available.names, 0, var.max_azs)

  # Create public subnets (3 bits → 8 total subnets possible from /22)
  public_subnet_cidrs = [
    for i in range(length(local.selected_azs)) :
    cidrsubnet(var.cidr_block, 3, i)
  ]

  # Create private subnets starting after public ones
  private_subnet_cidrs = [
    for i in range(length(local.selected_azs)) :
    cidrsubnet(var.cidr_block, 3, i + length(local.selected_azs))
  ]
}

#######################################
# Install nginx ingress yaml and a k8s loadbalancer
#######################################
resource "null_resource" "install_nginx_ingress" {
  depends_on = [module.eks] # Ensures cluster is ready before this runs

  provisioner "local-exec" {
    command = <<EOT
    echo "Installing ingress-nginx controller..."
    aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.aws_region}
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.5/deploy/static/provider/aws/deploy.yaml
    EOT
  }

  triggers = {
    cluster_name = module.eks.cluster_name
    # change this manually to force re-run if needed
    install_version = "v1.9.5"
  }
}

#######################################
# CloudWatch Log Groups
#######################################
resource "aws_cloudwatch_log_group" "quote_frontend" {
  name              = "/eks/quote-frontend"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "quote_backend" {
  name              = "/eks/quote-backend"
  retention_in_days = 7
}