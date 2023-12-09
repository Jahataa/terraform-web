terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.0.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.secret_key
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "ubuntu-web" {
  most_recent = "true"

  filter {
    name   = "image-id"
    values = ["ami-0ff1c68c6e837b183"]
  }
  owners = ["099720109477"]
}

resource "aws_vpc" "web-vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  tags = {
    Name = "web-vpc"
  }
}

resource "aws_internet_gateway" "web_igw" {
  vpc_id = aws_vpc.web-vpc.id
  tags = {
    Name = "web_igw"
  }
}

resource "aws_subnet" "web_public_subnet" {
  count             = var.subnet_count.public
  vpc_id            = aws_vpc.web-vpc.id
  cidr_block        = var.public_subnet_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "web_public_subnet_${count.index}"
  }
}

resource "aws_route_table" "web_public_rt" {
  vpc_id = aws_vpc.web-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.web_igw.id
  }
}

resource "aws_route_table_association" "public" {
  count          = var.subnet_count.public
  route_table_id = aws_route_table.web_public_rt.id
  subnet_id      = 	aws_subnet.web_public_subnet[count.index].id
}


resource "aws_security_group" "web_web_sg" {
  name        = "web_web_sg"
  description = "Security group for test web servers"
  vpc_id      = aws_vpc.web-vpc.id
  ingress {
    description = "Allow all traffic through HTTP"
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow SSH from my computer"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "web_sg"
  }
}

resource "aws_key_pair" "web_kp" {
  key_name   = "key"
  public_key = file("key.pub")
}

resource "aws_efs_file_system" "web_efs" {
  creation_token = "web-efs"
}

resource "aws_efs_mount_target" "web_efs_mount_target" {
  file_system_id = aws_efs_file_system.web_efs.id
  count          = length(aws_subnet.web_public_subnet)
  subnet_id      = aws_subnet.web_public_subnet[count.index].id
}

resource "aws_instance" "web" {
  count                  = var.settings.web_app.count
  ami                    = data.aws_ami.ubuntu-web.id
  instance_type          = var.settings.web_app.instance_type
  subnet_id              = aws_subnet.web_public_subnet[count.index].id
  key_name               = aws_key_pair.web_kp.key_name
  vpc_security_group_ids = [aws_security_group.web_web_sg.id]
  user_data = "${file("build.sh")}"

  tags = {
    Name = "web_${count.index}"
  }
}

resource "aws_eip" "web_eip" {
  count    = var.settings.web_app.count
  instance = aws_instance.web[count.index].id
  vpc      = true
  tags = {
    Name = "web_eip_${count.index}"
  }
}

resource "aws_lb" "web_lb" {
  name               = "web-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_web_sg.id]
  subnets            = aws_subnet.web_public_subnet[*].id

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "web_target_group" {
  name     = "web-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.web-vpc.id
}

resource "aws_lb_listener" "web_lb_listener" {
  load_balancer_arn = aws_lb.web_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_target_group.arn
  }
}

resource "aws_lb_target_group_attachment" "web_lb_attachment" {
  target_group_arn = aws_lb_target_group.web_target_group.arn
  count            = length(aws_instance.web)
  target_id        = aws_instance.web[count.index].id
  port             = 80
}

resource "aws_cloudwatch_metric_alarm" "requests_alarm" {
  alarm_name          = "HighRequestCountAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "RequestCount"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Sum"
  threshold           = "1000"
  alarm_description  = "Alarm when the total number of requests exceeds 1000"
}
