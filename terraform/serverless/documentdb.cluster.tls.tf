resource "aws_s3_object" "documentdb_certificate" {
  bucket = aws_s3_bucket.nsse.bucket
  key    = var.document_db_cluster.s3_certificate_path
  source = "${path.module}/lambdas/report-job/documentdb-ca.pem"
  etag   = filemd5("${path.module}/lambdas/report-job/documentdb-ca.pem")
}
