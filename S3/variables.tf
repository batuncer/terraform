variable "bucket_name" {
  description = "S3 bucket name"
  type        = string
}

variable "s3_file_path" {
  description = "Local file path to upload to S3"
  type        = string
}

variable "s3_object_key" {
  description = "S3 object key (file name in the bucket)"
  type        = string
}
