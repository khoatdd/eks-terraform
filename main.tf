module "fundamental_infra" {
  source      = "./modules/fundamental_infra/"
  region      = "${var.region}"
  name_prefix = "${var.name_prefix}"
}
