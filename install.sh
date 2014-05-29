#!/usr/bin/env bash

source /vagrant/.env

echo ">>> Starting Install Script"

# Update
sudo apt-get update

# Install MySQL without prompt
echo ">>> passowrd is $MYSQL_ROOT_PASS"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $MYSQL_ROOT_PASS"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $MYSQL_ROOT_PASS"

echo ">>> Installing Base Items"

# Install base items
sudo apt-get install -y vim tmux curl wget build-essential python-software-properties

echo ">>> Adding PPA's and Installing Server Items"

# Add repo for latest PHP
sudo add-apt-repository -y ppa:ondrej/php5

# Update Again
sudo apt-get update

# Install the Rest
sudo apt-get install -y php5 apache2 libapache2-mod-php5 php5-mysql php5-curl php5-gd php5-mcrypt php5-xdebug mysql-server

echo ">>> Configuring Server"

# xdebug Config
cat << EOF | sudo tee -a /etc/php5/mods-available/xdebug.ini
xdebug.scream=1
xdebug.cli_color=1
xdebug.show_local_vars=1
EOF

# Apache Config
sudo a2enmod rewrite
curl https://gist.github.com/fideloper/2710970/raw/vhost.sh > vhost
sudo chmod guo+x vhost
sudo mv vhost /usr/local/bin

# PHP Config
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php5/apache2/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/apache2/php.ini

sudo service apache2 restart

sudo rm -rf /var/www
sudo ln -s /vagrant /var/www

echo "create database wordpress" | sudo mysql -p$MYSQL_ROOT_PASS
