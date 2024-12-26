resource "aws_instance" "control-plane" {
  ami             = var.ubuntu-ami
  instance_type   = var.ubuntu-instance-type
  key_name        = aws_key_pair.k8s-key.key_name
  vpc_security_group_ids = [aws_security_group.cluster_security_group.id]
  subnet_id = aws_subnet.public_sub1.id


  tags = {
    Name = "control-plane"
  }

}

resource "null_resource" "configure_k8s" {
  depends_on = [ aws_instance.control-plane ]


  provisioner "file" {
    source      = "k8s-key"
    destination = "/home/ubuntu/k8s-key"
      connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("k8s-key")
    host        = aws_instance.control-plane.public_ip
  }
  
  }
  provisioner "file" {
    source      = "../k8s/manifests/initial-cluster.yaml"
    destination = "/home/ubuntu/initial-cluster.yaml"
      connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("k8s-key")
    host        = aws_instance.control-plane.public_ip

  }
  
  }
   provisioner "file" {
    source      = "./scripts"
    destination = "/home/ubuntu/scripts"
    
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("k8s-key")
      host        = aws_instance.control-plane.public_ip
    }
  }

  provisioner "remote-exec" {
   inline = [
      "echo 'Starting export K8S_VERSION'",
      "export K8S_VERSION=${local.k8s_version}",
      "echo 'Setting executable permissions for scripts'",
      "chmod +x /home/ubuntu/scripts/*",
    
       "/home/ubuntu/scripts/install-containerD.sh",
      "/home/ubuntu/scripts/configure-containerD.sh",
      "/home/ubuntu/scripts/install-k8s.sh",
      "/home/ubuntu/scripts/controlplane-config.sh",
      "echo 'Setting hostname'",
      "sudo hostnamectl set-hostname control-plane",
      "echo 'All commands completed successfully'",
      "kubeadm token create --print-join-command > /home/ubuntu/join_command.sh",
      "kubectl apply -f /home/ubuntu/initial-cluster.yaml",
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("k8s-key")
      host        = aws_instance.control-plane.public_ip
    }
  }

}


resource "aws_instance" "worker-node" {
  ami                  = var.ubuntu-ami
  instance_type        = var.ubuntu-instance-type
  key_name             = aws_key_pair.k8s-key.key_name
  count                = 2
  subnet_id            = aws_subnet.public_sub2.id
  vpc_security_group_ids = [aws_security_group.cluster_security_group.id]
  
  tags = {
    Name = "worker-node-${count.index + 1}"
  }
}


resource "null_resource" "get_join_command" {
  depends_on = [aws_instance.control_plane]

  provisioner "local-exec" {
    command = <<EOT
      ssh -o StrictHostKeyChecking=no -i k8s-key ubuntu@${aws_instance.control_plane.public_ip} 'cat /home/ubuntu/join_command.sh' > join_command.txt
      EOT
  }
}

output "join_command" {
  value = file("join_command.txt")
}


resource "null_resource" "configure_worker_node" {
  count = length(aws_instance.worker-node)

  depends_on = [aws_instance.worker-node, null_resource.get_join_command]

  provisioner "file" {
    source      = "/home/amoghazy/data/DevOps/projects/Real-Time-CICD-Project/cluster-terraform/scripts"
    destination = "/home/ubuntu/"
    
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("k8s-key")
      host        = aws_instance.worker-node[count.index].public_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Starting export K8S_VERSION'",
      "export K8S_VERSION=${local.k8s_version}",
      "echo 'Setting executable permissions for scripts'",
      "chmod +x /home/ubuntu/scripts/*",
    
       "/home/ubuntu/scripts/install-containerD.sh",
      "/home/ubuntu/scripts/configure-containerD.sh",
      "/home/ubuntu/scripts/install-k8s.sh",
      "echo 'Setting hostname'",
      "sudo hostnamectl set-hostname worker-${count.index + 1}",
      "echo 'All commands completed successfully'",
      file("join_command.txt") 
    ]


    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("k8s-key")
      host        = aws_instance.worker-node[count.index].public_ip
    }
  }
}


resource "null_resource" "update_hosts" {
  depends_on = [aws_instance.control-plane, aws_instance.worker-node]

  provisioner "remote-exec" {
    inline = [
      "echo '${aws_instance.control-plane.public_ip} control-plane' | sudo tee -a /etc/hosts",
      join("\n", [for i in range(0, length(aws_instance.worker-node)) : 
        "echo '${aws_instance.worker-node[i].public_ip} worker-${i + 1}' | sudo tee -a /etc/hosts"
      ])
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("k8s-key")
      host        = aws_instance.control-plane.public_ip
    }
  }
}




