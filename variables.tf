variable "name" {
  description = "Name for this backup task"
}

variable "bind_host_path" {
  description = "Host volume to mount into the container. Must be set together with bind_host_path"
  default     = "/tmp/dummy"
}

variable "bind_container_path" {
  description = "Container volume to mount into the container. Must be set together with bind_container_path"
  default     = "/tmp/dummy"
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

variable "metadata" {
  description = "Metadata for the resources created by this module"
  type        = "map"
  default     = {}
}
