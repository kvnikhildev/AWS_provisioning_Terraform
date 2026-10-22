#creation of first VPC
resource "aws_vpc" "vpc_1" {
  cidr_block = "10.0.0.0/24"
  tags = {
    Name = "vpc_server_1"
  }

}
#creation of second VPC
resource "aws_vpc" "vpc_2" {
  cidr_block = "11.0.0.0/24"
  tags = {
    Name = "vpc_server_2"
  }

}
#creation of subnet under first VPC
resource "aws_subnet" "subnet_1_1a" {
  vpc_id     = aws_vpc.vpc_1.id
  cidr_block = "10.0.0.0/28"
  tags = {
    Name = "subnet_for_server_1_1a"
  }

}
#creation of subnet under first VPC
resource "aws_subnet" "subnet_2_1a" {
  vpc_id     = aws_vpc.vpc_2.id
  cidr_block = "11.0.0.0/28"
  tags = {
    Name = "subnet_for_server_2_1a"
  }

}
#creation of internet gatway for vpc 1
resource "aws_internet_gateway" "igw_vpc_1" {
  vpc_id = aws_vpc.vpc_1.id
  tags = {
    Name = "igw_vpc_1"
  }

}
#creation of internet gatway for vpc 2
resource "aws_internet_gateway" "igw_vpc_2" {
  vpc_id = aws_vpc.vpc_2.id
  tags = {
    Name = "igw_vpc_2"
  }

}
#create route table for vpc1
resource "aws_route_table" "rt_vpc_1" {
  vpc_id = aws_vpc.vpc_1.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_vpc_1.id
  }
  route {
    cidr_block = "11.0.0.0/28"
    vpc_peering_connection_id = aws_vpc_peering_connection.vpc_to_vpc.id # add route to the vpc 2 
  }

}
#assosiate the subnet with route table
resource "aws_route_table_association" "sub_ass_rt_1" {
  subnet_id      = aws_subnet.subnet_1_1a.id
  route_table_id = aws_route_table.rt_vpc_1.id

}

#create route table for vpc2
resource "aws_route_table" "rt_vpc_2" {
  vpc_id = aws_vpc.vpc_2.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_vpc_2.id
  }
  route {
    cidr_block = "10.0.0.0/28"
    vpc_peering_connection_id = aws_vpc_peering_connection.vpc_to_vpc.id  # add route to the vpc 1 
  }
}
#assosiate the subnet with route table
resource "aws_route_table_association" "sub_ass_rt_2" {
  subnet_id      = aws_subnet.subnet_2_1a.id
  route_table_id = aws_route_table.rt_vpc_2.id

}
#creation of server 1 in vpc 1
resource "aws_instance" "apache_server_1" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = aws_subnet.subnet_1_1a.id

  vpc_security_group_ids      = [aws_security_group.server_1_sg.id]
  user_data                   = file("${path.module}/server.sh")
  user_data_replace_on_change = true
  associate_public_ip_address = true
}
#security group for the server 1
resource "aws_security_group" "server_1_sg" {
  vpc_id = aws_vpc.vpc_1.id
  tags = {
    Name = "server_1_security_group"
  }
}
#ssh rule for securiy group 1 
resource "aws_security_group_rule" "ssh_1" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.server_1_sg.id
}
#http rule for securiy group 1 
resource "aws_security_group_rule" "http1_" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.server_1_sg.id
}
#allow all outbond server 1
resource "aws_security_group_rule" "allow_all_server_1" {
  type = "egress"
  from_port = 0
  to_port  = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.server_1_sg.id
  
}
#allow all outbond server 2 
resource "aws_security_group_rule" "allow_all_server_2" {
  type = "egress"
  from_port = 0
  to_port  = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.server_2_sg.id
  
}

#creation of server 2 in vpc 2
resource "aws_instance" "apache_server_2" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.subnet_2_1a.id
  vpc_security_group_ids = [aws_security_group.server_2_sg.id]
  user_data                   = file("${path.module}/server.sh")
  user_data_replace_on_change = true
  associate_public_ip_address = true
  

}
#security group for the server 2
resource "aws_security_group" "server_2_sg" {
  vpc_id = aws_vpc.vpc_2.id
  tags = {
    Name = "server_2_security_group"
  }

}
#ssh rule for securiy group 2
resource "aws_security_group_rule" "ssh_2" {
  type              = "ingress"
  to_port           = 22
  from_port         = 22
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.server_2_sg.id

}
#http rule for securiy group 2
resource "aws_security_group_rule" "http_2" {
  type              = "ingress"
  to_port           = 80
  from_port         = 80
  cidr_blocks = ["0.0.0.0/0"]
  protocol          = "tcp"
  security_group_id = aws_security_group.server_2_sg.id

}

#VPC peering connection for communication between vpcs 
resource "aws_vpc_peering_connection" "vpc_to_vpc" {
  peer_owner_id = var.peer_owner_id  # accepter account id 
  peer_vpc_id = aws_vpc.vpc_1.id    # accepter vpc id
  vpc_id = aws_vpc.vpc_2.id         # requester vpc id 
  auto_accept = true
  
}

