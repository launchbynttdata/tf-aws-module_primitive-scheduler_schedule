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

output "id" {
  description = "The ID of the schedule."
  value       = module.scheduler_schedule.id
}

output "arn" {
  description = "The ARN of the schedule."
  value       = module.scheduler_schedule.arn
}

output "name" {
  description = "The name of the schedule."
  value       = module.scheduler_schedule.name
}

output "group_name" {
  description = "The schedule group name."
  value       = var.group_name
}

output "queue_url" {
  description = "The URL of the SQS queue used as the schedule target."
  value       = aws_sqs_queue.schedule_target.url
}

output "region" {
  description = "The AWS region where resources were created."
  value       = data.aws_region.current.name
}
