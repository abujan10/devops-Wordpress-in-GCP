#!/bin/bash
sudo apt update -y
sudo apt install apache2 php php-mysql -y
sudo systemctl start apache2
sudo systemctl enable apache2
cd /tmp
sudo wget https://wordpress.org/wordpress-4.8.14.tar.gz
sudo tar -xvzf wordpress-4.8.14.tar.gz
sudo mv wordpress/* /var/www/html/
sudo rm -rf /var/www/html/index.html
