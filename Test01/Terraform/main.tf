provider "aws" {
  region = "us-east-2"
}

resource "aws_security_group" "lb_sg" {
  name        = "lb_security_group-nof"
  description = "Allow HTTP inbound traffic"
  vpc_id = "vpc-084687c42bc6b6be7"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web_server" {
  ami               = "ami-0eb9d6fc9fab44d24"
  instance_type     = "t3.small"
  availability_zone = "us-east-2a"
  subnet_id         = "subnet-0dba81b888eb03998"  # Attach to a specific subnet

  tags = {
    Name = "WebServer"
  }
}

resource "aws_lb" "application_lb" {
  name               = "nof2"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = ["subnet-0dba81b888eb03998", "subnet-0caaa6ff3c583ca10"]
}

resource "aws_lb_target_group" "web_target_group" {
  name     = "web-target-group-nof01"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-084687c42bc6b6be7"
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.application_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_target_group.arn
  }
}

resource "aws_lb_target_group_attachment" "web_instance_attachment" {
  target_group_arn = aws_lb_target_group.web_target_group.arn
  target_id        = aws_instance.web_server.id
}

output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.web_server.id
}

output "public_ip" {
  description = "The public IP of the EC2 instance"
  value       = aws_instance.web_server.public_ip
}

output "load_balancer_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = aws_lb.application_lb.dns_name
}
