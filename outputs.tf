output "lambda_function_name" {
  value = aws_lambda_function.json_to_csv_lambda.function_name
}
output "s3_bucket_names" {
  description = "Map of S3 bucket ids keyed by bucket resource key"
  value       = { for k, b in aws_s3_bucket.this : k => b.id }
}
output "glue_job_name" {
  value = aws_glue_job.json_to_csv.name
}
output "first_bucket_arn" {
  value = data.aws_s3_bucket.s3_bucket["s3_first_bucket_name"].arn
}
output "second_bucket_arn" {
  value = data.aws_s3_bucket.s3_bucket["s3_second_bucket_name"].arn
}
output "third_bucket_arn" {
  value = data.aws_s3_bucket.s3_bucket["s3_third_bucket_name"].arn
}
output "glue_role_arn" {
  value = aws_iam_role.glue_role.arn
}
output "lambda_iam_role_arn" {
  value = aws_iam_role.lambda_role.arn
}
output "lambda_iam_policy_arn" {
  value = aws_iam_policy.lambda_policy.arn
}
output "glue_job_arn" {
  value = aws_glue_job.json_to_csv.arn
}
output "lambda_function_arn" {
  value = aws_lambda_function.json_to_csv_lambda.arn
}
output "cloudwatch_log_group_arn" {
  value = aws_cloudwatch_log_group.lambda_json_to_csv_log_group.arn
}
output "glue_policy_arn" {
  value = aws_iam_policy.glue_policy.arn
}
