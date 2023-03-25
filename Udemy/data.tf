data "aws_prefix_list" "s3_pl" {
  name = "com.amazonaws.*.s3"
}

data "aws_ami" "app" {
  most_recent = true
  #自分自身が作成した、AmazonのAMIどちらも使えるようにする。
  owners = ["self", "amazon"]


  filter {
    name   = "name"
    values = ["tastylog-*-ami"]
  }

  # filter {
  #   name   = "name"
  #   values = ["amzn2-ami-kernel-5.10-hvm-2.0.*-x86_64-gp2"]
  # }
  # filter {
  #   name   = "root-device-type"
  #   values = ["ebs"]
  # }
  # filter {
  #   name   = "virtualization-type"
  #   values = ["hvm"]
  # }

}