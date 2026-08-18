provider "aws" {
  region = var.aws_region
}

module "networking" {
  source = "./modules/networking"

  vpc_name           = "project-vpc"
  vpc_cidr           = "10.0.0.0/16"
  public_subnet1_cidr  = "10.0.0.0/20"
  public_subnet2_cidr  = "10.0.16.0/20"
  private_subnet1_cidr = "10.0.32.0/20"
  private_subnet2_cidr = "10.0.48.0/20"
}

module "compute" {
  source = "./modules/compute"

  vpc_id            = module.networking.vpc_id
  public_subnet1_id = module.networking.public_subnet1_id
  admin_ingress_cidr = var.admin_ingress_cidr
}

module "iam" {
  source = "./modules/iam"
}

module "monitoring" {
  source = "./modules/monitoring"

  vpc_id             = module.networking.vpc_id
  cloudtrail_bucket_name = var.audit_logs_bucket_name
  security_read_role_arn = module.iam.security_audit_read_role_arn
  flow_logs_role_name = "project-vpc-flowlogs-role"
  cloudtrail_name     = "project-cloudtrail"
}

module "automation" {
  source = "./modules/automation"

  alert_email = var.alert_email
}
