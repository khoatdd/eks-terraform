output "vpc" {
  value = "${aws_vpc.vpc.id}"
}

output "subnets_ids" {
  value = ["${aws_subnet.private_subnet_1.id}", "${aws_subnet.private_subnet_2.id}", "${aws_subnet.public_subnet_1.id}", "${aws_subnet.public_subnet_2.id}"]
}

output "public_subnet_ids" {
  value = ["${aws_subnet.public_subnet_1.id}", "${aws_subnet.public_subnet_2.id}"]
}
