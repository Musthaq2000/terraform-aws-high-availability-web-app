# Networking 
# 1. VPC

resource "aws_vpc" "my_vpc" {
  cidr_block = var.cidr
}

# 2. Subnet
resource "aws_subnet" "my_subnet1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "my_subnet2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-south-1b"
  map_public_ip_on_launch = true
}

# 3. Internet Gateway

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

# 4. Route Table
resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
}

# 5. Route Table Association

resource "aws_route_table_association" "my_rt1" {
  subnet_id      = aws_subnet.my_subnet1.id
  route_table_id = aws_route_table.my_route_table.id
}

resource "aws_route_table_association" "my_rt2" {
  subnet_id      = aws_subnet.my_subnet2.id
  route_table_id = aws_route_table.my_route_table.id
} 

# Security Group
resource "aws_security_group" "my_sg" {
  name        = "websg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  } 

   ingress {
    description = "Allow SSH"
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

  tags = {
    Name = "websg"
  }

}

# S3 Bucket

resource "aws_s3_bucket" "my_bucket" {
  bucket = "musthaqecluaseterraform" # Change this to a unique name
}

# Compute Instance

data "aws_ami" "ubuntu" {

  most_recent = true

  owners = ["099720109477"] # Canonical

  filter {
    name = "name"

    values = [
      "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"
    ]
  }

  filter {
    name = "virtualization-type"

    values = ["hvm"]
  }

}

resource "aws_instance" "Web-server1" {  
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.my_subnet1.id
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  key_name     = "MyKeyPair" # Ensure you have created this key pair in the specified region
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  user_data_base64 = base64encode(file("userdata1.sh"))

  tags = {
    Name = "WebServer1"
  }
}

resource "aws_instance" "Web-server2" {  
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.my_subnet2.id
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  key_name     = "MyKeyPair" # Ensure you have created this key pair in the specified region
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  user_data_base64 = base64encode(file("userdata2.sh"))

  tags = {
    Name = "WebServer2"
  }
}

# Load Balancer

# 1.Create Application Load Balancer

resource "aws_lb" "my_alb" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.my_sg.id]
  subnets            = [aws_subnet.my_subnet1.id, aws_subnet.my_subnet2.id]

  tags = {
    Name = "my-alb"
  }
}

# 2. Create Target Group

resource "aws_lb_target_group" "my_target_group" {
  name     = "my-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id

  health_check {
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
  }
}

# 3. Target Group Attachment

resource "aws_lb_target_group_attachment" "attach1" {
  target_group_arn = aws_lb_target_group.my_target_group.arn
  target_id        = aws_instance.Web-server1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "attach2" {
  target_group_arn = aws_lb_target_group.my_target_group.arn
  target_id        = aws_instance.Web-server2.id
  port             = 80
}

# 4. Create Listener

resource "aws_lb_listener" "my_listener" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_target_group.arn
  }
}

# 5. Output the Load Balancer DNS Name

output "load_balancer_dns_name" {
  value = aws_lb.my_alb.dns_name
}



