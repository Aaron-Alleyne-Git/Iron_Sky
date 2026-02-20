terraform {
  required_version = ">= 1.7.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "CloudGuard-DR"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

# Phase 1: VPC Foundation
module "aws_dr_foundation" {
  source = "../../modules/aws-dr-foundation"

  environment = var.environment
  vpc_cidr    = "10.0.0.0/16"
}

# Phase 2: EKS Cluster
module "kubernetes_dr_cluster" {
  source = "../../modules/kubernetes-dr-cluster"

  environment         = var.environment
  vpc_id              = module.aws_dr_foundation.vpc_id
  private_subnet_ids  = module.aws_dr_foundation.private_subnet_ids
  public_subnet_ids   = module.aws_dr_foundation.public_subnet_ids
  velero_bucket_arn   = module.aws_dr_foundation.velero_bucket_arn
}

output "eks_cluster_name" {
  value = module.kubernetes_dr_cluster.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.kubernetes_dr_cluster.cluster_endpoint
}

output "configure_kubectl" {
  value = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.kubernetes_dr_cluster.cluster_name}"
}