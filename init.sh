#!/usr/bin/env bash

if [ "$(id -u)" != "0" ]
then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Change working directory to /provision
cd /provision || exit

# Timezone
ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# Update software
add-apt-repository ppa:ondrej/php
apt-get update &> /dev/null
apt-get -yq upgrade
debconf-set-selections /provision/mysql-debconf-selections
apt-get -y install zip unzip patch curl elinks libc-client2007e libc-client2007e-dev libappindicator1 fonts-liberation \
 libasound2 libnspr4 libnss3 libxss1 xdg-utils dbus-x11 xfonts-base xfonts-100dpi xfonts-75dpi xfonts-cyrillic \
 xfonts-scalable mysql-server php7.3 php7.3-curl php7.3-imap php7.3-gd php7.3-mysql php7.3-mbstring php7.3-zip \
 php7.3-xml php7.3-bcmath php7.3-dev php7.3-intl php-pear php-xdebug libmcrypt-dev apache2

# MySQL
sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf
echo "sql_mode=" >> /etc/mysql/mysql.conf.d/mysqld.cnf
echo "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root' WITH GRANT OPTION;" | mysql -uroot -proot
echo "CREATE DATABASE automated_tests CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;" | mysql -uroot -proot
echo "GRANT ALL PRIVILEGES ON automated_tests.* TO 'automated_tests'@'%' IDENTIFIED BY 'automated_tests';" | mysql -uroot -proot
systemctl restart mysql

# Apache
sed -i '$ a ServerName localhost' /etc/apache2/apache2.conf
a2enmod rewrite
a2dissite 000-default
cp /provision/apache-suitecrm.conf /etc/apache2/sites-available/suitecrm.conf
a2ensite suitecrm
systemctl reload apache2

# PHP
pecl install mcrypt-1.0.2
echo 'extension=mcrypt.so' > /etc/php/7.3/mods-available/mcrypt.ini
phpenmod mcrypt
sed -i 's/^memory_limit = 128M$/memory_limit = 768M/g' /etc/php/7.3/apache2/php.ini
sed -i 's/^variables_order = "GPCS"$/variables_order = "EGPCS"/g' /etc/php/7.3/apache2/php.ini
sed -i 's/^upload_max_filesize = 2M$/upload_max_filesize = 50M/g' /etc/php/7.3/apache2/php.ini
sed -i 's/^;date.timezone =$/date.timezone = Africa\/Johannesburg/g' /etc/php/7.3/apache2/php.ini
sed -i 's/^;opcache.revalidate_freq=2$/opcache.revalidate_freq=0/g' /etc/php/7.3/apache2/php.ini
sed -i 's/^;date.timezone =$/date.timezone = Africa\/Johannesburg/g' /etc/php/7.3/cli/php.ini
sed -i '$ a xdebug.remote_enable = on' /etc/php/7.3/mods-available/xdebug.ini
sed -i '$ a xdebug.remote_connect_back = on' /etc/php/7.3/mods-available/xdebug.ini
sed -i '$ a xdebug.idekey = "vagrant"' /etc/php/7.3/mods-available/xdebug.ini
sed -i '$ a xdebug.max_nesting_level = 500' /etc/php/7.3/mods-available/xdebug.ini
systemctl restart apache2

# Composer
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
chmod +x /usr/local/bin/composer

# Chrome & web driver
cd ~
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
dpkg -i google-chrome-stable_current_amd64.deb
rm google-chrome-stable_current_amd64.deb
CHROME_DRIVER=$(curl https://chromedriver.storage.googleapis.com/LATEST_RELEASE)
wget https://chromedriver.storage.googleapis.com/$CHROME_DRIVER/chromedriver_linux64.zip
unzip chromedriver_linux64.zip
mkdir -p /vagrant/build/tmp
mv chromedriver /vagrant/build/tmp
chmod +x /vagrant/build/tmp/chromedriver
rm chromedriver_linux64.zip

# Setup SuiteCRM for testing
cp /provision/.bash_aliases /home/vagrant/.bash_aliases
chown vagrant:vagrant /home/vagrant/.bash_aliases
sudo -u vagrant -i
source /home/vagrant/.bash_aliases
cd /vagrant
rm -f /vagrant/config.php
cp /provision/test-env.custom.yml /vagrant/tests/_envs/custom.yml
composer install
cp /provision/suitecrm-config_si.php /vagrant/config_si.php
cp /provision/suitecrm-install_cli.php /vagrant/install_cli.php
php install_cli.php
mysql -uroot -proot -D automated_tests -v -e "source tests/_data/api_data.sql"
mysql -uroot -proot -D automated_tests -v -e "source tests/_data/api_data.sql"
