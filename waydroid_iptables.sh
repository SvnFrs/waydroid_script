#!/bin/bash

# Check if script is run with sudo/root privileges
if [ "$(id -u)" -ne 0 ]; then
   echo "This script must be run as root. Please use sudo."
   exit 1
fi

echo "Setting up iptables rules for Waydroid..."

# Allow DNS traffic
echo "Allowing DNS traffic (port 53)..."
iptables -A INPUT -p udp --dport 53 -j ACCEPT
iptables -A INPUT -p tcp --dport 53 -j ACCEPT

# Allow DHCP traffic
echo "Allowing DHCP traffic (port 67)..."
iptables -A INPUT -p udp --dport 67 -j ACCEPT

# Enable packet forwarding in iptables
echo "Setting default FORWARD policy to ACCEPT..."
iptables -P FORWARD ACCEPT

# Allow all traffic on the waydroid0 interface
echo "Adding waydroid0 interface to trusted rules..."
iptables -A INPUT -i waydroid0 -j ACCEPT 2>/dev/null || echo "Warning: waydroid0 interface not found. Rules will apply when interface is created."
iptables -A OUTPUT -o waydroid0 -j ACCEPT 2>/dev/null
iptables -A FORWARD -i waydroid0 -j ACCEPT 2>/dev/null
iptables -A FORWARD -o waydroid0 -j ACCEPT 2>/dev/null

# Enable IP forwarding in kernel
echo "Enabling IP forwarding in kernel..."
echo 1 > /proc/sys/net/ipv4/ip_forward
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p

echo "Waydroid iptables configuration complete!"
