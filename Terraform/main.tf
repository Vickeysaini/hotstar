terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region     = "us-east-1"  # N. Virginia
  access_key = var.access_key
  secret_key = var.secret_key
}

# Create security group for the EC2 instance
resource "aws_security_group" "ec2_security_group" {
  name        = "hotstar-ec2" 
  description = "allow access on port 22"

  ingress {
    description = "ssh access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Monitoring server security group"
  }
}

# Get the latest Amazon Linux 2 AMI dynamically in us-east-1
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.*-x86_64-gp2"]
  }
}

# Create EC2 instance
resource "aws_instance" "Monitoring_server" {
  ami             = data.aws_ami.amazon_linux_2.id
  instance_type   = "t2.medium"
  security_groups = [aws_security_group.ec2_security_group.name]
  key_name        = var.key_name  # must exist in us-east-1

  tags = {
    Name = var.instance_name
  }
}
