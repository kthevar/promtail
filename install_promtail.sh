#!/bin/bash

# Replace these paths and configuration options as needed

PROMTAIL_INSTALL_DIR="/opt/promtail"
PROMTAIL_EXECUTABLE="promtail-linux-amd64"
PROMTAIL_CONFIG="promtail-local-config.yaml"
PROMTAIL_USER="promtail"
PROMTAIL_GROUP="promtail"
PROMTAIL_LOG_DIR="/var/log/promtail" # Adjust as needed

# Download and install Promtail
mkdir $PROMTAIL_INSTALL_DIR
cd $PROMTAIL_INSTALL_DIR
curl -O -L "https://github.com/grafana/loki/releases/download/v2.8.4/promtail-linux-amd64.zip"
unzip "promtail-linux-amd64.zip"
chmod a+x "promtail-linux-amd64"

# Download Promtail configuration file
wget https://raw.githubusercontent.com/grafana/loki/main/clients/cmd/promtail/$PROMTAIL_CONFIG

# Create the Promtail systemd service file
sudo tee /etc/systemd/system/promtail.service > /dev/null << EOF
[Unit]
Description=Promtail Service
After=network.target

[Service]
User=$PROMTAIL_USER
Group=$PROMTAIL_GROUP
Type=simple
ExecStart=$PROMTAIL_INSTALL_DIR/$PROMTAIL_EXECUTABLE -config.file=$PROMTAIL_INSTALL_DIR/$PROMTAIL_CONFIG
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Create the Promtail user and group
sudo groupadd $PROMTAIL_GROUP
sudo useradd -r -M -s /bin/false -g $PROMTAIL_GROUP $PROMTAIL_USER

# Set permissions
sudo mkdir -p $PROMTAIL_LOG_DIR
sudo chown -R $PROMTAIL_USER:$PROMTAIL_GROUP $PROMTAIL_LOG_DIR

# Enable and start the Promtail service
sudo systemctl enable promtail
sudo systemctl start promtail

# Display service status
sudo systemctl status promtail
