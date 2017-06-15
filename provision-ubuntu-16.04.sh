#!/usr/bin/env bash

# Intended for Ubuntu 16.04 (Xenial)

export DEBIAN_FRONTEND=noninteractive


# Update Ubuntu
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
apt-get install -y php libapache2-mod-php php-mcrypt php-mysql php-cli


# Overwrite dir.conf 
# tell apache to look at php files first
cat > /etc/apache2/mods-enabled/dir.conf << EOM
<IfModule mod_dir.c>
    DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm
</IfModule>
EOM

sudo systemctl restart apache2