terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

# ---------- S3 bucket: private, encrypted, versioned ----------
resource "aws_s3_bucket" "data" {
  # checkov:skip=CKV_AWS_144:Cross-region replication not needed for demo
  # checkov:skip=CKV_AWS_145:SSE-S3 (AES256) is sufficient for demo; KMS adds cost
  # checkov:skip=CKV_AWS_18:Access logging needs a second log bucket; out of scope for demo
  # checkov:skip=CKV2_AWS_62:Event notifications not required for demo
  # checkov:skip=CKV2_AWS_61:Lifecycle rules not required for demo
  bucket = "sayan-devsecops-demo-20261107" # must be globally unique

  tags = {
    owner       = "sayan"
    environment = "demo"
  }
}

resource "aws_s3_bucket_public_access_block" "data" {
  bucket                  = aws_s3_bucket.data.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "data" {
  bucket = aws_s3_bucket.data.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "data" {
  bucket = aws_s3_bucket.data.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ---------- Security group: SSH only from one trusted IP ----------
resource "aws_security_group" "web" {
  # checkov:skip=CKV2_AWS_5:Demo group is not attached to an instance
  # checkov:skip=CKV_AWS_382:No egress rules defined in demo
  name        = "web-sg"
  description = "Allow SSH from admin IP only"

  ingress {
    description = "SSH from admin"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["203.0.113.10/32"] # placeholder IP
  }

  tags = {
    owner = "sayan"
  }
}
