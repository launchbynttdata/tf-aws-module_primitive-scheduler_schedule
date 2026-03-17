# Complete Example - AWS Scheduler Schedule

This example creates an EventBridge Scheduler schedule that sends messages to an SQS queue on a recurring basis. The SQS queue uses customer-managed KMS encryption (FG_R00070 compliant) with automatic key rotation enabled.

## Usage

```hcl
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

resource "aws_sqs_queue" "schedule_target" {
  name = module.resource_names["sqsqueue"].standard
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

resource "aws_iam_role_policy" "scheduler_sqs" {
  name   = "scheduler-sqs-send"
  role   = aws_iam_role.scheduler.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.schedule_target.arn
      }
    ]
  })
}

module "scheduler_schedule" {
  source = "../.."

  name        = var.name_prefix != null ? null : coalesce(var.name, module.resource_names["sched"].standard)
  name_prefix = var.name_prefix
  group_name  = var.group_name

  schedule_expression         = var.schedule_expression
  schedule_expression_timezone = var.schedule_expression_timezone
  description                 = var.description
  state                       = var.state
  action_after_completion     = var.action_after_completion
  start_date                  = var.start_date
  end_date                    = var.end_date
  region                      = var.region
  kms_key_arn                 = var.kms_key_arn

  flexible_time_window = {
    mode                     = var.flexible_time_window_mode
    maximum_window_in_minutes = var.flexible_time_window_maximum_minutes
  }

  schedule_target = {
    arn      = aws_sqs_queue.schedule_target.arn
    role_arn = aws_iam_role.scheduler.arn
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| logical_product_family | Logical product family for resource naming | `string` | n/a | yes |
| logical_product_service | Logical product service for resource naming | `string` | n/a | yes |
| class_env | Class environment for resource naming | `string` | n/a | yes |
| instance_env | Instance environment number (0-999) | `number` | n/a | yes |
| instance_resource | Instance resource number (0-100) | `number` | n/a | yes |
| resource_names_map | Map of resource types to naming configuration | `map(object)` | n/a | yes |
| use_azure_region_abbr | Use Azure region abbreviation in naming | `bool` | `false` | no |
| schedule_expression | When the schedule runs | `string` | `"rate(1 hour)"` | no |
| schedule_expression_timezone | Timezone for scheduling | `string` | `"UTC"` | no |
| description | Schedule description | `string` | `null` | no |
| state | ENABLED or DISABLED | `string` | `"ENABLED"` | no |
| start_date | Start date in UTC | `string` | `null` | no |
| end_date | End date in UTC | `string` | `null` | no |
| kms_key_arn | KMS key ARN | `string` | `null` | no |
| flexible_time_window_mode | OFF or FLEXIBLE | `string` | `"OFF"` | no |
| flexible_time_window_maximum_minutes | Max window minutes for FLEXIBLE | `number` | `null` | no |
| name | Schedule name | `string` | `null` | no |
| name_prefix | Schedule name prefix | `string` | `null` | no |
| group_name | Schedule group name | `string` | `"default"` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the schedule |
| arn | The ARN of the schedule |
| name | The name of the schedule |
| group_name | The schedule group name |
| queue_url | The URL of the SQS queue used as the schedule target |
| region | The AWS region where resources were created |

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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_resource_names"></a> [resource\_names](#module\_resource\_names) | terraform.registry.launch.nttdata.com/module_library/resource_name/launch | ~> 2.0 |
| <a name="module_scheduler_schedule"></a> [scheduler\_schedule](#module\_scheduler\_schedule) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.scheduler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.scheduler_sqs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_kms_key.sqs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_sqs_queue.schedule_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_logical_product_family"></a> [logical\_product\_family](#input\_logical\_product\_family) | Logical product family for resource naming. | `string` | n/a | yes |
| <a name="input_logical_product_service"></a> [logical\_product\_service](#input\_logical\_product\_service) | Logical product service for resource naming. | `string` | n/a | yes |
| <a name="input_class_env"></a> [class\_env](#input\_class\_env) | Class environment for resource naming (e.g., dev, prod). | `string` | n/a | yes |
| <a name="input_instance_env"></a> [instance\_env](#input\_instance\_env) | Instance environment number for resource naming (0-999). | `number` | n/a | yes |
| <a name="input_instance_resource"></a> [instance\_resource](#input\_instance\_resource) | Instance resource number for resource naming (0-100). | `number` | n/a | yes |
| <a name="input_resource_names_map"></a> [resource\_names\_map](#input\_resource\_names\_map) | Map of resource types to naming configuration. | <pre>map(object({<br/>    name       = string<br/>    max_length = number<br/>  }))</pre> | n/a | yes |
| <a name="input_use_azure_region_abbr"></a> [use\_azure\_region\_abbr](#input\_use\_azure\_region\_abbr) | Whether to use Azure region abbreviation in naming. | `bool` | `false` | no |
| <a name="input_schedule_expression"></a> [schedule\_expression](#input\_schedule\_expression) | Defines when the schedule runs. | `string` | `"rate(1 minute)"` | no |
| <a name="input_schedule_expression_timezone"></a> [schedule\_expression\_timezone](#input\_schedule\_expression\_timezone) | Timezone for the scheduling expression. | `string` | `"UTC"` | no |
| <a name="input_description"></a> [description](#input\_description) | Brief description of the schedule. | `string` | `null` | no |
| <a name="input_state"></a> [state](#input\_state) | Whether the schedule is enabled or disabled. | `string` | `"ENABLED"` | no |
| <a name="input_start_date"></a> [start\_date](#input\_start\_date) | Start date for the schedule in UTC. | `string` | `null` | no |
| <a name="input_end_date"></a> [end\_date](#input\_end\_date) | End date for the schedule in UTC. | `string` | `null` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | KMS key ARN for encryption. | `string` | `null` | no |
| <a name="input_flexible_time_window_mode"></a> [flexible\_time\_window\_mode](#input\_flexible\_time\_window\_mode) | Mode for flexible time window (OFF or FLEXIBLE). | `string` | `"OFF"` | no |
| <a name="input_flexible_time_window_maximum_minutes"></a> [flexible\_time\_window\_maximum\_minutes](#input\_flexible\_time\_window\_maximum\_minutes) | Maximum window in minutes for FLEXIBLE mode. | `number` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the schedule. Conflicts with name\_prefix. | `string` | `null` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Name prefix for the schedule. Conflicts with name. | `string` | `null` | no |
| <a name="input_group_name"></a> [group\_name](#input\_group\_name) | Schedule group name. | `string` | `"default"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The ID of the schedule. |
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the schedule. |
| <a name="output_name"></a> [name](#output\_name) | The name of the schedule. |
| <a name="output_group_name"></a> [group\_name](#output\_group\_name) | The schedule group name. |
| <a name="output_queue_url"></a> [queue\_url](#output\_queue\_url) | The URL of the SQS queue used as the schedule target. |
| <a name="output_region"></a> [region](#output\_region) | The AWS region where resources were created. |
<!-- END_TF_DOCS -->
