resource "aws_s3_bucket" "cfy" {
  bucket = var.bucket_name
}

resource "aws_s3_object" "object" {
  bucket = var.bucket_name
  key    = var.s3_object_key
  source = var.s3_file_path
}
