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

# -----------------------------------------------------------------------------
# Schedule identification
# -----------------------------------------------------------------------------

variable "name" {
  description = "Name of the schedule. If omitted, Terraform will assign a random, unique name. Conflicts with name_prefix."
  type        = string
  default     = null
}

variable "name_prefix" {
  description = "Creates a unique name beginning with the specified prefix. Conflicts with name."
  type        = string
  default     = null

  validation {
    condition     = var.name == null || var.name_prefix == null
    error_message = "Name and name_prefix cannot both be set."
  }
}

variable "group_name" {
  description = "Name of the schedule group to associate with this schedule. When omitted, the default schedule group is used."
  type        = string
  default     = "default"
}

# -----------------------------------------------------------------------------
# Schedule configuration
# -----------------------------------------------------------------------------

variable "schedule_expression" {
  description = "Defines when the schedule runs. See Schedule types on EventBridge Scheduler."
  type        = string
}

variable "schedule_expression_timezone" {
  description = "Timezone in which the scheduling expression is evaluated. Defaults to UTC."
  type        = string
  default     = "UTC"
}

variable "description" {
  description = "Brief description of the schedule."
  type        = string
  default     = null
}

variable "state" {
  description = "Specifies whether the schedule is enabled or disabled. One of: ENABLED (default), DISABLED."
  type        = string
  default     = "ENABLED"

  validation {
    condition     = contains(["ENABLED", "DISABLED"], var.state)
    error_message = "State must be ENABLED or DISABLED."
  }
}

variable "start_date" {
  description = "The date, in UTC, after which the schedule can begin invoking its target. Example: 2030-01-01T01:00:00Z."
  type        = string
  default     = null
}

variable "end_date" {
  description = "The date, in UTC, before which the schedule can invoke its target. Example: 2030-01-01T01:00:00Z."
  type        = string
  default     = null
}

variable "kms_key_arn" {
  description = "ARN for the customer managed KMS key that EventBridge Scheduler will use to encrypt and decrypt your data."
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# flexible_time_window (required)
# -----------------------------------------------------------------------------

variable "flexible_time_window" {
  description = <<-EOT
    Configures a time window during which EventBridge Scheduler invokes the schedule.
    - mode: OFF or FLEXIBLE (required)
    - maximum_window_in_minutes: 1 to 1440 (optional, for FLEXIBLE mode)
  EOT
  type = object({
    mode                      = string
    maximum_window_in_minutes = optional(number)
  })

  validation {
    condition     = contains(["OFF", "FLEXIBLE"], var.flexible_time_window.mode)
    error_message = "Flexible time window mode must be OFF or FLEXIBLE."
  }

  validation {
    condition     = var.flexible_time_window.mode != "FLEXIBLE" ? true : (try(var.flexible_time_window.maximum_window_in_minutes, null) == null ? true : (var.flexible_time_window.maximum_window_in_minutes >= 1 && var.flexible_time_window.maximum_window_in_minutes <= 1440))
    error_message = "Maximum window in minutes must be between 1 and 1440 when using FLEXIBLE mode."
  }
}

# -----------------------------------------------------------------------------
# target (required)
# -----------------------------------------------------------------------------

variable "schedule_target" {
  description = <<-EOT
    Configures the target of the schedule.
    Required: arn, role_arn
    Optional: input, dead_letter_config, retry_policy, ecs_parameters, eventbridge_parameters, kinesis_parameters, sagemaker_pipeline_parameters, sqs_parameters
  EOT
  type = object({
    arn      = string
    role_arn = string
    input    = optional(string)

    dead_letter_config = optional(object({
      arn = string
    }))

    retry_policy = optional(object({
      maximum_event_age_in_seconds = optional(number)
      maximum_retry_attempts       = optional(number)
    }))

    ecs_parameters = optional(object({
      task_definition_arn     = string
      group                   = optional(string)
      launch_type             = optional(string)
      platform_version        = optional(string)
      propagate_tags          = optional(string)
      reference_id            = optional(string)
      task_count              = optional(number)
      enable_ecs_managed_tags = optional(bool)
      enable_execute_command  = optional(bool)

      capacity_provider_strategy = optional(list(object({
        base              = optional(number)
        capacity_provider = string
        weight            = optional(number)
      })))

      network_configuration = optional(object({
        assign_public_ip = optional(bool)
        security_groups  = optional(list(string))
        subnets          = optional(list(string))
      }))

      placement_constraints = optional(list(object({
        expression = optional(string)
        type       = string
      })))

      placement_strategy = optional(list(object({
        field = optional(string)
        type  = string
      })))

      tags = optional(map(string))
    }))

    eventbridge_parameters = optional(object({
      detail_type = string
      source      = string
    }))

    kinesis_parameters = optional(object({
      partition_key = string
    }))

    sagemaker_pipeline_parameters = optional(object({
      pipeline_parameter = optional(list(object({
        name  = string
        value = string
      })))
    }))

    sqs_parameters = optional(object({
      message_group_id = optional(string)
    }))
  })
}
