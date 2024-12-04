# 1. Define Provider
provider "aws" {
  region = "eu-west-1" # Replace with your desired region
}

# 2. Variables (optional but useful for reuse)
variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "key_name" {
  default = "AwsNginxKey" # Replace with your EC2 key pair name
}

variable "ec2_ami_id" {
  default = "ami-0d64bb532e0502c46" # Ubuntu 24.04 - Replace with desired ID.
}

# 3. VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "test-vpc"
  }
}

# 4. Subnet
resource "aws_subnet" "subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnet_cidr
  map_public_ip_on_launch = true # Enables public IP for EC2 instances
}

# 5. Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

# 6. Route Table
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "test-route-table"
  }
}

# 6.1 Associate Subnet with Route Table
resource "aws_route_table_association" "subnet_association" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.route_table.id
}

# 7. Security Group
resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allows SSH from anywhere
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allows HTTP from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # All protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "test-sg"
  }
}

# 8. EC2 Instance
resource "aws_instance" "ec2" {
  ami           = var.ec2_ami_id # Replace with the desired Ubuntu AMI ID for your region
  instance_type = "t2.micro"              # Choose an appropriate instance type
  subnet_id     = aws_subnet.subnet.id
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.sg.id]

  user_data = <<-EOF
                #!/bin/bash
                apt update
                apt install nginx -y
                systemctl enable nginx
                systemctl start nginx
                EOF

  tags = {
    Name = "test-ec2"
  }
}

# 9. Output Public IP
output "ec2_public_ip" {
  value = aws_instance.ec2.public_ip
}
