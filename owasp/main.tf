provider "aws" {
  region = "eu-west-2"
}

data "aws_availability_zones" "available" {}

resource "aws_key_pair" "key_web" {
  key_name   = "key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDXm7T5/+xU02n8OE8duxZMwczWBqfssp6henwMwmk9qETyczajNdJtEeBs9Ld/BjY7XcjDsOjI1mTeu+bSmneBAIvjUseW+bzYwwA7vbGEfmWAPMwwtEHNiNNb5X2nI/GaMylDkSFMfj+tTZLU5MeQbqXmjUGxMDrd2Wz8dYDITvZ5O0/IHkapOmn0k8LjzlLRd6wfFCnieXTDcSTTiM+tTPla3Pp5qEwodwfdhecoq3iggEy9x9b5A3a9YPpxXBR+h32pwTfRHoMfu65sLReieKTY3MYTBle5s1kIqBwHlTR7x3eUvVdXJ24b1NtVANf/rw70IaCO6lQAgW2sv1/ff9MiEMaJl+e2nXLsVusX+7Q3++8Qa8jNM110I4vROASRBhKhZnGlggYeWeEWetxgvMs1ZAqy6HjnRJoRqbuMyUBwQ1r5u87w8+ePXh3/v9loczCYn7LlZwFYwwPUGq9xQ7Sh/gaTbNjf436iuJxUjbrfKqCRelrBaEAUy6ilUXQ6fcgYIB2HOnc+j/xIgje7pAzPOEIIDTW/E0QHyVctj+K9VQZGV5YHs25vfeTYaiQubKoYyITR2upMQf3s7kFAfreSr64JtlokLIWnoFVARyVyE2m0Zx5gSVc/CoJjmgmTf3U6/e8h7quKL14EY4SMAJBEHRln2ra1QgMgPOEbcw== vanno@LTPE"
}

resource "aws_instance" "test_instnc" {
  ami                    = "ami-09a56048b08f94cdf"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = aws_key_pair.key_web.id

  user_data = file("user-data.sh")

  associate_public_ip_address = true
  tags = {
    Name = "Test_Server"
  }
}

resource "aws_security_group" "web_sg" {
  name        = "Web_SG"
  description = "Dynamic SecurityGroup for WebServers"

  dynamic "ingress" {
    for_each = ["80", "22", "8080"]
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