# CloudWatch Log group to store Lambda logs
resource "aws_cloudwatch_log_group" "lambda_json_to_csv_log_group" {
  name              = "/lambda/${var.lambda_function_name}"
  retention_in_days = 1
}

/*
##############################
# Creating IAM Role for Lambda
##############################

# IAM Policy Document for Lambda - Allows Trust Policy for Lambda
resource "aws_iam_policy_document" "AWSLambdaTrustPolicy" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    principal {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    action = "sts:AssumeRole"
  }
}

resource "aws_iam_role" "lambda_function_role" {
  name               = "lambda_function_role"
  assume_role_policy = aws_iam_policy_document.AWSLambdaTrustPolicy.json
}

# IAM Policy Document for Lambda - Allows Writing to Cloudwatch Logs, Read/Write to S3 and Glue Console Full Access
resource "aws_iam_policy_attachment" "lambda_policy_attachment" {
  name       = "${var.lambda_function_name}-policy-attachment"
  roles      = [aws_iam_role.lambda_function_role.name]
  policy_arn = ["arn:aws:iam::aws:policy/AWSGlueConsoleFullAccess", "arn:aws:iam::aws:policy/AmazonS3FullAccess", "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"]
}
*/

# Lambda function
resource "aws_lambda_function" "json_to_csv_lambda" {
  depends_on       = [aws_iam_role.lambda_role, aws_iam_policy.lambda_policy, aws_iam_role_policy_attachment.attach_lambda_policy_to_lambda_role, aws_glue_job.json_to_csv, aws_cloudwatch_log_group.lambda_json_to_csv_log_group, aws_s3_bucket.this]
  filename         = data.archive_file.lambda_function_zip.output_path
  function_name    = var.lambda_function_name
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.lambda_handler"
  runtime          = var.lambda_runtime
  source_code_hash = filebase64sha256(data.archive_file.lambda_function_zip.output_path)

  environment {
    variables = {
      GLUE_JOB_NAME = var.glue_job_name
    }
  }

  # Optional: adjust timeouts/memory
  timeout     = 900
  memory_size = 512
  ephemeral_storage {
    size = 2048 # Min 512 MB and the Max 10240 MB
  }
  tags = merge(
    var.tags,
    {
      Name = lower("${var.lambda_function_name}-${var.project}-${var.env}-${data.aws_region.current.region}")
    }
  )
}


