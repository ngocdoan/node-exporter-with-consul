#!/bin/bash

# Default Consul port
DEFAULT_CONSUL_PORT="8500"

# Function to show usage
usage() {
  echo "Usage: $0 [--consul-ip <ip-address>] [--consul-port <port>]"
  exit 1
}

# Parse command line arguments
while [[ "$1" =~ ^-- ]]; do
  case "$1" in
    --consul-ip)
      CONSUL_IP="$2"
      shift 2
      ;;
    --consul-port)
      CONSUL_PORT="$2"
      shift 2
      ;;
    *)
      usage
      ;;
  esac
done

# If no consul-ip is provided via argument, ask the user for it
if [ -z "$CONSUL_IP" ]; then
  echo "Please enter the Consul server IP address (required):"
  read CONSUL_IP
  if [ -z "$CONSUL_IP" ]; then
    echo "Consul server IP address is required. Exiting..."
    exit 1
  fi
fi

# If no consul-port is provided via argument, default to 8500
if [ -z "$CONSUL_PORT" ]; then
  CONSUL_PORT=$DEFAULT_CONSUL_PORT
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
