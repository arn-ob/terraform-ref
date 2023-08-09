# Plan
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

  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "basic-vpc"
  }
}

# Create Subnet
resource "aws_subnet" "basic-vpc-subnet-1" {

  vpc_id     = aws_vpc.basic-vpc.id
  cidr_block = "10.0.1.0/26"

  tags = {
    Name = "basic-vpc-subnet-1"
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
    cidr_block = "10.0.1.0/26"
    gateway_id = aws_internet_gateway.basic-gw.id
  }

  route {
    cidr_block             = "0.0.0.0/0"
    egress_only_gateway_id = aws_internet_gateway.basic-gw.id
  }

  tags {
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

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.basic-vpc.cidr_block]
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

  tags {
    Name = "Allow_Web"
  }
}

# Create a network interface with an IP in the subnet that was created in step 4







