terraform {
  required_version = ">= 1.3.0"
  backend "s3" {
    bucket         = "hemant-terraform-state-project-1"
    key            = "project-1/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
  }
}

provider "aws" {
  region = var.region
}



# ──────────────────────────────
# VPC MODULE
# ──────────────────────────────
module "vpc" {
  # Static string literal path is REQUIRED for the source attribute
  source              = "../../modules/vpc"
  project             = var.project
  vpc_cidr            = var.vpc_cidr
  # ... other variables
}

# ──────────────────────────────
# SECURITY GROUP MODULE
# ──────────────────────────────
module "security" {
  source  = "../../modules/security"
  vpc_id  = module.vpc.vpc_id
  project = var.project
}

# ──────────────────────────────
# EC2 MODULE
# ──────────────────────────────
module "ec2" {
  source              = "../../modules/ec2"
  # ... other variables
}
