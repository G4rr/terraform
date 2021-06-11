provider "aws" {
	access_key = "AKIAW3X422IFO3FJZC2T"
	secret_key = "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"
	region     = "eu-west-2"
}


resource "aws_instance" "my_Ubuntu" {
  ami           = "ami-090f10efc254eaf55"
  instance_type = "t2.micro"

  tags = {
    Name    = "My Ubuntu Server"
    Owner   = "Oleksii Pryshchepav"
    Project = "Terraform from jenkins"
  }
}

resource "aws_instance" "my_Amazon" {
  ami           = "ami-03a71cec707bfc3d7"
  instance_type = "t2.small"

  tags = {
    Name    = "My Amazon Server"
    Owner   = "Oleksii Pryshchepav"
    Project = "Terraform from jenkins"
  }
}