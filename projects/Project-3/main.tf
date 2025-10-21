terraform {
  required_version = ">= 1.3.0"
  backend "s3" {
    bucket         = "hemant-terraform-state-project-3"
    key            = "project-3/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-3"
  }
}

provider "aws" {
  region = var.region
}

# ──────────────────────────────
# VPC MODULE
# ──────────────────────────────
module "vpc" {
  source              = "../../modules/vpc"
  project             = var.project
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  az_1                = var.az_1
  az_2                = var.az_2
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
  source            = "../../modules/ec2"
  project           = var.project
  ami_id            = var.ami_id
  instance_type     = var.instance_type
  sg_id             = module.security.sg_id
  public_subnet_id  = module.vpc.public_subnet_id
  private_subnet_id = module.vpc.private_subnet_id
  instance_count    = var.instance_count
  assign_public_ip  = var.assign_public_ip
}
