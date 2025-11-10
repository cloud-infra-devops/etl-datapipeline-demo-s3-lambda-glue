resource "aws_s3_bucket" "this" {
  for_each = var.name
  bucket   = each.value
  lifecycle {
    prevent_destroy = "false"
  }

  tags = merge(
    var.tags,
    {
      Name = lower("${each.value}-${var.project}-${var.env}-${data.aws_region.current.region}")
    }
  )
}

resource "aws_s3_bucket_versioning" "this" {
  depends_on = [aws_s3_bucket.this]
  for_each   = var.name
  bucket     = aws_s3_bucket.this[each.key].id
  versioning_configuration {
    status = var.versioning
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  depends_on = [aws_s3_bucket_versioning.this]
  for_each   = var.name
  bucket     = aws_s3_bucket.this[each.key].id
  rule {
    id     = "default"
    status = "Enabled"
    noncurrent_version_expiration {
      noncurrent_days = var.default_retention_noncurrent_days
    }
  }

  rule {
    id     = "archive_retention"
    status = "Enabled"
    noncurrent_version_expiration {
      noncurrent_days = var.archive_retention_noncurrent_days
    }
    filter {
      prefix = "archives"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  depends_on              = [aws_s3_bucket_lifecycle_configuration.this]
  for_each                = var.name
  bucket                  = aws_s3_bucket.this[each.key].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  depends_on = [aws_s3_bucket_public_access_block.this]
  for_each   = var.name
  bucket     = aws_s3_bucket.this[each.key].id
  rule {
    apply_server_side_encryption_by_default {
      # kms_master_key_id = var.kms_key_id
      # sse_algorithm     = "aws:kms"
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "this" {
  depends_on = [aws_s3_bucket_server_side_encryption_configuration.this]
  for_each   = var.name
  bucket     = aws_s3_bucket.this[each.key].id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_policy" "this" {
  depends_on = [aws_s3_bucket_ownership_controls.this]
  for_each   = var.name
  bucket     = aws_s3_bucket.this[each.key].id
  policy     = data.aws_iam_policy_document.this[each.key].json
}

resource "aws_s3_bucket_acl" "s3_acl" {
  depends_on = [aws_s3_bucket_policy.this]
  for_each   = var.name
  bucket     = aws_s3_bucket.this[each.key].id
  acl        = "private"
}

######################################################################
# Adding S3 bucket as trigger to lambda function and giving the permissions
######################################################################

# Bucket notification to send Put events (only for .json objects)
resource "aws_s3_bucket_notification" "lambda_trigger" {
  # for_each = var.name
  # Ensure permission created before notification (to avoid race)
  depends_on = [aws_lambda_permission.s3_lambda_invoke_permission]
  bucket     = data.aws_s3_bucket.s3_bucket["s3_first_bucket_name"].id

  lambda_function {
    lambda_function_arn = aws_lambda_function.json_to_csv_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    # filter_prefix       = "input/"
    filter_suffix = ".json"
  }
}

# Provide permission to invoke lambda function when file is uploaded to source S3 bucket
resource "aws_lambda_permission" "s3_lambda_invoke_permission" {
  statement_id  = "AllowS3InvokeLambdaFunction"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.json_to_csv_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = data.aws_s3_bucket.s3_bucket["s3_first_bucket_name"].arn
}

