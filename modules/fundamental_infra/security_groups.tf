resource "aws_security_group" "allow-ssh" {
  name        = "${var.name_prefix}-allow-ssh"
  description = "ssh"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.name_prefix}-allow-ssh"
  }
}
