resource "aws_s3_bucket" "s3-remote-bucket" {
    bucket = "tf-project-remote-state-backend-s3-bucket"
}

resource "aws_s3_bucket_acl" "private" {
  bucket = aws_s3_bucket.s3-remote-bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.s3-remote-bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "terraform-lock" {
    name           = "terraform-s3-backend"
    read_capacity  = 5
    write_capacity = 5
    hash_key       = "LockID"
    attribute {
        name = "LockID"
        type = "S"
    }
    tags = {
        "Name" = "DynamoDB Terraform State Lock Table"
    }
}