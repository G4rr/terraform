provider "aws" {
	region     = "eu-west-2"
}

data "aws_ami" "latest_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "web_server" {
  ami                    = data.aws_ami.latest_linux.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  user_data              = <<EOF
	#!/bin/bash
	sudo yum -y update
	sudo yum -y install httpd
	myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
	sudo echo "<h2>WebServer with IP: $myip</h2><br>Build by Terraform!"  >  /var/www/html/index.html
	sudo service httpd start
	sudo chkconfig httpd on
EOF

  tags = {
    Name = "Web Server Build by Terraform from Jenkins"
    Owner = "Oleksii Pryshchepa"
  }
}


resource "aws_security_group" "web_sg" {
  name        = "Web_Dsg"
  description = "Dynamic SecurityGroup for WebServers"

  dynamic "ingress" {
    for_each = ["80", "22"]
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