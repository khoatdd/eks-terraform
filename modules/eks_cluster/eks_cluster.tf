resource "aws_eks_cluster" "eks-cluster" {
  name = "${var.name_prefix}-cluster"
  role_arn = "${aws_iam_role.cluster.arn}"
  vpc_config {
    security_group_ids = ["${aws_security_group.cluster.id}"]
    subnet_ids = ["${var.subnets_ids}"]
  }
}
