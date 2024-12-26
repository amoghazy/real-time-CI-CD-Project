#!/bin/bash

PUBLIC_IP_ACCESS="true"
POD_CIDR="192.168.0.0/16"


if ! systemctl status containerd &>/dev/null; then
    echo "containerd is not installed or not active. Installing containerd..."
    sudo apt-get update
    sudo apt-get install -y containerd
    sudo systemctl enable --now containerd
else
    echo "containerd is already installed and active."
fi

# Pull required images for kubeadm
sudo kubeadm config images pull --cri-socket=unix:///run/containerd/containerd.sock

# Initialize kubeadm based on PUBLIC_IP_ACCESS
if [[ "$PUBLIC_IP_ACCESS" == "false" ]]; then
    MASTER_PRIVATE_IP=$(hostname -I | awk '{print $1}')
    sudo kubeadm init --cri-socket=unix:///run/containerd/containerd.sock \
        --apiserver-advertise-address="$MASTER_PRIVATE_IP" \
        --apiserver-cert-extra-sans="$MASTER_PRIVATE_IP" \
        --pod-network-cidr="$POD_CIDR" \
        --node-name="control-plane" \
        --ignore-preflight-errors=Swap

elif [[ "$PUBLIC_IP_ACCESS" == "true" ]]; then
    MASTER_PUBLIC_IP=$(curl -s ifconfig.me)
    sudo kubeadm init --cri-socket=unix:///run/containerd/containerd.sock \
        --control-plane-endpoint="$MASTER_PUBLIC_IP" \
        --apiserver-cert-extra-sans="$MASTER_PUBLIC_IP" \
        --pod-network-cidr="$POD_CIDR" \
        --node-name="control-plane" \
        --ignore-preflight-errors=Swap

else
    echo "Error: MASTER_PUBLIC_IP has an invalid value: $PUBLIC_IP_ACCESS"
    exit 1
fi

# Configure kubeconfig
mkdir -p "$HOME"/.kube
sudo cp -i /etc/kubernetes/admin.conf "$HOME"/.kube/config
sudo chown "$(id -u)":"$(id -g)" "$HOME"/.kube/config

# Install Calico Network Plugin
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
