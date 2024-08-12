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

# TODO: Create resource key pair
# resource "aws_key_pair" "hv_demothon_key" {
#   key_name   = "hv-demothon"
#   public_key = file("~/Downloads/hv-demothon.pem")
# }

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
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type
  #   key_name        = aws_key_pair.hv_demothon_key.key_name
  security_groups = [aws_security_group.kafka_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo dnf install -y java-21-amazon-corretto
              
              wget https://downloads.apache.org/kafka/3.7.1/kafka_2.13-3.7.1.tgz
              tar -xzf kafka_2.13-3.7.1.tgz
              cd kafka_2.13-3.7.1
              
              sed -i 's|#listeners=PLAINTEXT://:9092|listeners=PLAINTEXT://0.0.0.0:9092|' config/server.properties
              sed -i "s|#advertised.listeners=PLAINTEXT://your.host.name:9092|advertised.listeners=PLAINTEXT://0.0.0.0:9092|" config/server.properties
              
              nohup bin/zookeeper-server-start.sh config/zookeeper.properties > zookeeper.log 2>&1 &
              nohup bin/kafka-server-start.sh config/server.properties > kafka.log 2>&1 &
            EOF

  tags = {
    Name = "Kafka EC2 Instance"
  }
}


output "ec2_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.kafka_ec2.public_ip
}

output "ssh_command" {
  value = "ssh -i \"hv-demothon.pem\" ec2-user@${aws_instance.kafka_ec2.public_ip}"
}
