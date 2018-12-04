module "fundamental_infra" {
  source      = "./modules/fundamental_infra/"
  name_prefix = "${var.name_prefix}"
  region      = "${var.region}"
}

module "eks_cluster" {
  source            = "./modules/eks_cluster/"
  eks_cluster       = "${var.eks_cluster}"
  eks_node_role     = "${var.eks_node_role}"
  eks_service_role  = "${var.eks_service_role}"
  eks_vpc           = "${module.fundamental_infra.vpc}"
  name_prefix       = "${var.name_prefix}"
  public_subnet_ids = "${module.fundamental_infra.public_subnet_ids}"
  subnets_ids       = "${module.fundamental_infra.subnets_ids}"
}
