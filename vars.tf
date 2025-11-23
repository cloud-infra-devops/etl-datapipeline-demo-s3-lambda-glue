variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-west-2"
}

variable "aws_account_id" {
  description = "The AWS account ID to deploy resources"
  type        = string
  default     = "211125325120" #Put AWS Account ID
}

# variable "access_key" {
#   type      = string
#   sensitive = true
# }

# variable "secret_key" {
#   type      = string
#   sensitive = true
# }

# variable "token" {
#   type      = string
#   sensitive = true
# }

variable "name" {
  description = "value representing the name of the S3 bucket"
  type        = map(string)
  default = {
    "s3_first_bucket_name"  = "bkt01-source-json-data"
    "s3_second_bucket_name" = "bkt02-destination-csv-data"
    "s3_third_bucket_name"  = "bkt03-pyspark-src-code"
  }
}
variable "project" {
  description = "Project name"
  type        = string
  default     = "json-to-csv-etl-datapipeline"
}

variable "env" {
  description = "value representing the environment (e.g., dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["poc", "sbx", "dev", "qa", "prod"], var.env)
    error_message = "Environment must be one of: poc, sbx, dev, qa, prod"
  }
  default = "sbx"
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

# Uncomment the below variable if you use KMS CMK encryption
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

variable "cw_logs_retention_period_days" {
  description = "Cloudwatch Logs Retention Period in Days"
  type        = number
  default     = 1
}
