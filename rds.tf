#----------------------
#RDS parametar group
#----------------------

resource "aws_db_parameter_group" "mysql_standalone_parametergroup" {
  name   = "${var.project}-${var.enviroment}-mysql-standalone-parametergroup"
  family = "mysql8.0"

  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }
}

#----------------------
#RDS option group
#----------------------

resource "aws_db_option_group" "mysql_standalone_optiongroup" {
  name                 = "${var.project}-${var.enviroment}-mysql-standalone-optiongroup"
  engine_name          = "mysql"
  major_engine_version = "8.0"
}

#----------------------
#RDS subnet group
#----------------------
resource "aws_db_subnet_group" "mysql_standalone_subnetgroup" {
  name = "${var.project}-${var.enviroment}-mysql-standalone-subnetgroup"
  subnet_ids = [
    aws_subnet.private_subnet_1a.id,
    aws_subnet.private_subnet_1c.id
  ]

  tags = {
    Name    = "${var.project}-${var.enviroment}-mysql-standalone-subnetgroup"
    Project = var.project
    Env     = var.enviroment
  }
}


#----------------------
#RDS Instance
#----------------------
resource "random_string" "db_password" {
  length  = 16
  special = false

}

resource "aws_db_instance" "mysql_standalone" {
  engine         = "mysql"
  engine_version = "8.0.20"
  #インスタンスの名前
  identifier = "${var.project}-${var.enviroment}-mysql-standalone"

  username = "admin"
  password = random_string.db_password.result

  instance_class        = "db.t2.micro"
  allocated_storage     = 20
  max_allocated_storage = 50
  #gp2はSSD
  storage_type      = "gp2"
  storage_encrypted = false

  multi_az          = false
  availability_zone = "ap-northeast-1a"
  #mysql_standalone_subnetgroupは３３行目で作成したものを指定している。
  db_subnet_group_name = aws_db_subnet_group.mysql_standalone_subnetgroup.name
  #db_sgはsecurity_group.tfの33行目で作成したものを指定している・
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  port                   = 3306

  name                 = "testylog"
  parameter_group_name = aws_db_parameter_group.mysql_standalone_parametergroup.name
  option_group_name    = aws_db_option_group.mysql_standalone_optiongroup.name

  backup_window = "04:00-05:00"
  #backup_retention_periodは、バックアップを何日分保管するのかの設定
  backup_retention_period = 7
  #メンテナンスの前にバックアップを取るように時間帯をずらしている。
  maintenance_window         = "Mon:05:00-Mon:08:00"
  auto_minor_version_upgrade = false

  deletion_protection = false
  skip_final_snapshot = true

  apply_immediately = true

  tags = {
    Name    = "${var.project}-${var.enviroment}-mysql-standalone"
    Project = var.project
    Env     = var.enviroment
  }

}