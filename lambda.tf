# Archive with the code to upload
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda-src"
  output_path = "${path.module}/lambda.zip"
}

# IAM roles and policy
resource "aws_iam_role" "iam_for_lambda" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "lambda_policy" {
  role = "${aws_iam_role.iam_for_lambda.id}"
  name = "${var.name}-lambda-policy"

  policy = "${data.aws_iam_policy_document.lambda_policy.json}"
}

data "aws_iam_policy_document" "lambda_policy" {
  # Allow lambda to log
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:*:*:*",
    ]
  }

  # Allow lambda to run the task
  statement {
    effect = "Allow"

    actions = [
      "ecs:RunTask",
    ]

    resources = [
      "${module.s3_backup_taskdef.arn}",
    ]
  }

  # Allow lambda to assume the role of the task
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    resources = [
      "${module.s3_backup_taskdef.task_role_arn}",
    ]
  }

  depends_on = ["module.s3_backup_taskdef"]
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda_function.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.cron_schedule.arn}"
}

# Configure the lambda function
resource "aws_lambda_function" "lambda_function" {
  filename         = "${path.module}/lambda.zip"
  source_code_hash = "${data.archive_file.lambda_zip.output_base64sha256}"
  function_name    = "${var.name}-s3-backup"
  role             = "${aws_iam_role.iam_for_lambda.arn}"
  handler          = "ecs_worker.trigger"
  runtime          = "python3.6"

  environment {
    variables = "${
      merge(
        var.backup_env,
        map(
          "TASK_DEFINITION_ARN", module.s3_backup_taskdef.arn,
          "TASK_COMMAND", var.docker_command,
          "CONTAINER_NAME", "${var.name}-s3-backup",
          "CLUSTER", var.cluster,
        )
      )}"
  }
}

# Configure cron
resource "aws_cloudwatch_event_rule" "cron_schedule" {
  name                = "${aws_lambda_function.lambda_function.function_name}-cron_schedule"
  description         = "This event will run according to a schedule for lambda ${var.name}-s3-backup"
  schedule_expression = "${var.lambda_cron_schedule}"
}

resource "aws_cloudwatch_event_target" "event_target" {
  rule = "${aws_cloudwatch_event_rule.cron_schedule.name}"
  arn  = "${aws_lambda_function.lambda_function.arn}"
}
