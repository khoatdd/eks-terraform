output "eks_node_role" {
  value = "${aws_iam_role.node.arn}"
}

output "eks_cluster" {
  value = "${aws_eks_cluster.eks-cluster.id}"
}

output "endpoint" {
  value = "${aws_eks_cluster.eks-cluster.endpoint}"
}

output "kubeconfig-certificate-authority-data" {
  value = "${aws_eks_cluster.eks-cluster.certificate_authority.0.data}"
}
