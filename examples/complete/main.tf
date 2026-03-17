// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

module "resource_names" {
  source  = "terraform.registry.launch.nttdata.com/module_library/resource_name/launch"
  version = "~> 2.0"

  for_each = var.resource_names_map

  logical_product_family  = var.logical_product_family
  logical_product_service = var.logical_product_service
  class_env               = var.class_env
  instance_env            = var.instance_env
  instance_resource       = var.instance_resource
  cloud_resource_type     = each.value.name
  maximum_length          = each.value.max_length

  region                = join("", split("-", data.aws_region.current.name))
  use_azure_region_abbr = var.use_azure_region_abbr
}

resource "aws_iam_role" "scheduler" {
  name = module.resource_names["iamrole"].standard

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "scheduler.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_kms_key" "sqs" {
  description             = "KMS key for SQS queue encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow SQS to use the key"
        Effect = "Allow"
        Principal = {
          Service = "sqs.amazonaws.com"
        }
        Action = [
          "kms:GenerateDataKey",
          "kms:Decrypt"
        ]
        Resource = "*"
      },
      {
        Sid    = "Allow Scheduler role to use the key"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.scheduler.arn
        }
        Action = [
          "kms:GenerateDataKey",
          "kms:Decrypt"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_sqs_queue" "schedule_target" {
  name                              = module.resource_names["sqsqueue"].standard
  kms_master_key_id                 = aws_kms_key.sqs.arn
  kms_data_key_reuse_period_seconds = 300
}

resource "aws_iam_role_policy" "scheduler_sqs" {
  name = "scheduler-sqs-send"
  role = aws_iam_role.scheduler.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.schedule_target.arn
      },
      {
        Effect = "Allow"
        Action = [
          "kms:GenerateDataKey",
          "kms:Decrypt"
        ]
        Resource = aws_kms_key.sqs.arn
      }
    ]
  })
}

module "scheduler_schedule" {
  source = "../.."

  name        = var.name_prefix != null ? null : coalesce(var.name, module.resource_names["sched"].standard)
  name_prefix = var.name_prefix
  group_name  = var.group_name

  schedule_expression          = var.schedule_expression
  schedule_expression_timezone = var.schedule_expression_timezone
  description                  = var.description
  state                        = var.state
  start_date                   = var.start_date
  end_date                     = var.end_date
  kms_key_arn                  = var.kms_key_arn

  flexible_time_window = {
    mode                      = var.flexible_time_window_mode
    maximum_window_in_minutes = var.flexible_time_window_maximum_minutes
  }

  schedule_target = {
    arn      = aws_sqs_queue.schedule_target.arn
    role_arn = aws_iam_role.scheduler.arn
  }
}
