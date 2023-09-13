terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure AWS Provider
provider "aws" {
  region = "us-west-2"
}

data "aws_availability_zones" "available" {}

# Create a VPC
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name                 = "first"
  cidr                 = "10.10.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  public_subnets       = ["10.10.3.0/24", "10.10.4.0/24", "10.10.5.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_db_subnet_group" "first" {
  name       = "first"
  subnet_ids = module.vpc.public_subnets

  tags = {
    Name = "First"
  }
}

resource "aws_security_group" "first" {
  name   = "first-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

## RDS Instance
resource "aws_db_instance" "firsTerraDB" {
  identifier             = "first-terra-db"
  allocated_storage      = 10
  db_name                = var.db_name
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t2.micro"
  username               = var.db_username
  password               = var.db_password
  parameter_group_name   = "default.mysql8.0"
  db_subnet_group_name   = aws_db_subnet_group.first.name
  vpc_security_group_ids = [aws_security_group.first.id]
  publicly_accessible    = true
  skip_final_snapshot    = true
}

## Lambda function

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "archive_file" "lambda_function" {
  type        = "zip"
  source_file = "lambda_function.py"
  output_path = "deployment.zip"
}

resource "aws_lambda_function" "first" {
  filename      = "deployment.zip"
  function_name = "first_function"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda_function.lambda_handler"

  source_code_hash = data.archive_file.lambda_function.output_base64sha256

  runtime = "python3.9"

  #security_group_ids = [aws_security_group.first.id]
}