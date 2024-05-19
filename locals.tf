locals {
  tags = {
    ManagedBy   = "opentofu"
    Project     = "gateway-api-demo"
    Environment = "tst"
  }

  environment = "tst"
  project     = "gateway-api-demo"

  name = "${local.project}-${local.environment}"

  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  account_id = data.aws_caller_identity.current.account_id

  group_name        = "kubecraft"
  group_name_suffix = "${local.group_name}-${random_id.base_node_group_name_suffix.b64_url}"

  validation_errors = concat(
    # Validate node_count > 0
    var.node_count > 0 ? [] : ["The number of nodes must be greater than 0."],
    # Validate node_count_max > node_count
    var.node_count_max > var.node_count ? [] : ["The maximum number of nodes must be greater than node_count."],
    # Validate node_count_min < node_count
    var.node_count_min < var.node_count ? [] : ["The minimum number of nodes must be less than node_count."]
  )

  current_identity = data.aws_caller_identity.current.arn

  policies = {
    AmazonEC2ContainerRegistryPowerUser = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
    AmazonSSMManagedInstanceCore        = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    AmazonCloudwatchFullAccess          = "arn:aws:iam::aws:policy/CloudWatchFullAccessV2"
  }
}
