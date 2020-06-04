provider "aws" {
  region = "eu-west-2"
}

resource "aws_instance" "mysql_source_db" {
  ami           = "ami-0eb89db7593b5d434"
  instance_type = "t2.micro"
}
