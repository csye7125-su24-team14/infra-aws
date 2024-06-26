terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.4"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.11.2"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.31.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.14.0"
    }
  }
}

provider "tls" {
}
provider "time" {
}
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

data "aws_caller_identity" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--profile", var.aws_profile, "--cluster-name", module.eks.cluster_name]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--profile", var.aws_profile, "--cluster-name", module.eks.cluster_name]
    }
  }
}

module "vpc" {
  source       = "./modules/vpc"
  cidr_block   = var.cidr_block
  vpc_tag_name = var.vpc_tag_name
}

module "kms" {
  source          = "./modules/kms"
  aws_account_id  = data.aws_caller_identity.current.account_id
  aws_first_user  = var.aws_first_user
  aws_second_user = var.aws_second_user
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.14.0"

  cluster_name                             = "eks-csye7125"
  cluster_version                          = "1.29"
  create_iam_role                          = true # default value
  iam_role_use_name_prefix                 = false
  iam_role_name                            = "eksClusterRole"
  iam_role_description                     = "Eks cluster role"
  enable_cluster_creator_admin_permissions = true
  authentication_mode                      = "API_AND_CONFIG_MAP"
  create_kms_key                           = true # default
  enable_kms_key_rotation                  = false
  vpc_id                                   = module.vpc.vpc_id
  create_cluster_security_group            = true # default

  subnet_ids                      = module.vpc.public_subnet_ids
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true
  cluster_enabled_log_types       = ["audit", "api", "authenticator", "controllerManager", "scheduler"]
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    eks-pod-identity-agent = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  eks_managed_node_groups = {
    complete = {
      name = "csye_node"
      #   use_name_prefix = true
      subnet_ids = module.vpc.public_subnet_ids

      min_size       = 3
      max_size       = 6
      desired_size   = 3
      capacity_type  = "ON_DEMAND"
      instance_types = ["c3.large"] #c3.large
      update_config = {
        max_unavailable = 1
      }
      ebs_optimized                 = true
      disable_api_termination       = false
      enable_monitoring             = false # changed
      create_cluster_security_group = false # default true
      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 20
            volume_type           = "gp2"
            encrypted             = true
            kms_key_id            = module.kms.eks_kms_arn
            delete_on_termination = true
          }
        }
      }

      create_iam_role              = true # default
      iam_role_name                = "AmazonEksNodeRole"
      iam_role_use_name_prefix     = false
      iam_role_description         = "EKS managed node group role"
      iam_role_additional_policies = { "AmazonEBSCSIDriverPolicy" = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy" }
    }
  }
  access_entries = {
    ex-single = {
      kubernetes_groups = []
      principal_arn     = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${var.aws_second_user}"

      policy_associations = {
        ex-two = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

resource "null_resource" "wait_for_cluster_ready" {
  depends_on = [module.eks]
  provisioner "local-exec" {
    command = "aws eks --profile ${var.aws_profile} --region ${var.aws_region} update-kubeconfig --name ${module.eks.cluster_name} && kubectl wait --for=condition=Ready node --all --timeout=300s"
  }
}