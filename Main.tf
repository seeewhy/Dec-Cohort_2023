provider "aws" {
  region     = "us-east-2"
  access_key = ""
  secret_key = ""
}

/*resource "aws_instance" "firstinstance" {
  ami           = "ami-0a695f0d95cefc163" 
  instance_type = "t2.micro"

}*/


#Create a VPC

resource "aws_vpc" "prodvpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "production_vpc"
  }
}

# Create a subnet

resource "aws_subnet" "prodsubnet1" {
  vpc_id     = aws_vpc.prodvpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "Main"
  }
}

# Create an Internet Gateway

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.prodvpc.id

  tags = {
    Name = "IGW"
  }
}


# Create a Route Table

resource "aws_route_table" "prodroute" {
  vpc_id = aws_vpc.prodvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  
  tags = {
    Name = "RT"
  }
}


# Associate subnet to route Table

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.prodsubnet1.id
  route_table_id = aws_route_table.prodroute.id
}

# create a security group

resource "aws_security_group" "allow_web" {
  name        = "allow_web"
  description = "Allow web server for inbound traffic"
  vpc_id = aws_vpc.prodvpc.id

  ingress {
    description      = "web traffic HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  ingress {
    description      = "web traffic HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  ingress {
    description      = "web traffic SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  tags = {
    Name = "allow_tls"
  }
}


# Create an instance and add a security group to that instance

resource "aws_instance" "firstinstance" {
  ami           = "ami-0a695f0d95cefc163" 
  instance_type = "t2.micro"
  subnet_id      = aws_subnet.prodsubnet1.id
  vpc_security_group_ids = [aws_security_group.allow_web.id]
  availability_zone = "us-east-2b"
  key_name   = "new_key_pair-ohio"
  count = 3
  tags = {
    Name = "Web_Server"
  }

}

