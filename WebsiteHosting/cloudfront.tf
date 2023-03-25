# ---------------------------
# CloudFront cache distribution
# ---------------------------

resource "aws_cloudfront_distribution" "cf" {
  enabled         = true
  is_ipv6_enabled = true
  comment         = "cache distribution"
  price_class     = "PriceClass_All"

  #S3のオリジン設定
  origin {
    domain_name              = aws_s3_bucket.s3_static_bucket.bucket_regional_domain_name
    origin_id                = aws_s3_bucket.s3_static_bucket.id
    origin_access_control_id = aws_cloudfront_origin_access_control.main.id
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  #S3のビヘイビアの設定
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = aws_s3_bucket.s3_static_bucket.id
    viewer_protocol_policy = "redirect-to-https"
    forwarded_values {
      query_string = false
      headers      = []
      cookies {
        forward = "none"
      }
    }
  }


  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

}

#OACの作成
resource "aws_cloudfront_origin_access_control" "main" {
  name                              = "cf-oac-with-tf-example"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
