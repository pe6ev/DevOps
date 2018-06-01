provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_vpc" "main" {
  cidr_block           = "${var.cidr}"
  enable_dns_support   = "${var.enable_dns_support}"
  enable_dns_hostnames = "${var.enable_dns_hostnames}"

  tags {
    Name        = "Main"
    ManagedBy   = "PetarPeshev"
    Environment = "${var.environment}"
    Role        = "Main VPC"
    Provisioner = "Terraform"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name        = "Main"
    ManagedBy   = "PetarPeshev"
    Environment = "${var.environment}"
    Role        = "Main Internet Gateway"
    Provisioner = "Terraform"
  }
}

resource "aws_eip" "nat" {
  vpc = true

  tags {
    Name        = "Nat"
    ManagedBy   = "PetarPeshev"
    Environment = "${var.environment}"
    Role        = "NAT EIP"
    Provisioner = "Terraform"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.public.id}"
  depends_on    = ["aws_internet_gateway.main"]

  tags {
    Name        = "Main"
    ManagedBy   = "PetarPeshev"
    Environment = "${var.environment}"
    Role        = "Main NAT Gateway"
    Provisioner = "Terraform"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${var.public_cidr}"
  map_public_ip_on_launch = true

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name        = "Public Subnet"
    App         = "WebApp"
    ManagedBy   = "PetarPeshev"
    Environment = "${var.environment}"
    Role        = "Public Subnet"
    Provisioner = "Terraform"
  }
}

# Routes
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }

  depends_on = [
    "aws_route_table.public",
  ]

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name        = "Public Route Table"
    ManagedBy   = "PetarPeshev"
    Environment = "${var.environment}"
    Role        = "Public Route Table"
    Provisioner = "Terraform"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.public.id}"

  lifecycle {
    create_before_destroy = true
  }
}

# Private Subnet
resource "aws_subnet" "private" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${var.private_cidr}"
  map_public_ip_on_launch = false

  tags {
    Name        = "Private Subnet "
    App         = "MySQL"
    ManagedBy   = "PetarPeshev"
    Environment = "${var.environment}"
    Role        = "Private Subnet"
    Provisioner = "Terraform"
  }
}

// Private route table
resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.main.id}"
  }

  depends_on = [
    "aws_route_table.public",
  ]

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name        = "Private Route Table"
    App         = "MySQL"
    ManagedBy   = "PetarPeshev"
    Environment = "${var.environment}"
    Role        = "Private Route Table"
    Provisioner = "Terraform"
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = "${aws_subnet.private.id}"
  route_table_id = "${aws_route_table.private.id}"

  lifecycle {
    create_before_destroy = true
  }
}
