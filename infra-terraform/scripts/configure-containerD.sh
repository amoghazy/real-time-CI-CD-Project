#!/bin/bash

echo "Checking and updating containerd config for SystemdCgroup..."

CONFIG_FILE="/etc/containerd/config.toml"

# Ensure the config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Config file not found. Creating default config..."
    sudo mkdir -p /etc/containerd
    sudo containerd config default | sudo tee $CONFIG_FILE
fi

# Check if SystemdCgroup is set and update it to true if it's false
if grep -q 'SystemdCgroup = false' "$CONFIG_FILE"; then
    echo "SystemdCgroup is set to false. Updating it to true..."
    sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' "$CONFIG_FILE"
    echo "SystemdCgroup updated to true."
elif grep -q 'SystemdCgroup' "$CONFIG_FILE"; then
    echo "SystemdCgroup is already set to true."

    
fi

# Restart containerd to apply changes
echo "Restarting containerd..."
sudo systemctl restart containerd

# Verify containerd status
echo "Containerd status:"
sudo systemctl status containerd --no-pager
