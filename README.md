# Terraform AWS Module - EventBridge Scheduler Schedule

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## Overview

This Terraform module creates an [AWS EventBridge Scheduler Schedule](https://docs.aws.amazon.com/scheduler/latest/UserGuide/what-is-scheduler.html) resource. EventBridge Scheduler allows you to create schedules that invoke targets such as SQS queues, Lambda functions, ECS tasks, and more on a recurring or one-time basis.

## Usage

```hcl
module "scheduler_schedule" {
  source = "terraform.registry.launch.nttdata.com/module_primitive/scheduler_schedule/aws"
  version = "~> 1.0"

  name       = "my-schedule"
  group_name = "default"

  schedule_expression = "rate(1 hour)"

  flexible_time_window = {
    mode = "OFF"
  }

  schedule_target = {
    arn      = aws_sqs_queue.example.arn
    role_arn = aws_iam_role.scheduler.arn
  }
}
```

## Examples

See the [examples/complete](./examples/complete) directory for a full working example that creates an SQS queue, IAM role, and scheduler schedule.

## Documentation

- [AWS EventBridge Scheduler User Guide](https://docs.aws.amazon.com/scheduler/latest/UserGuide/what-is-scheduler.html)
- [Terraform aws_scheduler_schedule resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/scheduler_schedule)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.14 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.100.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_scheduler_schedule.schedule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/scheduler_schedule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Name of the schedule. If omitted, Terraform will assign a random, unique name. Conflicts with name\_prefix. | `string` | `null` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Creates a unique name beginning with the specified prefix. Conflicts with name. | `string` | `null` | no |
| <a name="input_group_name"></a> [group\_name](#input\_group\_name) | Name of the schedule group to associate with this schedule. When omitted, the default schedule group is used. | `string` | `"default"` | no |
| <a name="input_schedule_expression"></a> [schedule\_expression](#input\_schedule\_expression) | Defines when the schedule runs. See Schedule types on EventBridge Scheduler. | `string` | n/a | yes |
| <a name="input_schedule_expression_timezone"></a> [schedule\_expression\_timezone](#input\_schedule\_expression\_timezone) | Timezone in which the scheduling expression is evaluated. Defaults to UTC. | `string` | `"UTC"` | no |
| <a name="input_description"></a> [description](#input\_description) | Brief description of the schedule. | `string` | `null` | no |
| <a name="input_state"></a> [state](#input\_state) | Specifies whether the schedule is enabled or disabled. One of: ENABLED (default), DISABLED. | `string` | `"ENABLED"` | no |
| <a name="input_start_date"></a> [start\_date](#input\_start\_date) | The date, in UTC, after which the schedule can begin invoking its target. Example: 2030-01-01T01:00:00Z. | `string` | `null` | no |
| <a name="input_end_date"></a> [end\_date](#input\_end\_date) | The date, in UTC, before which the schedule can invoke its target. Example: 2030-01-01T01:00:00Z. | `string` | `null` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | ARN for the customer managed KMS key that EventBridge Scheduler will use to encrypt and decrypt your data. | `string` | `null` | no |
| <a name="input_flexible_time_window"></a> [flexible\_time\_window](#input\_flexible\_time\_window) | Configures a time window during which EventBridge Scheduler invokes the schedule.<br/>- mode: OFF or FLEXIBLE (required)<br/>- maximum\_window\_in\_minutes: 1 to 1440 (optional, for FLEXIBLE mode) | <pre>object({<br/>    mode                      = string<br/>    maximum_window_in_minutes = optional(number)<br/>  })</pre> | n/a | yes |
| <a name="input_schedule_target"></a> [schedule\_target](#input\_schedule\_target) | Configures the target of the schedule.<br/>Required: arn, role\_arn<br/>Optional: input, dead\_letter\_config, retry\_policy, ecs\_parameters, eventbridge\_parameters, kinesis\_parameters, sagemaker\_pipeline\_parameters, sqs\_parameters | <pre>object({<br/>    arn      = string<br/>    role_arn = string<br/>    input    = optional(string)<br/><br/>    dead_letter_config = optional(object({<br/>      arn = string<br/>    }))<br/><br/>    retry_policy = optional(object({<br/>      maximum_event_age_in_seconds = optional(number)<br/>      maximum_retry_attempts       = optional(number)<br/>    }))<br/><br/>    ecs_parameters = optional(object({<br/>      task_definition_arn     = string<br/>      group                   = optional(string)<br/>      launch_type             = optional(string)<br/>      platform_version        = optional(string)<br/>      propagate_tags          = optional(string)<br/>      reference_id            = optional(string)<br/>      task_count              = optional(number)<br/>      enable_ecs_managed_tags = optional(bool)<br/>      enable_execute_command  = optional(bool)<br/><br/>      capacity_provider_strategy = optional(list(object({<br/>        base              = optional(number)<br/>        capacity_provider = string<br/>        weight            = optional(number)<br/>      })))<br/><br/>      network_configuration = optional(object({<br/>        assign_public_ip = optional(bool)<br/>        security_groups  = optional(list(string))<br/>        subnets          = optional(list(string))<br/>      }))<br/><br/>      placement_constraints = optional(list(object({<br/>        expression = optional(string)<br/>        type       = string<br/>      })))<br/><br/>      placement_strategy = optional(list(object({<br/>        field = optional(string)<br/>        type  = string<br/>      })))<br/><br/>      tags = optional(map(string))<br/>    }))<br/><br/>    eventbridge_parameters = optional(object({<br/>      detail_type = string<br/>      source      = string<br/>    }))<br/><br/>    kinesis_parameters = optional(object({<br/>      partition_key = string<br/>    }))<br/><br/>    sagemaker_pipeline_parameters = optional(object({<br/>      pipeline_parameter = optional(list(object({<br/>        name  = string<br/>        value = string<br/>      })))<br/>    }))<br/><br/>    sqs_parameters = optional(object({<br/>      message_group_id = optional(string)<br/>    }))<br/>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The ID of the schedule (group\_name/name format). |
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the schedule. |
| <a name="output_name"></a> [name](#output\_name) | The name of the schedule. |
<!-- END_TF_DOCS -->
