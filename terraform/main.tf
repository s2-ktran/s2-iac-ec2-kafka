terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    singlestoredb = {
      source  = "singlestore-labs/singlestoredb"
      version = "0.1.0-alpha.5" # Use the latest version available
    }
  }
}

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

# Variable for existing AWS key pair
variable "key_name" {
  description = "The AWS Key Pair name to use for EC2 instances"
  type        = string
}

variable "single_store_ips" {
  type        = list(string)
  description = "List of SingleStore outbound IP addresses"
}
# Variable for Kafka topics
variable "kafka_topics" {
  description = "List of Kafka topics to create"
  type = list(object({
    name       = string
    partitions = number
  }))
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

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key_pem" {
  content         = tls_private_key.ec2_key.private_key_pem
  filename        = "${path.module}/../${var.key_name}.pem"
  file_permission = "0600"
}

resource "aws_key_pair" "deployer" {
  key_name   = var.key_name
  public_key = tls_private_key.ec2_key.public_key_openssh
}

resource "aws_instance" "kafka_ec2" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = var.instance_type
  key_name                    = var.key_name # Use the parameterized key name
  security_groups             = [aws_security_group.kafka_sg.name]
  associate_public_ip_address = false
  tags = {
    Name      = local.instance_name,
    Owner     = var.aws_profile_name,
    Terraform = "iac-ec2-kafka",
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

# Resource to create Kafka topics
# resource "null_resource" "create_kafka_topics" {
#   count = length(var.kafka_topics)

#   depends_on = [aws_instance.kafka_ec2]
# }

output "ec2_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_eip.kafka_ip.public_ip
}

output "ec2_instance_id" {
  value       = aws_instance.kafka_ec2.id
  description = "The ID of the Kafka EC2 instance."
}

output "ec2_name" {
  description = "The name of the Kafka EC2 instance"
  value       = "${local.instance_name_prefix}-${var.aws_profile_name}"
}

