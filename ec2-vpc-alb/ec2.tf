#create a new vpc
resource "aws_vpc" "apache_vpc" {
  cidr_block = "10.0.0.0/24"
  tags = {
    Name = "apache servervpc"
  }
}
#Create first subnet attached to the vpc
resource "aws_subnet" "apache_subnet-1" {
  cidr_block        = "10.0.0.0/28"
  vpc_id            = aws_vpc.apache_vpc.id
  availability_zone = "us-east-1a"
  tags = {
    Name = "public_subnet-1-us-east-1a"
  }
}
#create the second subnet attached to the vpc
resource "aws_subnet" "apche_subnet-2" {
  cidr_block        = "10.0.0.16/28"
  vpc_id            = aws_vpc.apache_vpc.id
  availability_zone = "us-east-1b"
  tags = {
    Name = "public_subnet-2-us-east-1b"
  }

}
#Creation of internet gatway to provied internet to the public subnet.attached to the vpc also 
resource "aws_internet_gateway" "apache-ig" {
  vpc_id = aws_vpc.apache_vpc.id
  tags = {
    Name = "internet-gatway-for-vpc-apche"
  }
}
#Create first Routing table also add route to the first subnet talk to the internetgatway
resource "aws_route_table" "apache-rt-1" {
  vpc_id = aws_vpc.apache_vpc.id
  tags = {
    Name = "apache-server-rt-1"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.apache-ig.id
  }

}
#Add the subnet to the routing table ,that is linking both routing table id and subnet id 
resource "aws_route_table_association" "subnet-ass-1" {
  subnet_id      = aws_subnet.apache_subnet-1.id
  route_table_id = aws_route_table.apache-rt-1.id

}
#create the second Routing table and add route the second subnet talk top the internetgatway
resource "aws_route_table" "apache-rt-2" {
  vpc_id = aws_vpc.apache_vpc.id
  tags = {
    Name = "apche-server-rt-2"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.apache-ig.id

  }

}
#add the subnet to the routing tale that is linking both routing table id and subnet id 
resource "aws_route_table_association" "subnet-ass-2" {
  route_table_id = aws_route_table.apache-rt-2.id
  subnet_id      = aws_subnet.apche_subnet-2.id

}
#create the security group for EC2 
resource "aws_security_group" "ec2_sg" {
  name        = "allow_ssh"
  description = "allow ssh and port 80 trafic to ec2"
  vpc_id      = aws_vpc.apache_vpc.id
  tags = {
    Name : "ec2-ssh-and-port-80"
  }
}
#Add the rule for the ec2 rhat is SSH access from anywhere (if you want to add security you can add here)
resource "aws_security_group_rule" "allow_ssh_for_ec2" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ec2_sg.id

}
#Add the rule that is allow port 80 becuase we run apche server in that EC2 
resource "aws_security_group_rule" "allow_http_for_ec2" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb_sg.id
  security_group_id        = aws_security_group.ec2_sg.id

}
#Adding out rule because we have user data in EC2 which is install during the creation time so it need access outside all port need to open
resource "aws_security_group_rule" "allow_out" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ec2_sg.id

}
#Create Launch templete which is help for creating EC2 provied all details of what kind of EC2 needed

resource "aws_launch_template" "apache-server" {
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name


  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.ec2_sg.id]

  }
  user_data = filebase64("${path.module}/apacheserver.sh")

}
#Create autoscalilng group which is scale whcih create the ec2 with lunch temp. also help autoscaling 
resource "aws_autoscaling_group" "apache_server_scaling" {
  name                = "apache-server-auto-scale"
  max_size            = 2
  min_size            = 1
  vpc_zone_identifier = [aws_subnet.apache_subnet-1.id, aws_subnet.apche_subnet-2.id]
  launch_template {
    id      = aws_launch_template.apache-server.id
    version = "$Latest"
  }
  target_group_arns = [aws_alb_target_group.alb_tg.arn]


}
#create Application load balancer 

resource "aws_lb" "apache-alb" {
  name               = "alb-for-apache"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.apache_subnet-1.id, aws_subnet.apche_subnet-2.id]

}
#Create security group for alb
resource "aws_security_group" "alb_sg" {
  name        = "allow_http"
  description = "allow http in alb"
  vpc_id      = aws_vpc.apache_vpc.id
  tags = {
    Name = "alb-sg-http"
  }

}
#Add rule for alb security group which is open port 80
resource "aws_security_group_rule" "allow_http_for_alb" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_sg.id
}
#Add rule for alb security group which is open all port from inside 
resource "aws_security_group_rule" "alb_outbond" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  protocol          = "-1"
  security_group_id = aws_security_group.alb_sg.id

}
#Create target goup with instance type and we add this tg group link in the autoscaling group
resource "aws_alb_target_group" "alb_tg" {
  target_type = "instance"
  name        = "alb-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.apache_vpc.id
}
#create alb listener that is add target group to the alb 
resource "aws_alb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.apache-alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.alb_tg.arn
  }

}




