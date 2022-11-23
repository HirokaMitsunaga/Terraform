resource "random_string" "s3_unique_key" {
  length  = 6
  upper   = false
  lower   = true
  number  = true
  special = false
}

# ---------------------------
# S3 static bucket
# ---------------------------

resource "aws_s3_bucket" "s3_static_bucket" {
  bucket = "${var.project}-${var.enviroment}-static-bucket-${random_string.s3_unique_key.result}"

  versioning {
    enabled = false
  }
}

resource "aws_s3_bucket_public_access_block" "s3_static_bucket" {
  bucket                  = aws_s3_bucket.s3_static_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  #aws_s3_bucket_policyを先に作る必要があるため、依存関係を設定する
  depends_on = [
    aws_s3_bucket_policy.s3_static_bucket
  ]
}

resource "aws_s3_bucket_policy" "s3_static_bucket" {
  bucket = aws_s3_bucket.s3_static_bucket.id
  policy = data.aws_iam_policy_document.s3_static_bucket.json
}

data "aws_iam_policy_document" "s3_static_bucket" {
  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.s3_static_bucket.arn}/*"]
    #静的コンテンツ用のため、全ての人に対して許可をする。
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.cf_s3_origin_access_identify.iam_arn]
    }

  }

}


# ---------------------------
# S3 deploy bucket
# ---------------------------

resource "aws_s3_bucket" "s3_deploy_bucket" {
  bucket = "${var.project}-${var.enviroment}-deploy-bucket-${random_string.s3_unique_key.result}"

  versioning {
    enabled = false
  }
}

resource "aws_s3_bucket_public_access_block" "s3_deploy_bucket" {
  bucket                  = aws_s3_bucket.s3_deploy_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  #aws_s3_bucket_policyを先に作る必要があるため、依存関係を設定する
  depends_on = [
    aws_s3_bucket_policy.s3_deploy_bucket
  ]
}

resource "aws_s3_bucket_policy" "s3_deploy_bucket" {
  bucket = aws_s3_bucket.s3_deploy_bucket.id
  policy = data.aws_iam_policy_document.s3_deploy_bucket.json
}

data "aws_iam_policy_document" "s3_deploy_bucket" {
  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.s3_deploy_bucket.arn}/*"]
    #静的コンテンツ用のため、全ての人に対して許可をする。
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.app_iam_role.arn]
    }

  }

}