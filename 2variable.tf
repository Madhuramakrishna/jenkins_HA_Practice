variable "Jenkins_region" {
  description = "Region in which Jenkins server to be created"
  default     = "ap-south-1"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
  type        = string
}

variable "instance_keypair" {
  description = "AWS EC2 key pair that need to be associated with EC2 Instance"
  default     = "general"
  type        = string
}

# AWS EC2 Instance Type - List
variable "instance_type_list" {
  description = "EC2 Instance type"
  type        = list(string)
  default     = ["t3.micro", "t3.small"]
}

# AWS EC2 Instance Type - Map
variable "instance_type_map" {
  description = "EC2 instance Type"
  type        = map(string)
  default     = {
    "dev"     = "t3.micro"
    "qa"      = "t3.small"
    "prod"    = "t2.micro"
  }
}

variable "jenkins_port" {
  type = number
  default = 8080
}

variable "alb_port" {
  type = number
  default = 80
}
