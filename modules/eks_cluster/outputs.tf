output "eks_node_role" {
  value = "${aws_iam_role.node.arn}"
}