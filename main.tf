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

resource "aws_scheduler_schedule" "schedule" {
  name                         = var.name
  name_prefix                  = var.name_prefix
  group_name                   = var.group_name
  schedule_expression          = var.schedule_expression
  schedule_expression_timezone = var.schedule_expression_timezone
  description                  = var.description
  state                        = var.state
  start_date                   = var.start_date
  end_date                     = var.end_date
  kms_key_arn                  = var.kms_key_arn

  flexible_time_window {
    mode                      = var.flexible_time_window.mode
    maximum_window_in_minutes = try(var.flexible_time_window.maximum_window_in_minutes, null)
  }

  target {
    arn      = var.schedule_target.arn
    role_arn = var.schedule_target.role_arn
    input    = try(var.schedule_target.input, null)

    dynamic "dead_letter_config" {
      for_each = var.schedule_target.dead_letter_config != null ? [var.schedule_target.dead_letter_config] : []
      content {
        arn = dead_letter_config.value.arn
      }
    }

    dynamic "retry_policy" {
      for_each = var.schedule_target.retry_policy != null ? [var.schedule_target.retry_policy] : []
      content {
        maximum_event_age_in_seconds = try(retry_policy.value.maximum_event_age_in_seconds, null)
        maximum_retry_attempts       = try(retry_policy.value.maximum_retry_attempts, null)
      }
    }

    dynamic "ecs_parameters" {
      for_each = var.schedule_target.ecs_parameters != null ? [var.schedule_target.ecs_parameters] : []
      content {
        task_definition_arn     = ecs_parameters.value.task_definition_arn
        group                   = try(ecs_parameters.value.group, null)
        launch_type             = try(ecs_parameters.value.launch_type, null)
        platform_version        = try(ecs_parameters.value.platform_version, null)
        propagate_tags          = try(ecs_parameters.value.propagate_tags, null)
        reference_id            = try(ecs_parameters.value.reference_id, null)
        task_count              = try(ecs_parameters.value.task_count, null)
        enable_ecs_managed_tags = try(ecs_parameters.value.enable_ecs_managed_tags, null)
        enable_execute_command  = try(ecs_parameters.value.enable_execute_command, null)

        dynamic "capacity_provider_strategy" {
          for_each = try(ecs_parameters.value.capacity_provider_strategy, [])
          content {
            base              = try(capacity_provider_strategy.value.base, null)
            capacity_provider = capacity_provider_strategy.value.capacity_provider
            weight            = try(capacity_provider_strategy.value.weight, null)
          }
        }

        dynamic "network_configuration" {
          for_each = try(ecs_parameters.value.network_configuration, null) != null ? [ecs_parameters.value.network_configuration] : []
          content {
            assign_public_ip = try(network_configuration.value.assign_public_ip, null)
            security_groups  = try(network_configuration.value.security_groups, null)
            subnets          = try(network_configuration.value.subnets, null)
          }
        }

        dynamic "placement_constraints" {
          for_each = try(ecs_parameters.value.placement_constraints, [])
          content {
            expression = try(placement_constraints.value.expression, null)
            type       = placement_constraints.value.type
          }
        }

        dynamic "placement_strategy" {
          for_each = try(ecs_parameters.value.placement_strategy, [])
          content {
            field = try(placement_strategy.value.field, null)
            type  = placement_strategy.value.type
          }
        }

        tags = try(ecs_parameters.value.tags, null)
      }
    }

    dynamic "eventbridge_parameters" {
      for_each = var.schedule_target.eventbridge_parameters != null ? [var.schedule_target.eventbridge_parameters] : []
      content {
        detail_type = eventbridge_parameters.value.detail_type
        source      = eventbridge_parameters.value.source
      }
    }

    dynamic "kinesis_parameters" {
      for_each = var.schedule_target.kinesis_parameters != null ? [var.schedule_target.kinesis_parameters] : []
      content {
        partition_key = kinesis_parameters.value.partition_key
      }
    }

    dynamic "sagemaker_pipeline_parameters" {
      for_each = var.schedule_target.sagemaker_pipeline_parameters != null ? [var.schedule_target.sagemaker_pipeline_parameters] : []
      content {
        dynamic "pipeline_parameter" {
          for_each = try(sagemaker_pipeline_parameters.value.pipeline_parameter, [])
          content {
            name  = pipeline_parameter.value.name
            value = pipeline_parameter.value.value
          }
        }
      }
    }

    dynamic "sqs_parameters" {
      for_each = var.schedule_target.sqs_parameters != null ? [var.schedule_target.sqs_parameters] : []
      content {
        message_group_id = try(sqs_parameters.value.message_group_id, null)
      }
    }
  }
}
