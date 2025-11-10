locals {
  bucket_policy_default_permission = [
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
  ]
  #   bucket_policy_permissions = concat(local.bucket_policy_default_permission, var.bucket_policy_allowed_arns)
}

## s3 bucket policy
data "aws_iam_policy_document" "this" {
  for_each = var.name
  version  = "2012-10-17"
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = local.bucket_policy_default_permission
    }
    actions = [
      "s3:*"
    ]
    resources = [
      "${aws_s3_bucket.this[each.key].arn}/*",
      "${aws_s3_bucket.this[each.key].arn}"
    ]
  }
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

# Inline policy: CloudWatch Logs + S3 permissions
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
        Resource = ["arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:/lambda/${var.lambda_function_name}:*"]
      },
      {
        Sid    = "GlueFullAccess"
        Effect = "Allow"
        Action = [
          "glue:*"
        ]
        Resource = [aws_glue_job.json_to_csv.arn] # Glue job ARN
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
          "s3:PutObject",
          "s3:PutObjectLegalHold",
          "s3:PutObjectRetention",
          "s3:PutObjectTagging",
          "s3:PutObjectVersionTagging"
        ]
        Resource = ["arn:aws:s3:::${data.aws_s3_bucket.s3_bucket["s3_first_bucket_name"].id}",
          "arn:aws:s3:::${data.aws_s3_bucket.s3_bucket["s3_first_bucket_name"].id}/*"
        ]
      }
    ]
  })
}

# Policy Attachment on the role.
resource "aws_iam_role_policy_attachment" "attach_lambda_policy_to_lambda_role" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

##############################
# Creating IAM Role for Glue
##############################
data "aws_iam_policy_document" "glue_trust_policy_document" {
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "glue_policy_document" {
  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = ["${data.aws_s3_bucket.s3_bucket["s3_first_bucket_name"].arn}"]
  }

  statement {
    effect  = "Allow"
    actions = ["s3:GetObject"]
    resources = [
      # "${data.aws_s3_bucket.s3_bucket["s3_first_bucket_name"].arn}/sample.json",
      "${data.aws_s3_bucket.s3_bucket["s3_first_bucket_name"].arn}/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      # "s3:GetObject",
      # "s3:PutObject",
      # "s3:ListObject",
      # "s3:DeleteObject",
      "s3:*",
      # "glue:*",
      # "iam:*",
    ]
    resources = [
      "${data.aws_s3_bucket.s3_bucket["s3_second_bucket_name"].arn}",
      "${data.aws_s3_bucket.s3_bucket["s3_second_bucket_name"].arn}/*",
      "${data.aws_s3_bucket.s3_bucket["s3_third_bucket_name"].arn}",
      "${data.aws_s3_bucket.s3_bucket["s3_third_bucket_name"].arn}/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws-glue/jobs/*"]
  }
}

resource "aws_iam_policy" "glue_policy" {
  name        = "Glue_Policy"
  description = "allows for running glue job in the glue console and access destination s3 bucket"
  policy      = data.aws_iam_policy_document.glue_policy_document.json
}

resource "aws_iam_role" "glue_role" {
  name               = "aws_glue_job_role"
  assume_role_policy = data.aws_iam_policy_document.glue_trust_policy_document.json
}

resource "aws_iam_role_policy_attachment" "glue_role_policy_attachment" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_policy.arn
}
