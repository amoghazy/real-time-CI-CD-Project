resource "aws_security_group" "cluster_security_group" {
  name        = var.security-group-name
  description = "Allow specific inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "app-sg"
  }
}

  resource "aws_vpc_security_group_egress_rule" "allow_all_traffic" {
  
  cidr_ipv4 = "0.0.0.0/0"
  security_group_id = aws_security_group.cluster_security_group.id
  ip_protocol = "-1"
}

# # 9000 
# resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
#   security_group_id = aws_security_group.cluster_security_group.id
#   cidr_ipv4         = "0.0.0.0/0"
#   from_port         = 9000
#   to_port           = 9000
#   ip_protocol       = "tcp"
# }
# 22 (SSH)
resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.cluster_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

# 25 (SMTP)
resource "aws_vpc_security_group_ingress_rule" "allow_smtp" {
  security_group_id = aws_security_group.cluster_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 25
  to_port           = 25
  ip_protocol       = "tcp"
}

# 80 (HTTP)
resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.cluster_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

# 433 (HTTPS)
resource "aws_vpc_security_group_ingress_rule" "allow_https" {
  security_group_id = aws_security_group.cluster_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

# 456
resource "aws_vpc_security_group_ingress_rule" "allow_456" {
  security_group_id = aws_security_group.cluster_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 456
  to_port           = 456
  ip_protocol       = "tcp"
}

# 443 (Kubernetes API server)
resource "aws_vpc_security_group_ingress_rule" "allow_6443" {
  security_group_id = aws_security_group.cluster_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 6443
  to_port           = 6443
  ip_protocol       = "tcp"
}

#  3000-10000 (any application)
resource "aws_vpc_security_group_ingress_rule" "allow_3000_10000" {
  security_group_id = aws_security_group.cluster_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 3000
  to_port           = 10000
  ip_protocol       = "tcp"
}

#  30000-32767 (Kubernetes NodePort)
resource "aws_vpc_security_group_ingress_rule" "allow_nodeport" {
  security_group_id = aws_security_group.cluster_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 30000
  to_port           = 32767
  ip_protocol       = "tcp"
}
