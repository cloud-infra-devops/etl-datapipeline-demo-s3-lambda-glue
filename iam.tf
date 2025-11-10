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
