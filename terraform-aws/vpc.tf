module "vpc" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git"

  name = "elasticsearch-${var.es_cluster}-vpc"
  cidr = "${var.vpc_cidr}"

  azs             = ["${var.availability_zones}"]
  private_subnets = ["${var.vpc_private_subnets}"]
  public_subnets = ["${var.vpc_public_subnets}"]

  enable_nat_gateway = true
  enable_vpn_gateway = true
  single_nat_gateway = true
  tags = {
    Name        = "${var.es_cluster}-vpc"
    Environment = "${var.environment}"
    Cluster     = "${var.environment}-${var.es_cluster}"
  }
}
