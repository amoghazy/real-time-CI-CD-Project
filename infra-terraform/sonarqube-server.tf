resource "aws_instance" "sonarqube_server" {
  depends_on = [ aws_instance.control-plane ]
  ami             = var.ubuntu-ami
  instance_type   = var.ubuntu-instance-type
  key_name        = aws_key_pair.k8s-key.key_name
  vpc_security_group_ids = [aws_security_group.cluster_security_group.id]
  subnet_id = aws_subnet.public_sub2.id


  tags = {
    Name = "Sonarqube-Server"
  }


}

resource "null_resource" "install_sonarqube" {

  depends_on = [aws_instance.sonarqube_server]

 

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
      "chmod +x /home/ubuntu/install-docker.sh",
       "/home/ubuntu/install-docker.sh",
      "echo 'Setting hostname ....'  ",
      "sudo hostnamectl set-hostname sonarqube-server",
      "sudo chmod 666 /var/run/docker.sock" ,
      "echo 'Starting Sonarqube Server ....'  ",
      "docker run -d --name sonar -p 9000:9000 sonarqube:lts-community",
      "echo 'Waiting for Sonarqube Server to start ....'  ",
      "sleep 15",
      "echo 'Sonarqube Server started successfully ....'  ",
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("k8s-key")
      host        = aws_instance.sonarqube_server.public_ip

    }
  }


}

output "sonarqube_url" {
    value = "http://${aws_instance.sonarqube_server.public_ip}:9000"

}