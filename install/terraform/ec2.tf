# Key Pair
resource "aws_key_pair" "my-key-pair" {
  key_name   = "devops"
  public_key = file("~/.ssh/id_rsa.pub")
}

# Security Group
resource "aws_security_group" "allow_all_outbound" {
  name        = "allow_all_outbound"
  description = "Allow all outbound traffic"
  vpc_id      = aws_vpc.my-vpc.id

  tags = {
    Name = "allow_all_outbound"
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_all_outbound.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.my-vpc.id

  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow HTTP and HTTPS inbound traffic"
  vpc_id      = aws_vpc.my-vpc.id

  tags = {
    Name = "allow_http"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.allow_http.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_https_ipv4" {
  security_group_id = aws_security_group.allow_http.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_security_group" "allow_nexus" {
  name        = "allow_nexus"
  description = "Allow 8081 inbound traffic"
  vpc_id      = aws_vpc.my-vpc.id

  tags = {
    Name = "allow_nexus"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_nexus_ipv4" {
  security_group_id = aws_security_group.allow_nexus.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8081
  ip_protocol       = "tcp"
  to_port           = 8081
}

resource "aws_security_group" "allow_sonarqube" {
  name        = "allow_sonarqube"
  description = "Allow 9000 inbound traffic"
  vpc_id      = aws_vpc.my-vpc.id

  tags = {
    Name = "allow_sonarqube"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_sonarqube_ipv4" {
  security_group_id = aws_security_group.allow_sonarqube.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 9000
  ip_protocol       = "tcp"
  to_port           = 9000
}

# EC2
resource "aws_instance" "jenkins" {
  ami                    = var.AMI
  instance_type          = var.INSTANCE_TYPE
  key_name               = aws_key_pair.my-key-pair.key_name
  subnet_id              = aws_subnet.my-public-subnet-1.id
  vpc_security_group_ids = [aws_security_group.allow_all_outbound.id, aws_security_group.allow_ssh.id, aws_security_group.allow_http.id]

  provisioner "local-exec" {
    command = "echo '${aws_instance.jenkins.public_ip} jenkins' | sudo tee -a /etc/hosts"
  }

  provisioner "remote-exec" {
    inline = ["sudo hostnamectl set-hostname jenkins"]
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/id_rsa")
    host        = self.public_ip
  }

  tags = {
    Name = "jenkins"
  }
}

resource "aws_instance" "nexus" {
  ami                    = var.AMI
  instance_type          = var.INSTANCE_TYPE
  key_name               = aws_key_pair.my-key-pair.key_name
  subnet_id              = aws_subnet.my-public-subnet-1.id
  vpc_security_group_ids = [aws_security_group.allow_all_outbound.id, aws_security_group.allow_ssh.id, aws_security_group.allow_http.id, aws_security_group.allow_nexus.id,]

  provisioner "local-exec" {
    command = "echo '${aws_instance.nexus.public_ip} nexus' | sudo tee -a /etc/hosts"
  }

  provisioner "remote-exec" {
    inline = ["sudo hostnamectl set-hostname nexus"]
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/id_rsa")
    host        = self.public_ip
  }

  tags = {
    Name = "nexus"
  }
}

resource "aws_instance" "sonarqube" {
  ami                    = var.AMI
  instance_type          = var.INSTANCE_TYPE
  key_name               = aws_key_pair.my-key-pair.key_name
  subnet_id              = aws_subnet.my-public-subnet-1.id
  vpc_security_group_ids = [aws_security_group.allow_all_outbound.id, aws_security_group.allow_ssh.id, aws_security_group.allow_http.id, aws_security_group.allow_sonarqube.id,]

  provisioner "local-exec" {
    command = "echo '${aws_instance.sonarqube.public_ip} sonarqube' | sudo tee -a /etc/hosts"
  }

  provisioner "remote-exec" {
    inline = ["sudo hostnamectl set-hostname sonarqube"]
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/id_rsa")
    host        = self.public_ip
  }

  tags = {
    Name = "sonarqube"
  }
}
