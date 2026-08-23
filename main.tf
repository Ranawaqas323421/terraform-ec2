provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_key_pair" "default" {
  key_name   = "terrafrom1"
  public_key = file("/home/codespace/.ssh/id_rsa.pub")
}

resource "aws_security_group" "ec2_sg" {
  name        = "allow_ssh"
  description = "Allow SSH traffic"
  vpc_id      = data.aws_vpc.default.id

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

resource "aws_instance" "default" {
  ami                    = "ami-0b6d9d3d33ba97d99"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.default.key_name
  subnet_id              = data.aws_subnets.default.ids[0]
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  tags = {
    Name = "Terraform-RANA"
  }
}

output "ec2_instance_info" {
  value = {
    name        = aws_instance.default.tags["Name"]
    public_ip   = aws_instance.default.public_ip
    public_dns  = aws_instance.default.public_dns
    username    = "ec2-user"
    ssh_command = "ssh -i ~/.ssh/terraform-key.pem ec2-user@${aws_instance.default.public_dns}"
  }
}