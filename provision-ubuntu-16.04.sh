#!/usr/bin/env bash

# Intended for Ubuntu 16.04 (Xenial)

export DEBIAN_FRONTEND=noninteractive


# Update Ubuntu
add-apt-repository main
add-apt-repository universe
add-apt-repository restricted
add-apt-repository multiverse
apt-get update

# Adjust timezone to be ...
ln -sf /usr/share/zoneinfo/Europe/Rome /etc/localtime

# Apache
echo "----- Provision: Installing apache..."
apt-get install -y apache2 apache2-utils
echo "ServerName localhost" > "/etc/apache2/conf-available/fqdn.conf"
a2enconf fqdn
a2enmod rewrite
a2dissite 000-default.conf

echo "----- Provision: Setup /var/www to point to /vagrant ..."
rm -rf /var/www
ln -fs /vagrant /var/www

# Apache / Virtual Host Setup
echo "----- Provision: Install Host File..."
cp /vagrant/vhostfile /etc/apache2/sites-available/project.conf
a2ensite project.conf

# Cleanup
apt-get -y autoremove

# Restart Apache
echo "----- Provision: Restarting Apache..."
#service apache2 restart
systemctl restart apache2


# Install Mysql
echo "----- Provision: Installing Mysql ..."
 MYSQL_ROOT_PASSWORD='123'

 debconf-set-selections <<< "mysql-server mysql-server/root_password password $MYSQL_ROOT_PASSWORD"
 debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $MYSQL_ROOT_PASSWORD"

apt-get install -y mysql-server-5.7


# TODO mysql_secure_installation


# Install php and modules
echo "----- Provision: Installing PHP ..."
sudo apt-get install ppa-purge
sudo apt-get purge php-common php

apt-get install -y php php-common libapache2-mod-php php-mcrypt php-mysql php-cli

# Install php mdules for magento2
apt-get install -y php-mcrypt php-curl php-gd libcurl3 php-intl php-xsl php-zip


# Install phpmyadin (development environment only!)
#apt-get install -y phpmyadmin

# Install php and modules
echo "----- Provision: Configuring PHP ..."
phpenmod mcrypt


a2enmod php7.0
systemctl restart apache2


# magentp2 permissions
echo "----- Provision: set Magento 2 Permissions ..."
chmod -R ug+w /vagrant/html/app/etc
chmod -R ug+w /vagrant/html/var
chmod -R ug+w /vagrant/html/pub/media
chmod -R ug+w /vagrant/html/pub/static
chmod ug+x /vagrant/html/bin/magento





# Overwrite dir.conf tell apache to look at php files first
echo "----- Provision: Configure Apache..."
cat > /etc/apache2/mods-enabled/dir.conf << EOM
<IfModule mod_dir.c>
    DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm
</IfModule>
EOM



# Set permissions
#chgrp -R www-data /vagrant/html/
#chmod -R g+w /vagrant/html/


# Restart Apache
echo "----- Provision: Restarting Apache..."
#service apache2 restart
systemctl restart apache2


# show the IP
echo "----- IP: "
hostname -I



# set cron tab 
#sudo crontab -u www-data -e

# * * * * * /usr/bin/php /vargrant/html/bin/magento cron:run | grep -v "Ran jobs by schedule" >> /vargrant/html/var/log/magento.cron.log
#* * * * * /usr/bin/php /vargrant/html/update/cron.php >> /vargrant/html/var/log/update.cron.log
#* * * * * /usr/bin/php /vargrant/html/bin/magento setup:cron:run >> /vargrant/html/var/log/setup.cron.log