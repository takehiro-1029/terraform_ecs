# Ref: https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.0"

  name                 = "my-vpc"
  cidr                 = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  azs            = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

  #デフォルトセキュリティグループのルール削除
  manage_default_security_group  = true
  default_security_group_ingress = []
  default_security_group_egress  = []
}

# Ref: https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/latest
module "security-group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.9.0"

  name        = "user-service"
  description = "Security group for user-service "
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "mysql-tcp", "ssh-tcp", "http-8080-tcp"]
  egress_rules        = ["all-all"]
}

# タスク定義
# resource "aws_ecs_task_definition" "task" {
#   family                   = "httpd-task"
#   #0.25vCPU
#   cpu                      = "256"
#   #0.5GB
#   memory                   = "512"
#   network_mode             = "awsvpc"
#   requires_compatibilities = ["FARGATE"]
#   container_definitions    = file("./container_definitions.json")
# }

# cluster
resource "aws_ecs_cluster" "cluster" {
  name = var.ecs_cluster_name
}

# service
resource "aws_ecs_service" "service" {
  name             = var.ecs_service_name
  cluster          = aws_ecs_cluster.cluster.arn
  task_definition  = var.task_definition
  desired_count    = 1
  launch_type      = "FARGATE"
  platform_version = "1.4.0"

  network_configuration {
    assign_public_ip = true
    security_groups  = [module.security-group.security_group_id]
    subnets          = module.vpc.public_subnets
  }

  ## デプロイ毎にタスク定義が更新されるため、リソース初回作成時を除き変更を無視
  lifecycle {
    ignore_changes = [task_definition]
  }
}




