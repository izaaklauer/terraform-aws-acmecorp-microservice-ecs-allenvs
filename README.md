# Acmecorp microservice module

< DISCLAIMER: Sample module for a fictional company acmecorp, built as an example, not maintained >

If you're bootstrapping a microservice in acmecorp, start here!

This module will create all the foundational infrastructure that your application needs, across all environments.
You can consume this as a terraform cloud no-code module. After instantiating the workspace, you can consume
the workspace outputs in your waypoint.hcl.


# Waypoint

After you've created a workspace (and built your app), fill in this waypoint.hcl template and add it to your repo:

```
project = "<YOUR_APP_NAME>"

app "<YOUR_APP_NAME>" {
  labels = {
    "owner" = "izaak",
    "corp" = "acmecorp"
  }

  build {
    use "pack" {}

    registry {
      use "aws-ecr" {
        region     = "us-east-1"
        repository = var.ecr_registry
        tag        = gitrefpretty()
      }
    }
  }

  deploy {
    use "aws-ecs" {
      count            = 1
      memory           = 512
      cpu              = 256
      service_port     = 3000
      assign_public_ip = false
      logging {
        create_group = false
      }

      cluster             = var.tfc_infra.dev.ecs_cluster_name
      log_group           = var.tfc_infra.dev.log_group_name
      execution_role_name = var.tfc_infra.dev.execution_role_name
      task_role_name      = var.tfc_infra.dev.task_role_name
      region              = var.tfc_infra.dev.region
      subnets             = var.tfc_infra.dev.private_subnets
      security_group_ids  = [var.tfc_infra.dev.security_group_id]
      alb {
        load_balancer_arn = var.tfc_infra.dev.alb_arn
        subnets           = var.tfc_infra.dev.public_subnets
      }
    }

    workspace "prod" {
      use "aws-ecs" {
        count            = 1
        memory           = 512
        cpu              = 256
        service_port     = 3000
        assign_public_ip = false
        logging {
          create_group = false
        }

        cluster             = var.tfc_infra.prod.ecs_cluster_name
        log_group           = var.tfc_infra.prod.log_group_name
        execution_role_name = var.tfc_infra.prod.execution_role_name
        task_role_name      = var.tfc_infra.prod.task_role_name
        region              = var.tfc_infra.prod.region
        subnets             = var.tfc_infra.prod.private_subnets
        security_group_ids  = [var.tfc_infra.prod.security_group_id]
        alb {
          load_balancer_arn = var.tfc_infra.prod.alb_arn
          subnets           = var.tfc_infra.prod.public_subnets
        }
      }
    }
  }
}

variable "tfc_infra" {
  default = dynamic("terraform-cloud", {
    organization = "acmecorpinfra"
    workspace    = "<YOUR_APP_NAME>-nocode"
  })
  type        = any
  sensitive   = false
  description = "all outputs from this app's tfc workspace"
}

```
