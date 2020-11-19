terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region     = "eu-west-1"
  access_key = "<YOUR_ACESS_KEY>"
  secret_key = "<YOUR_SECRET_KEY>"
}



# Configure the AWS Provider 
# 1. Create VPC 
resource "aws_vpc" "demo-vpc" {
  cidr_block = "10.0.0.0/16"
}
# 2. Create a Subnet 
resource "aws_subnet" "demo-subnet" {
  vpc_id            = aws_vpc.demo-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "Demo Subnet 1a"
  }
}

# 3. Create Internet gateway 
resource "aws_internet_gateway" "demo-igw" {
  vpc_id = aws_vpc.demo-vpc.id

  tags = {
    Name = "Demo IGW"
  }
}

# 4. Create Route table 
resource "aws_route_table" "demo-route-table" {
  vpc_id = aws_vpc.demo-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo-igw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.demo-igw.id
  }

  tags = {
    Name = "Demo RT"
  }
}
# 5. Assign the RB to the Subnet 
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.demo-subnet.id
  route_table_id = aws_route_table.demo-route-table.id
}

# 6. Create Security group to allow access on port 22,80,443 
resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id      = aws_vpc.demo-vpc.id

  ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "https"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["93.152.152.242/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "demo-sg"
  }
}
# 7. Create network interface with an ip in the subnet that was created in step 4 
resource "aws_network_interface" "demo-nic" {
  subnet_id       = aws_subnet.demo-subnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_all.id]
}


# 8. Assign an EIP to the network interface in step 7 
resource "aws_eip" "demo-eip" {
  instance          = aws_instance.demo-web-server.id
  network_interface = aws_network_interface.demo-nic.id

  vpc        = true
  depends_on = [aws_internet_gateway.demo-igw]

}
# 9. Create Ubuntu server and install/enable nginx 

resource "aws_instance" "demo-web-server" {
  ami               = "ami-089cc16f7f08c4457"
  instance_type     = "t2.micro"
  availability_zone = "eu-west-1a"
  key_name          = "demo-key"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.demo-nic.id
  }

  user_data = <<-EOL
              #!/bin/env bash
              sudo apt update -y
              sudo apt install nginx -y
              sudo systemctl start nginx
              sudo bash -c 'echo Our demo aws instance with terraform for fun. > /var/www/html/index.html'
              EOL
  tags = {
    Name = "Demo instance"

  }

}