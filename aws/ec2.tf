data "aws_ami" "linux" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  depends_on = [aws_vpc.vpc]

  tags = {
    Name = "${var.app_name}-allow-ssh"
  }
}

resource "aws_launch_template" "launch_template" {
  name                    = "${var.app_name}-launch-template"
  disable_api_termination = true
  instance_type           = var.instance_type
  image_id                = data.aws_ami.linux.id
  update_default_version  = true

  tags = {
    Name = "${var.app_name}-launch-template"
  }
}

resource "aws_autoscaling_group" "autoscaling_group" {
  name                = "${var.app_name}-autoscaling-group"
  max_size            = 1
  min_size            = 1
  force_delete        = true
  vpc_zone_identifier = [aws_subnet.public.id]

  launch_template {
    id      = aws_launch_template.launch_template.id
    version = "$Latest"
  }

  depends_on = [aws_launch_template.launch_template]
}