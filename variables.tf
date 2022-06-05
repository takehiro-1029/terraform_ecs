## 最低限必要なAWS Config (AWS CLIで”aws config”を実行して、Region、Access Keyなどを設定するのと同じ) ##
variable "aws_region" {}
variable "aws_profile" {}

variable "ecs_cluster_name" {}
variable "ecs_service_name" {}
variable "task_definition" {}


