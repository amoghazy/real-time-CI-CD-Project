
resource "aws_instance" "web" {
depends_on = [ aws_instance.control-plane , aws_instance.jenkins_server]
  ami             = var.ubuntu-ami
  key_name        = aws_key_pair.k8s-key.key_name
  vpc_security_group_ids = [aws_security_group.cluster_security_group.id]
  subnet_id = aws_subnet.public_sub2.id

  instance_type     = "t2.micro"


  tags = {
    Name = "monitor-server"
  }
  provisioner "file" {

    source      = "./scripts/install-monitor-tools.sh"
    destination = "/tmp/install-monitor-tools.sh"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("k8s-key")
      host        = self.public_ip
    }
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install-monitor-tools.sh",
      "/tmp/install-monitor-tools.sh",
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("k8s-key")
      host        = self.public_ip
    }
  }
}

output "prometheus_url" {
    value = "http://${aws_instance.web.public_ip}:9090"

}
output "grafana_url" {
    value = "http://${aws_instance.web.public_ip}:3000"
  
}