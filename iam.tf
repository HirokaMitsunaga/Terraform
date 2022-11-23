
# ---------------------------
# IAM Role
# ---------------------------

resource "aws_iam_instance_profile" "app_ec2_profile" {
  #instance_prpfileのnameはIAMロールと同じものを定義する。
  name = aws_iam_role.app_iam_role.name
  role = aws_iam_role.app_iam_role.name
}

resource "aws_iam_role" "app_iam_role" {
  name = "${var.project}-${var.enviroment}-app-iam-role"
  #信頼ポリシーがjson形式のため最後に「.json」をつける。
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}



data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "app_iam_role_ec2_readonly" {

  role       = aws_iam_role.app_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "app_iam_role_ssm_managed" {

  role       = aws_iam_role.app_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "app_iam_role_ssm_readonly" {

  role       = aws_iam_role.app_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "app_iam_role_s3_readonly" {

  role       = aws_iam_role.app_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}