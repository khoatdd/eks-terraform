resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags {
    Name = "${var.name_prefix}-vpc"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "10.0.0.0/24"
  availability_zone = "${var.region}a"

  tags {
    Name = "${var.name_prefix}-private_subnet_1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.region}b"

  tags {
    Name = "${var.name_prefix}-private_subnet_2"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  availability_zone       = "${var.region}b"
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true

  tags {
    Name = "${var.name_prefix}-public_subnet_1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  availability_zone       = "${var.region}b"
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = true

  tags {
    Name = "${var.name_prefix}-public_subnet_2"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.name_prefix}-internet-gateway"
  }
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.public_subnet_1.id}"

  tags {
    Name = "${var.name_prefix}-nat_gateway"
  }

  depends_on = ["aws_internet_gateway.igw"]
}

resource "aws_route_table" "public_route" {
  depends_on = ["aws_internet_gateway.igw"]
  vpc_id     = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags {
    Name = "${var.name_prefix}-public_route_table"
  }
}

resource "aws_route_table" "private_route" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat_gateway.id}"
  }

  tags {
    Name = "${var.name_prefix}-private_route_table"
  }
}

resource "aws_route_table_association" "public_subnet_1_association" {
  subnet_id      = "${aws_subnet.public_subnet_1.id}"
  route_table_id = "${aws_route_table.public_route.id}"
}

resource "aws_route_table_association" "public_subnet_2_association" {
  subnet_id      = "${aws_subnet.public_subnet_2.id}"
  route_table_id = "${aws_route_table.public_route.id}"
}

resource "aws_route_table_association" "private_subnet_1_association" {
  subnet_id      = "${aws_subnet.private_subnet_1.id}"
  route_table_id = "${aws_route_table.private_route.id}"
}

resource "aws_route_table_association" "private_subnet_2_association" {
  subnet_id      = "${aws_subnet.private_subnet_2.id}"
  route_table_id = "${aws_route_table.private_route.id}"
}


resource "aws_route53_zone_association" "secondary" {
  zone_id = "${var.hosted_zone_id}"
  vpc_id  = "${aws_vpc.vpc.id}"
}