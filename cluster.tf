module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name                             = var.cluster_name
  cluster_version                          = var.cluster_version
  vpc_id                                   = module.vpc.vpc_id
  subnet_ids                               = module.vpc.private_subnets
  control_plane_subnet_ids                 = module.vpc.intra_subnets
  authentication_mode                      = "API_AND_CONFIG_MAP"
  enable_cluster_creator_admin_permissions = true
  cluster_endpoint_public_access           = true

  eks_managed_node_group_defaults = {
    ami_type = var.ami_type

    attach_worker_cni_policy = true

    disk_size = var.disk_size

  }
  node_security_group_tags = {
    "karpenter.sh/discovery" = var.cluster_name
  }

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
  }

  eks_managed_node_groups = {
    (local.group_name) = {
      instance_types = var.instance_types
      min_size       = var.node_count_min
      max_size       = var.node_count_max
      desired_size   = var.node_count

      name                     = "${var.cluster_name}-${local.group_name_suffix}"
      node_group_name_prefix   = false
      iam_role_name            = "${var.cluster_name}-${local.group_name_suffix}"
      iam_role_use_name_prefix = false


      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            delete_on_termination = true
            encrypted             = true
            iops                  = 3000
            throughput            = 125
            volume_size           = var.disk_size
            volume_type           = "gp3"
          }
        }
      }

      iam_role_additional_policies = {
        AmazonSSMManagedInstanceCore        = local.policies.AmazonSSMManagedInstanceCore
        AmazonEC2ContainerRegistryPowerUser = local.policies.AmazonEC2ContainerRegistryPowerUser
        AmazonCloudwatchFullAccess          = local.policies.AmazonCloudwatchFullAccess
      }
    }
  }

  cluster_enabled_log_types = ["audit", "api", "authenticator", "controllerManager", "scheduler"]

  tags = merge(local.tags, { Name = "${var.cluster_name}" })
}


resource "random_id" "base_node_group_name_suffix" {
  keepers = {
    cluster_name   = var.cluster_name
    subnet_ids     = join("|", module.vpc.private_subnets)
    instance_types = join("|", var.instance_types)
    disk_size      = var.disk_size
  }
  byte_length = 2
}

#-----------------------------------
# Addons
#-----------------------------------
module "addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.16"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  enable_aws_gateway_api_controller = true
  aws_gateway_api_controller = {
    chart_version           = "v1.0.3"
    create_namespace        = true
    namespace               = "aws-application-networking-system"
    source_policy_documents = [data.aws_iam_policy_document.gateway_api_controller.json]
    set = [
      {
        name  = "clusterName"
        value = module.eks.cluster_name
      },
      {
        name  = "log.level"
        value = "debug"
      },
      {
        name  = "clusterVpcId"
        value = module.vpc.vpc_id
      },
      {
        name  = "defaultServiceNetwork"
        value = ""
      },
      {
        name  = "latticeEndpoint"
        value = "https://vpc-lattice.${var.region}.amazonaws.com"
      }
    ]
    wait = true
  }
  tags = local.tags

}

#-----------------------------------
# Update cluster security group to allow access from VPC Lattice
#-----------------------------------

data "aws_ec2_managed_prefix_list" "vpc_lattice_ipv4" {
  name = "com.amazonaws.${var.region}.vpc-lattice"
}

resource "aws_vpc_security_group_ingress_rule" "cluster_sg_ingress" {
  security_group_id = module.eks.node_security_group_id

  prefix_list_id = data.aws_ec2_managed_prefix_list.vpc_lattice_ipv4.id
  ip_protocol    = "-1"
}
