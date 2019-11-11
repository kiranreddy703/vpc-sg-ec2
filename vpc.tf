provider "aws" {
access_key = ""
secret_key = ""
region = "us-east-2"
}
variable "public_subnet_cidr" {
description = "CIDR for public subnet"
default     = "10.0.1.0/24"
}
variable "private_subnet_cidr" {
description = "CIDR for private subnet"
default     = "10.0.2.0/24"
}
variable "key_name" {
description = "Key name for SSHing into EC2"
default = "terrafgit"
}
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"

  tags = {
    Name = "myterraform-vpc"
  }
}
resource "aws_internet_gateway" "default" {
vpc_id = "${aws_vpc.main.id}"                                                                               tags {
    Name = "linoxide gw"
  }
}
resource "aws_subnet" "public-subnet" {
vpc_id = "${aws_vpc.main.id}"
cidr_block = "${var.public_subnet_cidr}"
availability_zone = "us-east-2a"

tags {
Name = "Linoxide Public Subnet"
}
}
resource "aws_subnet" "private-subnet" {
vpc_id = "${aws_vpc.main.id}"
cidr_block = "${var.private_subnet_cidr}"
availability_zone = "us-east-2b"

tags {
Name = "Linoxide Private Subnet"
}
}

resource "aws_route_table" "public-subnet" {
vpc_id = "${aws_vpc.main.id}"

route {
cidr_block = "0.0.0.0/0"
gateway_id = "${aws_internet_gateway.default.id}"
}

tags {
Name = "Linoxide Public Subnet"
}
}
resource "aws_security_group" "web" {
name = "vpc_web"
description = "Accept incoming connections."

ingress {
from_port = 80
to_port = 80
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"] }
ingress {
from_port = 443
to_port = 443
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"] }
ingress {
from_port = -1
to_port = -1
protocol = "icmp"
cidr_blocks = ["0.0.0.0/0"] }


vpc_id = "${aws_vpc.main.id}"

tags {
Name = "WebServerSG"
}
}
resource "aws_instance" "web-1" {
ami = "ami-00c03f7f7f2ec15c3"
availability_zone = "us-east-2a"
instance_type = "t2.micro"
key_name = "${var.key_name}"
vpc_security_group_ids = ["${aws_security_group.web.id}"] subnet_id = "${aws_subnet.public-subnet.id}"
associate_public_ip_address = true
source_dest_check = false
tags {
Name = "Web Server LAMP"
}
}
