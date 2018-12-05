resource "aws_iam_role" "node" {
  name = "${var.name_prefix}-eks_node_role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.node.name}"
}

resource "aws_iam_role_policy_attachment" "node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.node.name}"
}

resource "aws_iam_role_policy_attachment" "node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.node.name}"
}

resource "aws_iam_instance_profile" "node" {
  name = "${var.name_prefix}-eks-node-prof2"
  role = "${aws_iam_role.node.name}"
}

data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-*"]
  }

  tags = "${
    map(
    "Name", "${var.name_prefix}-eks-node-sg",
    "kubernetes.io/cluster/${var.name_prefix}-cluster", "owned",
    )
  }"

  most_recent = true
  owners      = ["602401143452"] # Amazon
}

locals {
  node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh ${var.name_prefix}-cluster
USERDATA
}

resource "aws_launch_configuration" "eks" {
  depends_on                  = ["aws_eks_cluster.eks-cluster"]
  associate_public_ip_address = "true"
  iam_instance_profile        = "${aws_iam_instance_profile.node.name}"
  image_id                    = "${data.aws_ami.eks-worker.id}"
  instance_type               = "${var.instance_type}"
  name_prefix                 = "${var.name_prefix}-eks-lc"
  security_groups             = ["${aws_security_group.node.id}"]
  user_data_base64            = "${base64encode(local.node-userdata)}"
  key_name                    = "${aws_key_pair.eks_node_key.id}"

  root_block_device {
    volume_size           = "${var.volume_size}"
    volume_type           = "gp2"
    delete_on_termination = "${var.delete_on_termination}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "eks" {
  depends_on           = ["aws_eks_cluster.eks-cluster"]
  desired_capacity     = "${var.desired_capacity}"
  launch_configuration = "${aws_launch_configuration.eks.id}"
  max_size             = "${var.max_capacity}"
  min_size             = "${var.min_capacity}"
  name                 = "${var.name_prefix}-eks-asg"

  vpc_zone_identifier = ["${var.public_subnet_ids}"]

  tag {
    key                 = "Name"
    value               = "${var.name_prefix}-eks-node"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.name_prefix}-cluster"
    value               = "owned"
    propagate_at_launch = true
  }
}
