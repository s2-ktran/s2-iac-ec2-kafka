provider "aws" {
  region = var.region
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

locals {
  instance_name_prefix = "kafka-instance"
  instance_name        = "${local.instance_name_prefix}-${var.aws_profile_name}"
}

variable "aws_profile_name" {
  description = "The AWS profile name to use for naming resources"
  type        = string
  default     = "default"
}

variable "instance_type" {
  description = "The type of EC2 instance to use"
  type        = string
  default     = "t2.large"
}

variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-west-2"
}

variable "my_ip" {
  description = "Your IP address for SSH and Kafka/Zookeeper access"
  type        = string
}

variable "single_store_ips" {
  description = "List of SingleStore outbound IP addresses"
  type        = list(string)
}



resource "aws_eip" "kafka_ip" {
  instance = aws_instance.kafka_ec2.id
}

resource "aws_security_group" "kafka_sg" {
  description = "Security group for Kafka"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    from_port   = 9092
    to_port     = 9092
    protocol    = "tcp"
    cidr_blocks = concat([var.my_ip], var.single_store_ips)
  }

  ingress {
    from_port   = 2181
    to_port     = 2181
    protocol    = "tcp"
    cidr_blocks = concat([var.my_ip], var.single_store_ips)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "kafka_ec2" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = var.instance_type
  security_groups             = [aws_security_group.kafka_sg.name]
  associate_public_ip_address = false

  tags = {
    Name = local.instance_name
  }

  user_data = file("${path.module}/user_data.sh")
}

resource "aws_security_group_rule" "kafka_ip_ingress" {
  type              = "ingress"
  from_port         = 9092
  to_port           = 9092
  protocol          = "tcp"
  security_group_id = aws_security_group.kafka_sg.id
  cidr_blocks       = ["${aws_eip.kafka_ip.public_ip}/32"]
}

resource "aws_security_group_rule" "kafka_ip_ingress_2181" {
  type              = "ingress"
  from_port         = 2181
  to_port           = 2181
  protocol          = "tcp"
  security_group_id = aws_security_group.kafka_sg.id
  cidr_blocks       = ["${aws_eip.kafka_ip.public_ip}/32"]
}


output "ec2_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_eip.kafka_ip.public_ip
}
