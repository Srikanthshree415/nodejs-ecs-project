resource "aws_s3_bucket" "raw" {
  bucket = var.raw_bucket_name
}

resource "aws_s3_bucket" "curated" {
  bucket = var.curated_bucket_name
}

resource "aws_s3_bucket_versioning" "raw" {
  bucket = aws_s3_bucket.raw.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "curated" {
  bucket = aws_s3_bucket.curated.id
  versioning_configuration {
    status = "Enabled"
  }
}
