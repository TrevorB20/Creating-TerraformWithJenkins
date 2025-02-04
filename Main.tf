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
  region = "us-east-1"
}

#Creating EC2 Instance

resource "aws_instance" "JenkinsEC2Server" {
  ami                    = "ami-0c614dee691cbbf37"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.JenkinsSG.id]
  subnet_id              = "subnet-0fa21531e3c4921e4"
  key_name               = "Ec2Kp"

  #UserData To Install Jenkins
  user_data = file("UserData_Script.sh")
  tags = {
    Name = "JenkinsEC2Server"
  }
}
#Create Security Group For Server
resource "aws_security_group" "JenkinsSG" {
  name        = "JenkinsSG"
  description = "Allow traffic on port 8080 and on port 22"
  vpc_id      = "vpc-0f0dff515f59e2cfb"

  tags = {
    Name = "JenkinsSG"
  }


  #Allow Acces on port 8080
  ingress {
    protocol    = "tcp"
    from_port   = 8080
    to_port     = 8080
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Allow Traffic on port 443
  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }
  #Allow access on port 22
  ingress {
    protocol    = "tcp"
    self        = true
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["AddyourownIP/32"] #Get Your Own IP from your Loacl machine
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# My S3 Bucket
resource "aws_s3_bucket" "jenkins557" {
  bucket = "jenkins-557"
}

resource "aws_s3_bucket_public_access_block" "jenkins_acl" {
  bucket = aws_s3_bucket.jenkins557.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
