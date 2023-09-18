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

  name                 = "second-vpc"
  cidr                 = "10.10.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  public_subnets       = ["10.10.3.0/24", "10.10.4.0/24", "10.10.5.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_db_subnet_group" "second-subnet" {
  name       = "second"
  subnet_ids = module.vpc.public_subnets

  tags = {
    Name = "Second"
  }
}

resource "aws_security_group" "second-sg" {
  name   = "second-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 6379
    to_port = 6379
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 6379
    to_port = 6379
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS Instance
resource "aws_db_instance" "firsTerraDB" {
  identifier             = "second-terra-db"
  allocated_storage      = 10
  db_name                = var.db_name
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t2.micro"
  username               = var.db_username
  password               = var.db_password
  parameter_group_name   = "default.mysql8.0"
  db_subnet_group_name   = aws_db_subnet_group.second-subnet.name
  vpc_security_group_ids = [aws_security_group.second-sg.id]
  publicly_accessible    = true
  skip_final_snapshot    = true
}


# Redis Cluster
resource "aws_elasticache_subnet_group" "second-cluster-sg" {
  name       = "second-cluster-subnet"
  subnet_ids = module.vpc.public_subnets
}

resource "aws_elasticache_cluster" "second-cluster" {
  cluster_id           = "second-cluster-id"
  engine               = "redis"
  node_type            = "cache.t4g.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis5.0"
  engine_version       = "5.0.6"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.second-cluster-sg.name
}

# Lambda function

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

resource "aws_iam_role_policy_attachment" "AWSLambdaVPCAccessExecutionRole" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_lambda_layer_version" "function_packages" {
  filename            = "./code/packages.zip"
  layer_name          = "function_packages"
  compatible_runtimes = ["python3.9"]
}

data "archive_file" "lambda_function" {
  type        = "zip"
  source_file = "./code/lambda_function.py"
  output_path = "deployment_payload.zip"
}

resource "aws_lambda_function" "first_lambda" {
  filename      = "deployment_payload.zip"
  function_name = "first_function"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda_function.lambda_handler"
  layers        = [aws_lambda_layer_version.function_packages.arn]

  source_code_hash = data.archive_file.lambda_function.output_base64sha256

  runtime = "python3.9"

  vpc_config {
    subnet_ids         = module.vpc.public_subnets
    security_group_ids = [aws_security_group.second-sg.id]
  }

  environment {
    variables = {
      MYSQL_HOST     = aws_db_instance.firsTerraDB.address
      MYSQL_PORT     = aws_db_instance.firsTerraDB.port
      MYSQL_USER     = aws_db_instance.firsTerraDB.username
      MYSQL_PASSWORD = aws_db_instance.firsTerraDB.password
      MYSQL_DB       = aws_db_instance.firsTerraDB.db_name

      REDIS_URL  = "${aws_elasticache_cluster.second-cluster.cache_nodes.0.address}"
      REDIS_PORT = "${aws_elasticache_cluster.second-cluster.cache_nodes.0.port}"
    }
  }
}