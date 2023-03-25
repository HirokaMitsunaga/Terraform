# ---------------------------
# key pair
# ---------------------------

resource "aws_key_pair" "keypair" {
  key_name   = "${var.project}-${var.enviroment}-keypair"
  public_key = file("./src/tastylog-dev-keypair.pub")

  tags = {
    Name    = "${var.project}-${var.enviroment}-keypair"
    Project = var.project
    Env     = var.enviroment
  }

}

# ---------------------------
# SSM Parameter Store
# ---------------------------
resource "aws_ssm_parameter" "host" {
  name = "/${var.project}/${var.enviroment}/app/MYSQL_HOST"
  type = "String"
  #valueは作成済みのRDSインスタンスの情報から取ってくる。
  value = aws_db_instance.mysql_standalone.address
}

resource "aws_ssm_parameter" "port" {
  name = "/${var.project}/${var.enviroment}/app/MYSQL_PORT  "
  type = "String"
  #valueは作成済みのインスタンスの情報から取ってくる。
  value = aws_db_instance.mysql_standalone.port
}

resource "aws_ssm_parameter" "database" {
  name = "/${var.project}/${var.enviroment}/app/MYSQL_DATABASE"
  type = "String"
  #valueは作成済みのインスタンスの情報から取ってくる。
  value = aws_db_instance.mysql_standalone.name
}

resource "aws_ssm_parameter" "username" {
  name = "/${var.project}/${var.enviroment}/app/MYSQL_USERNAME"
  type = "SecureString"
  #valueは作成済みのインスタンスの情報から取ってくる。
  value = aws_db_instance.mysql_standalone.username
}

resource "aws_ssm_parameter" "password" {
  name = "/${var.project}/${var.enviroment}/app/MYSQL_PASSWORD"
  type = "SecureString"
  #valueは作成済みのインスタンスの情報から取ってくる。
  value = random_string.db_password.result
}




# ---------------------------
# EC2 Instance
# ---------------------------

#resource "aws_instance" "app_server" {
#  ami           = data.aws_ami.app.id
#  instance_type = "t2.micro"
#  subnet_id     = aws_subnet.public_subnet_1a.id
#  #associate_public_ip_addressはパブリックIPを使うかどうかのbool値
#  associate_public_ip_address = true
#  #iam.tfで作成したインスタンスプロフィールを指定する。
#  iam_instance_profile = aws_iam_instance_profile.app_ec2_profile.name
#  vpc_security_group_ids = [
#    aws_security_group.app_sg.id,
#    aws_security_group.opmng_sg.id
#  ]
#  #key_name = aws_key_pair.keypair.nameでない事に注意（公式ドキュメント要参照）
#  key_name = aws_key_pair.keypair.key_name
#
#  tags = {
#    Name    = "${var.project}-${var.enviroment}-app-ec2"
#    Project = var.project
#    Env     = var.enviroment
#    type    = "app"
#    #あとで環境変数を参照する際にtypeを使う
#  }
#} 
#data.tfのamiの部分をコメントアウトしたことにより、上記は使えなくなったため、コメントアウトする。

# ---------------------------
# launch template
# ---------------------------

resource "aws_launch_template" "app_lt" {
  update_default_version = true

  name     = "${var.project}-${var.enviroment}-app-lt"
  image_id = data.aws_ami.app.id

  key_name = aws_key_pair.keypair.key_name

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name    = "${var.project}-${var.enviroment}-app-ec2"
      Project = var.project
      Env     = var.enviroment
      type    = "app"
    }
  }
  network_interfaces {
    associate_public_ip_address = true
    security_groups = [
      aws_security_group.app_sg.id,
      aws_security_group.opmng_sg.id
    ]
    #インスタンスが消えた時に一緒にネットワーク情報も消えるようにする。
    delete_on_termination = true
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.app_ec2_profile.name
  }

  #S3に保存されたソースコードを元にアプリケーションを動かす。初期設定のためのスクリプトを立ち上げる
  user_data = filebase64("./src/initialize.sh")
}

# ---------------------------
# auto scailing group
# ---------------------------

resource "aws_autoscaling_group" "app_asg" {
  name = "${var.project}-${var.enviroment}-app-asg"

  max_size         = 1
  min_size         = 1
  desired_capacity = 1

  #ヘルスチェックの間隔
  health_check_grace_period = 300
  health_check_type         = "ELB"

  vpc_zone_identifier = [
    aws_subnet.public_subnet_1a.id,
    aws_subnet.public_subnet_1c.id
  ]

  target_group_arns = [aws_alb_target_group.alb_target_group.arn]

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.app_lt.id
        version         = "$Latest"
      }
      override {
        instance_type = "t2.micro"
      }
    }

  }

}