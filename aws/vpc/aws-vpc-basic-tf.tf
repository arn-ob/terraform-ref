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
  region  = "ap-northeast-3"  # Osaka
  profile = "arn"
}

resource "aws_vpc" "basic-vpc" {
  
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "basic-vpc"
  }
}

resource "aws_subnet" "basic-vpc-subnet-1" {
  
  vpc_id = aws_vpc.basic-vpc.id
  cidr_block = "10.0.1.0/26"

  tags = {
    Name = "basic-vpc-subnet-1"
  }
}

resource "aws_subnet" "basic-vpc-subnet-2" {
  
  vpc_id = aws_vpc.basic-vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "basic-vpc-subnet-2"
  }
}
