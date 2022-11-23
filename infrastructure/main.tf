module "AutoScaling" {
  source           = "./modules/AutoScaling"
  instance_type    = var.instance_type
  security_groups  = module.Security_Groups.internal_webserver
  private_subnets  = module.Networking.private_subnets
  target_group_arn = module.Load_Balancing.webserver_tg
}

module "Compute" {
  source                    = "./modules/Compute"
  linux_ami                 = var.linux_ami
  windows_ami               = var.windows_ami
  instance_type             = var.instance_type
  public_bastion            = module.Security_Groups.public_bastion
  windows_rdp               = module.Security_Groups.public_rdp
  windows_admin_workstation = module.Security_Groups.private_rdp
  internal_apache_webserver = module.Security_Groups.internal_webserver
  public_subnet             = module.Networking.public_subnets
  private_subnet            = module.Networking.private_subnets
  webserver_tg              = module.Load_Balancing.webserver_tg
  al2_instance_profile      = module.Systems_Manager.al2_ssm_profile
  win_instance_profile      = module.Systems_Manager.win_ssm_profile
  user_data                 = file("./userdata.tpl")
}

module "Database" {
  source            = "./modules/Database"
  allocated_storage = var.allocated_storage
  engine            = var.engine
  engine_version    = var.engine_version
  instance_class    = var.instance_class
  multi_az          = false
  db_name           = var.db_name
  subnet_ids        = module.Networking.private_subnets
  security_groups   = module.Security_Groups.private_database_sg
}

module "Load_Balancing" {
  source                 = "./modules/Load_Balancing"
  vpc_id                 = module.Networking.vpc_id
  certificate_arn        = module.Route53.certificate_arn
  security_groups        = module.Security_Groups.internal_alb
  private_subnets        = module.Networking.private_subnets
  lb_healthy_threshold   = 3
  lb_unhealthy_threshold = 10
  lb_timeout             = 20
  lb_interval            = 30
}

module "Networking" {
  source           = "./modules/Networking"
  vpc_cidr         = var.vpc_id
  private_sn_count = var.private_sn_count
  public_sn_count  = var.public_sn_count
  internal_ec2     = module.Compute.internal_webserver
}

module "Route53" {
  source  = "./modules/Route53"
  records = module.Load_Balancing.lb_dns_name
  vpc_id  = module.Networking.vpc_id
}

module "Security_Groups" {
  source = "./modules/Security_Groups"
  vpc_id = module.Networking.vpc_id
}

module "Systems_Manager" {
  source                     = "./modules/Systems_Manager"
  internal_webserver         = module.Compute.internal_webserver
  internal_admin_workstation = module.Compute.internal_admin_workstation
  vpc_id                     = module.Networking.vpc_id
  security_group             = module.Security_Groups.internal_alb
  subnet_ids                 = module.Networking.private_subnets
}

terraform {
  backend "s3" {
    bucket         = "tf-project-remote-state-backend-s3-bucket"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-s3-backend"
  }
}