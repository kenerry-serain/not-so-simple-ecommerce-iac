resource "aws_s3_bucket_lifecycle_configuration" "nsse_intelligent_tiering" {
  bucket = aws_s3_bucket.nsse.id

  rule {
    id     = "MovingtoIntelligentTiering"
    status = "Enabled"

    transition {
      days          = 0
      storage_class = "INTELLIGENT_TIERING"
    }

    noncurrent_version_transition {
      noncurrent_days = 0
      storage_class   = "INTELLIGENT_TIERING"
    }
  }
}
