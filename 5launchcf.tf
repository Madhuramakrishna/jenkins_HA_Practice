# Create Jenkins server Launch configuration
resource "aws_launch_configuration" "jenkinslc" {
  name_prefix     = "aws_lc-"
  image_id        = data.aws_ami.amzlinux2.id
  instance_type   = var.instance_type
  key_name        = var.instance_keypair
  security_groups = [aws_security_group.Jenkins-SG.id]
  user_data       = <<-EOF
              #!/bin/bash
              sudo yum -y update
              sudo yum install -y unzip
              sudo yum install -y nfs-utils
              sudo mkdir -p /var/lib/jenkins
              sudo adduser -m -d /var/lib/jenkins jenkins
              sudo groupadd jenkins
              sudo usermod -a -G jenkins jenkins
              sudo chown -R jenkins:jenkins /var/lib/jenkins
              while ! (sudo mount -t nfs4 -o vers=4.1 $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone).${aws_efs_file_system.JenkinsEFS.dns_name}:/ /var/lib/jenkins); do sleep 10; done
              # Edit fstab so EFS automatically loads on reboot
              while ! (echo ${aws_efs_file_system.JenkinsEFS.dns_name}:/ /var/lib/jenkins nfs defaults,vers=4.1 0 0 >> /etc/fstab) ; do sleep 10; done
              sudo yum -y install java
              sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key;
              cat >/etc/yum.repos.d/jenkins.repo <<EOL
	      [jenkins]
	      name=Jenkins
	      baseurl=http://pkg.jenkins.io/redhat
	      gpgcheck=1
              EOL
              sudo yum -y update
              sudo yum -y install jenkins
              EOF
}
