#!/bin/bash

# Prompt the user for the Consul IP address
echo "Please enter the Consul server IP address (default: 192.168.135.249):"
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

# Send the request to deregister the service from Consul
response=$(curl -s -o /dev/null -w "%{http_code}" -X PUT "$CONSUL_SERVER/v1/agent/service/deregister/$HOSTNAME")

# Check the HTTP status code returned
if [ "$response" -eq 200 ]; then
  echo "The service with ID $HOSTNAME has been successfully deregistered from Consul."
else
  echo "Failed to deregister the service with ID $HOSTNAME from Consul. Error code: $response"
fi
