module "s3_backup_container_definition" {
  source = "github.com/mergermarket/tf_ecs_container_definitions"

  name           = "${var.name}-s3-backup"
  image          = "${var.docker_image}"
  cpu            = 256
  memory         = 256

  container_env = "${var.backup_env}"

  metadata = "${var.metadata}"

  mountpoint = {
    sourceVolume  = "s3_backup_volume"
    containerPath = "${var.bind_container_path}"
    readOnly      = "false"
  }
}

module "s3_backup_taskdef" {
  source = "github.com/mergermarket/tf_ecs_task_definition"

  family                = "${var.name}-s3-backup"
  container_definitions = ["${module.s3_backup_container_definition.rendered}"]

  volume = {
    name       = "s3_backup_volume"
    host_path  = "${var.bind_host_path}"
  }
}
