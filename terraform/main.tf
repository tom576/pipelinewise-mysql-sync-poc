provider "aws" {
  region = "eu-west-2"
}

variable "db_port" {
  description = "The port the db is listening on"
  type        = number
  default     = 3306
}


resource "aws_vpc" "poc_vpc" {
  cidr_block       = "10.0.0.0/16"

  tags = {
    Name = "poc"
  }
}

resource "aws_internet_gateway" "poc_igw" {
  vpc_id = aws_vpc.poc_vpc.id

  tags = {
    Name = "poc_igw"
  }
}

resource "aws_subnet" "poc_subnet" {
  vpc_id                  = aws_vpc.poc_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "poc_subnet"
  }
}

resource "aws_route_table" "poc_rt" {
  vpc_id = aws_vpc.poc_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.poc_igw.id
  }

  tags = {
    Name = "poc_rt"
  }
}

resource "aws_route_table_association" "rt_sub_ass_poc" {
  subnet_id      = aws_subnet.poc_subnet.id
  route_table_id = aws_route_table.poc_rt.id
}


resource "aws_instance" "mysql_source_db" {
  ami                    = "ami-0eb89db7593b5d434"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.poc_sg.id]
  subnet_id              = aws_subnet.poc_subnet.id
  key_name               = "MyEC2KeyPair"
  tags = {
    Name = "MySQLSourceDB"
  }
}

resource "aws_security_group" "poc_sg" {
  name   = "poc_sg"
  vpc_id = aws_vpc.poc_vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["80.192.115.141/32"]
  }
  ingress {
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = ["80.192.115.141/32","10.0.1.0/24"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  } 
} 

