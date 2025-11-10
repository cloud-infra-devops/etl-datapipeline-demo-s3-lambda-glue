variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-west-2"
}

variable "aws_account_id" {
  description = "The AWS account ID to deploy resources"
  type        = string
  default     = "211125325120"
}

variable "name" {
  description = "value representing the name of the S3 bucket"
  type        = map(string)
  default = {
    "s3_first_bucket_name"  = "source-json-s3-duke-ima-poc"
    "s3_second_bucket_name" = "destination-csv-s3-duke-ima-poc"
    "s3_third_bucket_name"  = "pyspark-src-s3-duke-ima-poc"
  }
}
variable "project" {
  description = "Project name"
  type        = string
  default     = "duke-energy-ima"
}

variable "env" {
  description = "value representing the environment (e.g., dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["poc", "sbx", "dev", "qa", "prod"], var.env)
    error_message = "Environment must be one of: poc, sbx, dev, qa, prod"
  }
  default = "poc"
}

variable "versioning" {
  type    = string
  default = "Disabled"
  validation {
    condition     = contains(["Enabled", "Disabled"], var.versioning)
    error_message = "S3 Bucket Versioning must be one of: Enabled or Disabled"
  }
}

variable "tags" {
  type    = map(string)
  default = {}
}

# variable "kms_key_id" {
#   type = string
# }

variable "default_retention_noncurrent_days" {
  type    = string
  default = 180
}

variable "archive_retention_noncurrent_days" {
  type    = string
  default = 90
}

variable "lambda_function_name" {
  type        = string
  description = "Name for the Lambda function"
  default     = "json-to-csv-lambda"
}

variable "lambda_runtime" {
  type        = string
  description = "Runtime for the Lambda function"
  default     = "python3.13"

}

variable "glue_job_name" {
  type        = string
  description = "Name of the Glue job to start"
  default     = "json_to_csv"
}
