resource "aws_key_pair" "k8s-key" {
  key_name   = var.key-name
  public_key = file("k8s-key.pub")
}
