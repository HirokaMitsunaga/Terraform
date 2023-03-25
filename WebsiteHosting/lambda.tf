resource "aws_lambda_layer_version" "lambda_layer" {
  filename   = "boto3-1.26.32.zip"
  layer_name = "test_boto3-1-26-32"

  compatible_runtimes = ["python3.9"]
}


resource "aws_lambda_function" "main_lambda" {
  filename      = "change-cloudfront-default-root-object.zip"
  function_name = "change-cloudfront-default-root-object"
  role          = aws_iam_role.lambda_iam_role.arn
  handler       = "change-cloudfront-default-root-object.lambda_handler"
  timeout       = 900
  runtime       = "python3.9"
  layers        = [aws_lambda_layer_version.lambda_layer.arn]

  environment {
    variables = {
      DistributionId = aws_cloudfront_distribution.cf.id
    }
  }

}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main_lambda.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.s3_static_bucket.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.s3_static_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.main_lambda.arn
    events              = ["s3:ObjectCreated:Put"]
    filter_prefix       = ""
    filter_suffix       = ".html"
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}