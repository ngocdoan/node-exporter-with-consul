#!/usr/bin/env bash
echo -e "\e[1m\e[32m2. Installing node-exporter... \e[0m" && sleep 1
# install node-exporter
wget https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz
tar xvfz node_exporter-*.*-amd64.tar.gz
sudo mv node_exporter-*.*-amd64/node_exporter /usr/local/bin/
rm node_exporter-* -rf

sudo useradd -rs /bin/false node_exporter

sudo tee <<EOF >/dev/null /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl start node_exporter

echo -e "\e[1m\e[32mInstallation finished... \e[0m" && sleep 1
echo -e "\e[1m\e[32mPlease make sure ports 9100 is open \e[0m" && sleep 1
#####################################################################

# Prompt the user for the Consul server address

# Prompt the user for the Consul server IP address (default port 8500)
echo "Please enter the Consul server IP address (example: 192.168.1.200):"
read CONSUL_IP

# Check if the user entered a value for the Consul server
if [ -z "$CONSUL_IP" ]; then
  echo "Consul server address is required. Exiting..."
  exit 1
fi

# Prompt the user for the Consul server port (default to 8500 if empty)
echo "Please enter the Consul server port (default: 8500):"
read CONSUL_PORT

# If the user didn't enter a port, default to 8500
if [ -z "$CONSUL_PORT" ]; then
  CONSUL_PORT="8500"
fi

# Combine IP and port to form the Consul server URL
CONSUL_SERVER="http://$CONSUL_IP:$CONSUL_PORT"

# Get the hostname of the machine
HOSTNAME=$(hostname)

# Get the local IP address of the machine
IP_ADDRESS=$(hostname -I | awk '{print $1}')

# Create the payload for the Consul service registration API
curl -X PUT -d "{
  \"ID\": \"$HOSTNAME\",
  \"Name\": \"node-exporter\",
  \"Tags\": [\"metrics\", \"prometheus\"],
  \"Address\": \"$IP_ADDRESS\",
  \"Port\": 9100,
  \"Check\": {
    \"HTTP\": \"http://$IP_ADDRESS:9100/metrics\",
    \"Interval\": \"10s\"
  }
}" "$CONSUL_SERVER/v1/agent/service/register"

# Print success message
echo "Successfully registered node-exporter with ID: $HOSTNAME and IP address: $IP_ADDRESS to Consul at $CONSUL_SERVER"
