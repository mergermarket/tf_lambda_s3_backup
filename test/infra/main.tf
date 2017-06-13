provider "aws" {
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_get_ec2_platforms      = true
  skip_region_validation      = true
  skip_requesting_account_id  = true
  max_retries                 = 1
  access_key                  = "a"
  secret_key                  = "a"
  region                      = "eu-west-1"
}

module "lambda_s3_backup" {
  source = "../.."

  name                = "test"
  bucket_name         = "test_bucket"
  bind_host_path      = "/mnt/vol-1234"
  bind_container_path = "/data"
  cluster             = "test-cluster"

  backup_env = {
    "VAR1" = "foo"
    "VAR1" = "bar"
  }
}
