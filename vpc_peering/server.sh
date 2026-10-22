#!/bin/bash

# Update packages
apt-get update -y

# Install Apache
apt-get install -y apache2

# Start Apache
systemctl start apache2

# Enable Apache to start on boot
systemctl enable apache2

# Create a simple webpage
echo "<h1>Welcome to My Apache Server!</h1>" > /var/www/html/index.html