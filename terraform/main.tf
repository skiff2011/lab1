terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "eu-north-1"
}

resource "aws_instance" "lab2_server" {
  ami           = "ami-000e50175c5f86214"
  instance_type = "t3.micro"

  # Key pair for SSH access (ensure this exists in your AWS account)
  key_name = "lab1_key" # Replace with your key pair name

  # Security group to allow SSH and HTTP access
  vpc_security_group_ids = [aws_security_group.docker_sg.id]

  # User data script to install Docker and run a container
  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y apt-transport-https ca-certificates curl software-properties-common
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
              add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
              apt-get update
              apt-get install -y docker-ce
              systemctl start docker
              systemctl enable docker
              docker run -d --name lab1_app -p 80:80 osmovzhenko/lab1
              docker run -d --name watchtower -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower --interval 100
              EOF

  # Tags for the instance
  tags = {
    Name = "Lab2Server"
  }
}

# Security group to allow SSH and HTTP traffic
resource "aws_security_group" "docker_sg" {
  name_prefix = "docker-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH from my IP
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTP traffic from any IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Lab2SecurityGroup"
  }
}