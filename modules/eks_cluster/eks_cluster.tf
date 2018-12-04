resource "aws_eks_cluster" "eks-cluster" {
  name = "${var.eks_cluster}"
  role_arn = "${aws_iam_role.cluster.arn}"
  vpc_config {
    security_group_ids = ["${aws_security_group.cluster.id}"]
    subnet_ids = ["${var.subnets_ids}"]
  }
}
output "endpoint" {
  value = "${aws_eks_cluster.eks-cluster.endpoint}"
}
output "kubeconfig-certificate-authority-data" {
  value = "${aws_eks_cluster.eks-cluster.certificate_authority.0.data}"
}
