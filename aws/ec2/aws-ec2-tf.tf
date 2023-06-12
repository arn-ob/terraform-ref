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
  region  = "ap-northeast-2"
  profile = "arn"
}

resource "aws_instance" "app_server" {
  ami           = "ami-027886247d2f15359"
  instance_type = "t2.micro"

  tags = {
    Name = "aws-ec2-tf"
  }
}
