resource "aws_s3_object" "python_pyspark_script" {
  bucket = data.aws_s3_bucket.s3_bucket["s3_third_bucket_name"].id
  key    = "glue/scripts/pyspark_script.py"
  source = "pyspark_script.py"
  etag   = filemd5("pyspark_script.py")
}

resource "aws_glue_job" "json_to_csv" {
  depends_on        = [aws_s3_bucket.this, aws_s3_object.python_pyspark_script, aws_iam_policy.glue_policy, aws_iam_role.glue_role, aws_iam_role_policy_attachment.glue_role_policy_attachment]
  glue_version      = "5.0"                      # Optional
  max_retries       = 0                          # Optional
  name              = var.glue_job_name          # Required
  description       = "Glue ETL job"             # Description
  role_arn          = aws_iam_role.glue_role.arn # Required
  number_of_workers = 2                          # Optional, defaults to 5 if not set
  worker_type       = "G.1X"                     # Optional
  timeout           = 2880                       # Optional
  execution_class   = "STANDARD"                 # Optional
  tags = merge(
    var.tags,
    {
      Name = lower("${var.glue_job_name}-${var.project}-${var.env}-${data.aws_region.current.region}")
    }
  )
  command {
    name            = "glueetl"                                                                                        #optional
    script_location = "s3://${data.aws_s3_bucket.s3_bucket["s3_third_bucket_name"].id}/glue/scripts/pyspark_script.py" #required
    python_version  = "3"                                                                                              #optional
  }
  default_arguments = {
    "--job-language"                     = "python"
    "--continuous-log-logGroup"          = "/aws-glue/jobs"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-continuous-log-filter"     = "true"
    "--enable-metrics"                   = "true"
    "--enable-auto-scaling"              = "true"
    "--class"                            = "GlueApp"
    "--enable-job-insights"              = "true"
    "--enable-glue-datacatalog"          = "true"
    "--job-bookmark-option"              = "job-bookmark-disable"
    # "--datalake-formats"        = "iceberg"
    # "--conf"                    = "spark.sql.extensions=org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions  --conf spark.sql.catalog.glue_catalog=org.apache.iceberg.spark.SparkCatalog  --conf spark.sql.catalog.glue_catalog.warehouse=s3://tnt-erp-sql/ --conf spark.sql.catalog.glue_catalog.catalog-impl=org.apache.iceberg.aws.glue.GlueCatalog  --conf spark.sql.catalog.glue_catalog.io-impl=org.apache.iceberg.aws.s3.S3FileIO"
  }
  execution_property {
    max_concurrent_runs = 1
  }
}
