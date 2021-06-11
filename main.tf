provider "aws" {
	region     = "eu-west-2"
}

resource "aws_instance" "my_webserver" {
  ami                    = "ami-03a71cec707bfc3d7"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.my_webserver.id]
  user_data              = <<EOF
	#!/bin/bash
	yum -y update
	yum -y install httpd
	myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
	echo "<h2>WebServer with IP: $myip</h2><br>Build by Terraform!"  >  /var/www/html/index.html
	sudo service httpd start
	chkconfig httpd on
EOF

  tags = {
    Name = "Web Server Build by Terraform from Jenkins"
    Owner = "Oleksii Pryshchepa"
  }
}


resource "aws_security_group" "my_webserver" {
  name = "WebServer Security Group"
  description = "My First SecurityGroup"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Web Server SecurityGroup"
    Owner = "Oleksii Pryshchepa"
  }
}