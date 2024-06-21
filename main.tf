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



module "vpc" {
  source       = "./modules/vpc"
  cidr_block   = var.cidr_block
  vpc_tag_name = var.vpc_tag_name
}

module "kms" {
  source         = "./modules/kms"
  aws_account_id = var.aws_account_id
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
    # One access entry with a policy associated
    # ex-single = {
    #   kubernetes_groups = []
    #   principal_arn     = "arn:aws:iam::${var.aws_account_id}:user/skaluva"
    #   policy_associations = {
    #     single = {
    #       policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
    #       access_scope = {
    #         namespaces = ["default"]
    #         type       = "namespace"
    #       }
    #     }
    #   }
    # }
    ex-multiple = {
      kubernetes_groups = []
      principal_arn     = "arn:aws:iam::${var.aws_account_id}:user/skaluva"

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

# module "eks_eks-managed-node-group" {
#   source                       = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"
#   version                      = "20.14.0"
#   create                       = true
#   cluster_name                 = module.eks.cluster_name
#   name                         = "csye_node"
#   ami_type                     = "AL2_x86_64"
#   instance_types               = ["c3.large"]
#   iam_role_use_name_prefix     = false
#   iam_role_name                = "AmazonEKSNodeRole"
#   min_size                     = 1
#   max_size                     = 1
#   desired_size                 = 1
#   create_launch_template       = false
#   use_custom_launch_template   = false
#   iam_role_additional_policies = { "AmazonEBSCSIDriverPolicy" = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy" }
#   block_device_mappings = {
#         xvda = {
#           device_name = "/dev/xvda"
#           ebs = {
#             volume_size           = 8
#             volume_type           = "gp2"
#             encrypted             = true
#             # kms_key_id            = module.ebs_kms_key.key_arn
#             delete_on_termination = true
#           }
#         }
#       }
#   update_config = {
#     "max_unavailable" : 1
#   }
#   subnet_ids           = module.vpc.public_subnet_ids
#   cluster_service_cidr = module.eks.cluster_service_cidr
#   # capacity_type = "ON_DEMAND" default
#   # disk_size = 20 default 
#   # create_iam_role = true defaults
#   # iam_role_description = ""
# }
