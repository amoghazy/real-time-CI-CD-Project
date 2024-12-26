resource "aws_instance" "jenkins_server" {
  depends_on = [ aws_instance.control-plane ]

  ami             = var.ubuntu-ami
  instance_type   = var.ubuntu-instance-type
  key_name        = aws_key_pair.k8s-key.key_name
  vpc_security_group_ids = [aws_security_group.cluster_security_group.id]
  subnet_id = aws_subnet.public_sub2.id

 root_block_device {
    volume_size = 20 
    volume_type = "gp3" 
  }
  tags = {
    Name = "Jenkins-Server"
  }


 
}

resource "null_resource" "install_jenkins" {

  depends_on = [aws_instance.jenkins_server]

   provisioner "file" {
    source      = "./scripts/install-jenkins.sh"
    destination = "/home/ubuntu/install-jenkins.sh"
    
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("k8s-key")
      host        = aws_instance.jenkins_server.public_ip
    }
  }
   provisioner "file" {
    source      = "./scripts/install-k8s.sh"
    destination = "/home/ubuntu/install-k8s.sh"
    
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("k8s-key")
      host        = aws_instance.jenkins_server.public_ip
    }
  }

provisioner "file" {
    source      = "./scripts/install-docker.sh"
    destination = "/home/ubuntu/install-docker.sh"
    
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("k8s-key")
      host        = aws_instance.sonarqube_server.public_ip
    }
  }

  provisioner "remote-exec" {
   inline = [
      "export K8S_VERSION=${local.k8s_version}",
    
      "chmod +x /home/ubuntu/install-jenkins.sh",
      "chmod +x /home/ubuntu/install-k8s.sh",
    
      "/home/ubuntu/install-jenkins.sh",
      "/home/ubuntu/install-k8s.sh",
      "chmod +x /home/ubuntu/install-docker.sh",
       "/home/ubuntu/install-docker.sh",
       "sudo usermod -aG docker jenkins",
      "echo 'Setting hostname'",
      "sudo hostnamectl set-hostname jenkins-server",
    
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("k8s-key")
      host        = aws_instance.jenkins_server.public_ip
    }
  }
  
}


output "jenkins_url" {
    value = "http://${aws_instance.jenkins_server.public_ip}:8080"


}
 resource "null_resource" "get_jenkins_initial_pass" {
  depends_on = [aws_instance.jenkins_server]

  provisioner "local-exec" {
    command = <<EOT
      ssh -o StrictHostKeyChecking=no -i k8s-key ubuntu@${aws_instance.jenkins_server.public_ip} 'sudo cat /var/lib/jenkins/secrets/initialAdminPassword' > jenkins_initial_pass.txt
      EOT
  }
}

