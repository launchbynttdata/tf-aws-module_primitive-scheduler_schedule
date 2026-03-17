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

variable "logical_product_family" {
  description = "Logical product family for resource naming."
  type        = string
}

variable "logical_product_service" {
  description = "Logical product service for resource naming."
  type        = string
}

variable "class_env" {
  description = "Class environment for resource naming (e.g., dev, prod)."
  type        = string
}

variable "instance_env" {
  description = "Instance environment number for resource naming (0-999)."
  type        = number
}

variable "instance_resource" {
  description = "Instance resource number for resource naming (0-100)."
  type        = number
}

variable "resource_names_map" {
  description = "Map of resource types to naming configuration."
  type = map(object({
    name       = string
    max_length = number
  }))
}

variable "use_azure_region_abbr" {
  description = "Whether to use Azure region abbreviation in naming."
  type        = bool
  default     = false
}

variable "schedule_expression" {
  description = "Defines when the schedule runs."
  type        = string
  default     = "rate(1 minute)"
}

variable "schedule_expression_timezone" {
  description = "Timezone for the scheduling expression."
  type        = string
  default     = "UTC"
}

variable "description" {
  description = "Brief description of the schedule."
  type        = string
  default     = null
}

variable "state" {
  description = "Whether the schedule is enabled or disabled."
  type        = string
  default     = "ENABLED"
}

variable "start_date" {
  description = "Start date for the schedule in UTC."
  type        = string
  default     = null
}

variable "end_date" {
  description = "End date for the schedule in UTC."
  type        = string
  default     = null
}

variable "kms_key_arn" {
  description = "KMS key ARN for encryption."
  type        = string
  default     = null
}

variable "flexible_time_window_mode" {
  description = "Mode for flexible time window (OFF or FLEXIBLE)."
  type        = string
  default     = "OFF"
}

variable "flexible_time_window_maximum_minutes" {
  description = "Maximum window in minutes for FLEXIBLE mode."
  type        = number
  default     = null
}

variable "name" {
  description = "Name of the schedule. Conflicts with name_prefix."
  type        = string
  default     = null
}

variable "name_prefix" {
  description = "Name prefix for the schedule. Conflicts with name."
  type        = string
  default     = null
}

variable "group_name" {
  description = "Schedule group name."
  type        = string
  default     = "default"
}
