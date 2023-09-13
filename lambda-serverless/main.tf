terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
}

# Configure AWS Provider
provider "aws" {
  region = "us-west-2"
}

# Create a VPC
resource "aws_vpc" "myTVPC" {
    cidr_block = "10.10.0.0/16"
}

resource "aws_db_instance" "firsTerraDB" {
    identifier = "first-terra-db"
    allocated_storage = 10
    db_name = var.db_name
    engine = "mysql"
    engine_version = "8.0"
    instance_class = "db.t2.micro"
    username = var.db_username
    password = var.db_password
    parameter_group_name = "default.mysql8.0"
    publicly_accessible = true
    skip_final_snapshot = true
}