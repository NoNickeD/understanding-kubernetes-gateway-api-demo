data "aws_availability_zones" "available" {
  state = "available"
}
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com", "ec2.amazonaws.com", "eks-fargate-pods.amazonaws.com", "eks-nodegroup.amazonaws.com", "lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_ssm_parameter" "eks_ami_release_version" {
  name = "/aws/service/eks/optimized-ami/${module.eks.cluster_version}/amazon-linux-2/recommended/release_version"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_policy_document" "gateway_api_controller" {
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"] # For testing purposes only (highly recommended limit access to specific resources for production usage)

    actions = [
      "vpc-lattice:*",
      "iam:CreateServiceLinkedRole",
      "ec2:DescribeVpcs",
      "ec2:DescribeSubnets",
      "ec2:DescribeTags",
      "ec2:DescribeSecurityGroups",
      "logs:CreateLogDelivery",
      "logs:GetLogDelivery",
      "logs:UpdateLogDelivery",
      "logs:DeleteLogDelivery",
      "logs:ListLogDeliveries",
      "tag:GetResources",
    ]
  }
}
