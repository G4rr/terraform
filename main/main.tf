provider "aws" {
  region = "eu-west-2"
}

data "aws_availability_zones" "available" {}
data "aws_ami" "latest_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

#resource "aws_key_pair" "key_web" {
#  key_name   = "key"
#  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDXm7T5/+xU02n8OE8duxZMwczWBqfssp6henwMwmk9qETyczajNdJtEeBs9Ld/BjY7XcjDsOjI1mTeu+bSmneBAIvjUseW+bzYwwA7vbGEfmWAPMwwtEHNiNNb5X2nI/GaMylDkSFMfj+tTZLU5MeQbqXmjUGxMDrd2Wz8dYDITvZ5O0/IHkapOmn0k8LjzlLRd6wfFCnieXTDcSTTiM+tTPla3Pp5qEwodwfdhecoq3iggEy9x9b5A3a9YPpxXBR+h32pwTfRHoMfu65sLReieKTY3MYTBle5s1kIqBwHlTR7x3eUvVdXJ24b1NtVANf/rw70IaCO6lQAgW2sv1/ff9MiEMaJl+e2nXLsVusX+7Q3++8Qa8jNM110I4vROASRBhKhZnGlggYeWeEWetxgvMs1ZAqy6HjnRJoRqbuMyUBwQ1r5u87w8+ePXh3/v9loczCYn7LlZwFYwwPUGq9xQ7Sh/gaTbNjf436iuJxUjbrfKqCRelrBaEAUy6ilUXQ6fcgYIB2HOnc+j/xIgje7pAzPOEIIDTW/E0QHyVctj+K9VQZGV5YHs25vfeTYaiQubKoYyITR2upMQf3s7kFAfreSr64JtlokLIWnoFVARyVyE2m0Zx5gSVc/CoJjmgmTf3U6/e8h7quKL14EY4SMAJBEHRln2ra1QgMgPOEbcw== vanno@LTPE"
#}

resource "aws_security_group" "web_sg" {
  name_prefix        = "Web_SG-"
  description = "Dynamic SecurityGroup for WebServers"

  dynamic "ingress" {
    for_each = ["80", "8080"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "Dynamic SecurityGroup"
    Owner = "Oleksii Pryshchepa"
  }

}
############################################################################
# PROD SERVERS
resource "aws_launch_configuration" "prod_instnc" {
  name_prefix     = "WebServer-"
  image_id        = data.aws_ami.latest_linux.id
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.web_sg.id]
  #key_name        = aws_key_pair.key_web.id

  user_data = file("user-data.sh")

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "prod_instnc" {
  name                 = "ASG-${aws_launch_configuration.prod_instnc.name}"
  launch_configuration = aws_launch_configuration.prod_instnc.name
  min_size             = 2
  max_size             = 3
  min_elb_capacity     = 2
  health_check_type    = "ELB"
  vpc_zone_identifier  = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
  load_balancers       = [aws_elb.prod_instnc.name]

  dynamic "tag" {
    for_each = {
      Name  = "WebServer in ASG"
      Owner = "Oleksii Pryshchepa"
    }
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_elb" "prod_instnc" {
  name               = "WebServer-on-ELB"
  availability_zones = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  security_groups    = [aws_security_group.web_sg.id]
  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = 80
    instance_protocol = "http"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 10
  }
  tags = {
    Name = "WebServer-ELB"
  }
}

resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = data.aws_availability_zones.available.names[1]
}

resource "local_file" "dns" {
  content  = aws_elb.prod_instnc.dns_name
  filename = "../dns.txt"
}

