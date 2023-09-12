
 # 123


resource "aws_key_pair" "generated_key" {
  key_name   = "my_aws_key"
  public_key = file(var.Path_to_ssh)
}

resource "aws_instance" "Test" {
  ami                    = data.aws_ami.latest_free_ami.id
  instance_type          = var.ec2_instance_type
  subnet_id              = aws_subnet.publicsubnet.id
  key_name               = aws_key_pair.generated_key.key_name # Reference the key pair resource
  vpc_security_group_ids = [aws_security_group.my_security_group.id]
  #
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  user_data = templatefile("NginxInstall.sh.tpl", {
    Hello = var.templateVarHello,
    Names = var.templateVar1
  })
  tags = {
    Name = "test server"
  }
}

resource "aws_security_group" "my_security_group" {
  name        = "Dynamic-my-security-group"
  description = "My Security Group"
  vpc_id      = aws_vpc.myvpc.id
  dynamic "ingress" {
    for_each = ["80", "22"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraformVpc"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_internet_gateway.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.publicsubnet.id
  route_table_id = aws_route_table.public.id
}

resource "aws_internet_gateway" "my_internet_gateway" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "terraformInternetGateway"
  }

}

resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "terraformVpc"
  }
}

resource "aws_subnet" "publicsubnet" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.current.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name              = "terraformPublic"
    availability_zone = data.aws_availability_zones.current.names[0]
  }
}

resource "aws_subnet" "privatesubnet" {
  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.current.names[1]
  tags = {
    Name              = "terraformPrivate"
    availability_zone = data.aws_availability_zones.current.names[1]
  }
}

#===============================>
resource "aws_s3_bucket" "my_bucket" {
  bucket_prefix = "mybucket-s3-"
  tags = {
    Name        = "mybucket-s3-"
    Environment = "Environment"
  }
}
#================================>
resource "aws_iam_role_policy" "ec2_policy" {
  name = "ec2_policy"
  role = aws_iam_role.role_for_s3.id

  #ec2:*Describe
  policy = data.aws_iam_policy_document.policy_my_bucket.json
}

resource "aws_iam_role" "role_for_s3" {
  name = "role_for_s3"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "instance_allow_to_s3_bucket"
  role = aws_iam_role.role_for_s3.name
}
#====================================>
resource "aws_iam_policy" "policy_for_ec2" {
  name   = "s3-bucket-allow"
  policy = data.aws_iam_policy_document.policy_my_bucket.json
}
resource "aws_iam_role" "instance" {
  name                = "instance_role"
  path                = "/system/"
  assume_role_policy  = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
        
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
  managed_policy_arns = [aws_iam_policy.policy_for_ec2.arn]
}
data "aws_iam_policy_document" "policy_my_bucket" {
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = [
      "${aws_s3_bucket.my_bucket.arn}/*"
    ]
  }
}

