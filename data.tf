data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  bucket_policy_default_permission = [
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
  ]
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

data "archive_file" "lambda_function_zip" {
  type        = "zip"
  source_file = "${path.module}/index.py"
  output_path = "${path.module}/index.zip"
}

data "aws_s3_bucket" "s3_bucket" {
  depends_on = [aws_s3_bucket.this]
  for_each   = var.name
  bucket     = each.value
}

# Uncomment the below data block if you use KMS CMK encryption

# data "aws_kms_key" "s3_kms_key" {
#   depends_on = [var.kms_key_id]
#   key_id     = var.kms_key_id
# }
