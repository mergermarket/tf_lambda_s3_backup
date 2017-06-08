variable "name" {
  description = "Name for this backup task"
}

variable "docker_image" {
  description = "Docker image to use for the task. It should contain all the logic to perform the dump and sync"
  default     = "mergermarket/docker-mysql-s3-backup"
}

variable "backup_env" {
  description = "Environment parameters passed to the lambda function and the container"
  type        = "map"
  default     = {}
}
