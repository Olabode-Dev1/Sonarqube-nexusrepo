#!/bin/bash

set -e  # Exit on any error

echo "Updating package lists..."
sudo apt update -y

echo "Installing Java..."
sudo apt install -y openjdk-11-jre-headless

echo "Downloading Nexus Repository Manager..."
wget -q https://download.sonatype.com/nexus/3/latest-unix.tar.gz -O /tmp/nexus.tar.gz

echo "Extracting Nexus files..."
sudo tar -zxvf /tmp/nexus.tar.gz -C /opt/
sudo mv /opt/nexus-* /opt/nexus

echo "Creating Nexus user..."
sudo adduser --system --no-create-home --group nexus

echo "Granting permissions to Nexus user..."
sudo chown -R nexus:nexus /opt/nexus

echo "Configuring Nexus user..."
echo 'run_as_user="nexus"' | sudo tee /opt/nexus/bin/nexus.rc

echo "Setting up Nexus as a systemd service..."
sudo bash -c 'cat <<EOL > /etc/systemd/system/nexus.service
[Unit]
Description=Nexus Repository Manager
After=network.target

[Service]
Type=forking
ExecStart=/opt/nexus/bin/nexus start
ExecStop=/opt/nexus/bin/nexus stop
User=nexus
Restart=on-abort
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOL'

echo "Enabling Nexus service..."
sudo systemctl daemon-reload
sudo systemctl enable nexus
sudo systemctl start nexus

echo "Nexus Repository Manager setup complete. Access it at: http://<server-ip>:8081"