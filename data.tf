data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

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
