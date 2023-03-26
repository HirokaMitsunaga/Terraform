data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}


data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    actions = [
      "cloudfront:GetDistribution",
      "cloudfront:GetInvalidation",
      "cloudfront:CreateInvalidation",
      "cloudfront:UpdateDistribution"
    ]
    effect = "Allow"
    resources = [
      aws_cloudfront_distribution.cf.arn
    ]
  }
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    effect    = "Allow"
    resources = ["arn:aws:logs:ap-northeast-1:${local.account_id}*"]
  }
}

#ポリシーの作成
resource "aws_iam_policy" "lambda_policy" {
  name   = "LambdaPolicy"
  policy = data.aws_iam_policy_document.lambda_policy.json
}

#ロールへポリシーをアタッチ
resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_iam_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

#ロールの作成
resource "aws_iam_role" "lambda_iam_role" {
  name               = "LambdaRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}