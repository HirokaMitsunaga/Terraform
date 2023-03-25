# ---------------------------
# ALB
# ---------------------------

resource "aws_lb" "alb" {
  name               = "${var.project}-${var.enviroment}-app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups = [
    aws_security_group.web_sg.id
  ]
  subnets = [
    aws_subnet.public_subnet_1a.id,
    aws_subnet.public_subnet_1c.id
  ]
}

resource "aws_alb_listener" "alb_listener_http" {
  load_balancer_arn = aws_lb.alb.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.alb_target_group.arn
  }
}

resource "aws_alb_listener" "alb_listener_https" {
  load_balancer_arn = aws_lb.alb.id
  port              = 443
  protocol          = "HTTPS"
  #httpとは違い証明書系の文言を記載する
  ssl_policy      = "ELBSecurityPolicy-2016-08"
  certificate_arn = aws_acm_certificate.tokyo_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.alb_target_group.arn
  }
}


# ---------------------------
# targert grop
# ---------------------------

resource "aws_alb_target_group" "alb_target_group" {
  name     = "${var.project}-${var.enviroment}-app-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  tags = {
    Name    = "${var.project}-${var.enviroment}-app-tg"
    Project = var.project
    Env     = var.enviroment
  }
}

#resource "aws_alb_target_group_attachment" "instance" {
#target_group_arn = aws_alb_target_group.alb_target_group.arn
#target_id        = aws_instance.app_server.id
#}