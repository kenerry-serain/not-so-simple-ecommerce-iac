resource "aws_s3_object" "documentdb_certificate" {
  bucket = aws_s3_bucket.nsse.bucket
  key    = "app/documentdb-ca.pem"
  source = "${path.module}/lambdas/report-job/documentdb-ca.pem"
  etag = filemd5("${path.module}/lambdas/report-job/documentdb-ca.pem")
}