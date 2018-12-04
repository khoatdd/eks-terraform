module "fundamental_infra" {
  source      = "./modules/fundamental_infra/"
  name_prefix = "${var.name_prefix}"
  region      = "${var.region}"
}

module "eks_cluster" {
  source            = "./modules/eks_cluster/"
  name_prefix       = "${var.name_prefix}"
  eks_cluster       = "${var.eks_cluster}"
  eks_vpc           = "${module.fundamental_infra.vpc}"
  public_subnet_ids = "${module.fundamental_infra.public_subnet_ids}"
  subnets_ids       = "${module.fundamental_infra.subnets_ids}"
}
