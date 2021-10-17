# USe default VPC
data "aws_vpc" "default" {
  default = true
}

#Fetch subnet from default VPC
data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}


#Get the latest AMI ID for Amazon Linux2 OS
data "aws_ami" "amzlinux2" {
  most_recent      = true
  owners           = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-gp2"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}
