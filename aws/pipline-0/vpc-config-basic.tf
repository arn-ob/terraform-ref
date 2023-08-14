# Pipline-0 Plan
# 
# 1. Create VPC
# 2. Create Subnet
# 3. Create Internet Gateway
# 4. Create customer route table
# 5. Create a subnet
# 6. Associate the subnet with the route table
# 7. Create a security group to allow 22,80,443
# 8. Create a network interface with an IP in the subnet that was created in step 4
# 9. Assign an elastic IP to the network interface created in step 8
# 10. Create a ubuntu server 
#
# -----------------------------------------------------------------------------------

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
  region  = "ap-northeast-3" # Osaka
  profile = "arn"
}


# --- Provider Config ----


# Create VPC
resource "aws_vpc" "basic-vpc" {

  cidr_block = "10.0.0.0/20"

  tags = {
    Name = "basic-vpc"
  }
}


# Create Subnet
resource "aws_subnet" "basic-vpc-subnet-1" {

  vpc_id            = aws_vpc.basic-vpc.id
  cidr_block        = "10.0.1.0/26"
  availability_zone = "ap-northeast-3a"

  tags = {
    Name = "basic-vpc-subnet-1"
  }
}

resource "aws_subnet" "basic-vpc-subnet-2" {

  vpc_id            = aws_vpc.basic-vpc.id
  cidr_block        = "10.0.2.0/28"
  availability_zone = "ap-northeast-3b"

  tags = {
    Name = "basic-vpc-subnet-2"
  }
}


# Create Internet Gateway
resource "aws_internet_gateway" "basic-gw" {
  vpc_id = aws_vpc.basic-vpc.id
}



# Create customer route table
resource "aws_route_table" "basic-route-table" {

  vpc_id = aws_vpc.basic-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.basic-gw.id
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.basic-gw.id
  }

  tags = {
    Name = "basic-route-table"
  }

}



# Associate the subnet with the route table
resource "aws_route_table_association" "basic-route-table-association" {
  subnet_id      = aws_subnet.basic-vpc-subnet-1.id
  route_table_id = aws_route_table.basic-route-table.id
}


# Create a security group to allow 22,80,443
resource "aws_security_group" "basic-sg" {

  name        = "basic-sg-for-web"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.basic-vpc.id

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "For Web"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Allow_Web"
  }
}


# Create a network interface with an IP in the subnet that was created in step 4
resource "aws_network_interface" "basic-nic" {
  subnet_id       = aws_subnet.basic-vpc-subnet-1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.basic-sg.id]

}


# Assign an elastic IP to the network interface created in step 8
resource "aws_eip" "basic-eip" {
  vpc                       = true
  network_interface         = aws_network_interface.basic-nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on                = [aws_internet_gateway.basic-gw]
}


# Create a ubuntu serve
resource "aws_instance" "basic-ec2" {

  ami               = "ami-0da13880f921c96a5"
  instance_type     = "t2.micro"
  availability_zone = "ap-northeast-3a"
  key_name          = "general"

  # 
  # vpc_id = aws_vpc.basic-vpc.id
  # subnet_id                   = aws_subnet.basic-vpc-subnet-2.id
  # associate_public_ip_address = false

  # If network interface is used, comment out the subnet_id
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.basic-nic.id
  }

  user_data = <<-EOF
                #!/bin/bash
                sudo apt-get update
                sudo apt-get install -y nginx
                sudo service nginx start
                EOF

  tags = {
    Name = "web-basic-ec2"
  }
}


