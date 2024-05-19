#-----------------------------------
# VPC Outputs
#-----------------------------------
output "private_subnets" {
  value = module.vpc.private_subnets
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "intra_subnets" {
  value = module.vpc.intra_subnets
}

output "database_subnets" {
  value = module.vpc.database_subnets
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  value = module.vpc.vpc_cidr_block
}

output "gateway_id" {
  value = module.vpc.public_internet_gateway_route_id
}

#-----------------------------------
# EKS Outputs
#-----------------------------------
output "eks-endpoint" {
  value = module.eks.cluster_endpoint
}


output "eks-cluster-name" {
  value = module.eks.cluster_name
}

output "eks-cluster-arn" {
  value = module.eks.cluster_arn
}

output "eks-cluster-version" {
  value = module.eks.cluster_version
}

output "eks-cluster-security-group" {
  value = module.eks.cluster_security_group_id
}

output "eks-cluster-status" {
  value = module.eks.cluster_status
}

#-----------------------------------
# ECR Outputs
#-----------------------------------
output "ecr-repository" {
  value = aws_ecr_repository.ecr-repository.name
}

output "ecr-repository-url" {
  value = aws_ecr_repository.ecr-repository.repository_url
}
