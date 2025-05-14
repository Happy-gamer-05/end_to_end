provider "aws" {
  region = "us-east-1"  # Update to your desired region
}

# Generate a new private key locally
resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create AWS key pair from the generated public key
resource "aws_key_pair" "generated_key" {
  key_name   = "devops-key"  # Name of the new key pair
  public_key = tls_private_key.ec2_key.public_key_openssh
}

# Save the private key to disk
resource "local_file" "private_key" {
  content         = tls_private_key.ec2_key.private_key_pem
  filename        = "${path.module}/devops-key.pem"
  file_permission = "0400"  # Set file permission for security
}

# Security group with open ports: 22, 80, 5000, 8080, 50000
resource "aws_security_group" "web_sg" {
  name        = "allow_devops_ports"
  description = "Allow inbound traffic for SSH, HTTP, Flask, Jenkins"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP"
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Flask app"
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Jenkins"
  }

  ingress {
    from_port   = 50000
    to_port     = 50000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Jenkins agents"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 instance with a new key pair and security group
resource "aws_instance" "web" {
  ami                    = "ami-0c94855ba95c71c99"  # Ubuntu 20.04 LTS AMI (Update this with the latest Ubuntu AMI ID for your region)
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.generated_key.key_name  # Reference the newly created key pair
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "DevOpsAppServer"
  }

  provisioner "local-exec" {
    command = "echo ${self.public_ip} > ip.txt"
  }
}

# Output the public IP of the EC2 instance
output "ec2_public_ip" {
  value = aws_instance.web.public_ip
}

# Output the private key location
output "private_key_location" {
  value = local_file.private_key.filename
}
