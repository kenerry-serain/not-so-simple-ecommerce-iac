data "archive_file" "lambda_report_job" {
  type        = var.lambda_report_job.package_type
  source_dir  = "${path.module}/${var.lambda_report_job.source_dir}"
  output_path = "${path.module}/${var.lambda_report_job.output_path}"
}

resource "aws_lambda_function" "report_job" {
  timeout          = var.lambda_report_job.timeout
  filename         = "${path.module}/${var.lambda_report_job.filename}"
  function_name    = var.lambda_report_job.function_name
  role             = aws_iam_role.report_job_lambda_role.arn
  handler          = var.lambda_report_job.handler
  source_code_hash = data.archive_file.lambda.output_base64sha256
  runtime          = var.lambda_report_job.runtime
  layers           = [aws_lambda_layer_version.node_modules.arn]

  vpc_config {
    subnet_ids         = data.aws_subnets.private_subnets.ids
    security_group_ids = [aws_security_group.postgresql.id, aws_security_group.documentdb.id]
  }

  environment {
    variables = {
      RDS_PROXY_ENDPOINT         = aws_db_proxy.this.endpoint,
      RDS_SECRET_ARN             = aws_rds_cluster.this.master_user_secret[0].secret_arn
      DOCUMENTDB_SECRET_ARN      = aws_secretsmanager_secret.documentdb.arn
      DOCUMENTDB_ENDPOINT        = aws_docdb_cluster.this.endpoint
      DOCUMENTDB_DATABASE_NAME   = var.document_db_cluster.database_name
      RDS_DATABASE_NAME          = aws_rds_cluster.this.database_name
      BUCKET_NAME                = aws_s3_bucket.nsse.bucket
      DOCUMENTDB_CERT_OBJECT_KEY = aws_s3_object.documentdb_certificate.key
    }
  }
}
