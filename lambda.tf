# CloudWatch Log group to store Lambda logs
resource "aws_cloudwatch_log_group" "lambda_json_to_csv_log_group" {
  name              = "/aws/lambda/json_to_csv_lambda"
  retention_in_days = 1
}

##############################
# Creating IAM Role for Lambda
##############################
resource "aws_iam_role" "lambda_role" {
  name = "${var.lambda_function_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Inline policy: CloudWatch Logs + S3 + Glue permissions
resource "aws_iam_policy" "lambda_policy" {
  name = "${var.lambda_function_name}-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "CloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = aws_cloudwatch_log_group.lambda_json_to_csv_log_group.arn
      },
      {
        Sid    = "S3Access"
        Effect = "Allow"
        Action = [
          "s3:GetBucket*",
          "s3:GetObject*",
          "s3:List*",
          "s3:Abort*",
          "s3:DeleteObject*",
          "s3:GetBucket*",
          "s3:GetObject*",
          "s3:List*",
          "s3:PutObject",
          "s3:PutObjectLegalHold",
          "s3:PutObjectRetention",
          "s3:PutObjectTagging",
          "s3:PutObjectVersionTagging"
        ]
        Resource = ["arn:aws:s3:::${data.aws_s3_bucket.s3_bucket["s3_first_bucket_name"].id}",
          "arn:aws:s3:::${data.aws_s3_bucket.s3_bucket["s3_first_bucket_name"].id}/*"
        ]
      },
      {
        Sid    = "GlueFullAccess"
        Effect = "Allow"
        Action = [
          "glue:*"
        ]
        Resource = aws_glue_job.json_to_csv.arn # tighten if you know the Glue job ARN
      }
    ]
  })
}

# Policy Attachment on the role.
resource "aws_iam_role_policy_attachment" "attach_lambda_policy_to_lambda_role" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
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
  depends_on       = [aws_iam_role_policy_attachment.attach_lambda_policy_to_lambda_role]
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


