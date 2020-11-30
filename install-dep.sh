#!/bin/bash
sudo apt install apache2 php php-cli libapache2-mod-php curl -y
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
sudo apt install git php-gd php-xml php-xmlrpc php-curl php-soap php-zip php-mbstring libphp-embed -y
sudo apt install build-essential bison flex xmlsec1 libxml2-utils openssl mutt wkhtmltopdf rename cups cups-bsd putty-tools smbclient -y
