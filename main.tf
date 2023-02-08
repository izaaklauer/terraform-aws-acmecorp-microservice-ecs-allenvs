terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.6"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}


module "dev" {
  source  = "app.terraform.io/acmecorpinfra/waypoint-ecs/aws"
  version = "0.0.1"

  # App-specific config
  waypoint_project = var.waypoint_project
  application_port = 3000 # TODO(izaak): allow to be configured via input variables. It's pretty draconian to not allow app devs to choose this.

  waypoint_workspace = "dev"

  # Module config
  alb_internal = true
  create_ecr   = true

  # Existing infrastructure
  aws_region       = "us-east-1"
  vpc_id           = data.terraform_remote_state.networking-dev-us-east-1.outputs.vpc_id
  public_subnets   = data.terraform_remote_state.networking-dev-us-east-1.outputs.private_subnets
  private_subnets  = data.terraform_remote_state.networking-dev-us-east-1.outputs.public_subnets
  ecs_cluster_name = data.terraform_remote_state.microservice-infra-dev-us-east-1.outputs.ecs_cluster_name
  log_group_name   = data.terraform_remote_state.microservice-infra-dev-us-east-1.outputs.log_group_name

  tags = {
    env       = "dev"
    corp      = "acmecorp"
    workload  = "microservice"
    project   = var.waypoint_project
  }
}


module "prod" {
  source  = "app.terraform.io/acmecorpinfra/waypoint-ecs/aws"
  version = "0.0.1"

  # App-specific config
  waypoint_project = var.waypoint_project
  application_port = 3000 # TODO(izaak): allow to be configured via input variables. It's pretty draconian to not allow app devs to choose this.

  waypoint_workspace = "prod"

  # Module config
  alb_internal = false
  create_ecr   = false # already created in dev

  # Existing infrastructure
  aws_region       = "us-east-1"
  vpc_id           = data.terraform_remote_state.networking-prod-us-east-1.outputs.vpc_id
  public_subnets   = data.terraform_remote_state.networking-prod-us-east-1.outputs.private_subnets
  private_subnets  = data.terraform_remote_state.networking-prod-us-east-1.outputs.public_subnets
  ecs_cluster_name = data.terraform_remote_state.microservice-infra-prod-us-east-1.outputs.ecs_cluster_name
  log_group_name   = data.terraform_remote_state.microservice-infra-prod-us-east-1.outputs.log_group_name

  tags = {
    env       = "prod"
    corp      = "acmecorp"
    workload  = "microservice"
    project   = var.waypoint_project
  }
}
