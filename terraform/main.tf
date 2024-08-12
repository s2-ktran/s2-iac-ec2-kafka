provider "aws" {
  region = var.region
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

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_security_group" "kafka_sg" {
  name        = "kafka-security-group"
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
  ami             = data.aws_ami.amazon_linux_2.id
  instance_type   = var.instance_type
  security_groups = [aws_security_group.kafka_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo dnf install -y java-21-amazon-corretto
              
              wget https://downloads.apache.org/kafka/3.7.1/kafka_2.13-3.7.1.tgz
              tar -xzf kafka_2.13-3.7.1.tgz
              cd kafka_2.13-3.7.1

              PUBLIC_IP=$(curl -s http://checkip.amazonaws.com)
              
              sed -i 's|#listeners=PLAINTEXT://:9092|listeners=PLAINTEXT://0.0.0.0:9092|' config/server.properties
              sed -i "s|#advertised.listeners=PLAINTEXT://your.host.name:9092|advertised.listeners=PLAINTEXT://$PUBLIC_IP:9092|" config/server.properties
              
              nohup bin/zookeeper-server-start.sh config/zookeeper.properties > zookeeper.log 2>&1 &
              sleep 30  # Ensure Zookeeper is up and running
              
              nohup bin/kafka-server-start.sh config/server.properties > kafka.log 2>&1 &
              sleep 30  # Ensure Kafka is up and running
              
              bin/kafka-topics.sh --create --topic event_topic --bootstrap-server $PUBLIC_IP:9092 --partitions 8

            EOF

  tags = {
    Name = "Kafka EC2 Instance"
  }
}


output "ec2_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.kafka_ec2.public_ip
}
