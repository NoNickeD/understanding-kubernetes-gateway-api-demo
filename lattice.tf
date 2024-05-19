#-----------------------------------
# VPC Lattice service network
#-----------------------------------

resource "aws_vpclattice_service_network" "this" {
  name      = "echoer"
  auth_type = "NONE"

  tags = local.tags
}

resource "aws_vpclattice_service_network_vpc_association" "cluster_vpc" {
  vpc_identifier             = module.vpc.vpc_id
  service_network_identifier = aws_vpclattice_service_network.this.id
}

