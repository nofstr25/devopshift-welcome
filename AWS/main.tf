provider "aws" {
  region = var.region
}

resource "aws_security_group" "sg" {
ingress {
    from_port   = 22
    to_port     = 22
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

resource "aws_instance" "vm" {
  ami           = "ami-025a9b1af952cc749" # Amazon Linux 2 AMI in us-east-1
  instance_type = "t2.micro"
  subnet_id              =   "subnet-06acd0b316280afeb"
  vpc_security_group_ids = [aws_security_group.sg.id]
  tags = {
  Name = "nof-vm1"
  }
}

output "vm_public_ip" {
  value       = aws_instance.vm.public_ip
  description = "Public IP address of the VM"
}