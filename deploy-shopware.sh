#!/bin/bash

# Überprüfen, ob das Skript mit Root-Rechten ausgeführt wird
if [ "$EUID" -ne 0 ]; then
  echo "Dieses Skript muss mit Root-Rechten ausgeführt werden."
  exit 1
fi

# Aktualisiere das System
echo "Aktualisieren des Systems"
apt update
apt upgrade -y

# Installiere Apache2
echo "Installieren von Apache2"
apt install -y apache2

# Installiere MariaDB und konfiguriere root-Passwort
echo "Installieren von MariaDB und Konfigurieren des root-Passworts"
apt install -y mariadb-server
mysql_secure_installation

# Installiere PHP und erforderliche Erweiterungen
echo "Installieren von PHP und erforderlichen Erweiterungen"
apt install -y php php-cli php-fpm php-json php-common php-mysql php-zip php-gd php-mbstring php-curl php-xml php-pear php-bcmath php-json php-iconv php-intl 

# Starte und aktiviere Apache2 und PHP-FPM
echo "Starten und Aktivieren von Apache2 und PHP-FPM"
systemctl start apache2
systemctl enable apache2
systemctl start php7.4-fpm
systemctl enable php7.4-fpm

# Erstelle ein Datenbankbenutzer für Shopware
echo "Erstellen eines Datenbankbenutzers für Shopware"
mysql -u root -p <<MYSQL_SCRIPT
CREATE DATABASE shopware;
CREATE USER 'shopware'@'localhost' IDENTIFIED BY 'shopware';
GRANT ALL PRIVILEGES ON shopware.* TO 'shopware'@'localhost';
FLUSH PRIVILEGES;
exit
MYSQL_SCRIPT

# Lade Shopware herunter und installiere es
echo "Herunterladen und Installieren von Shopware"
cd /var/www/html
wget https://github.com/shopware/web-recovery/releases/latest/download/shopware-installer.phar.php
mkdir shopware
mv shopware-* /var/www/html/shopware
chown -R www-data:www-data /var/www/html/shopware

# Konfiguriere Apache2 für Shopware
echo "Konfigurieren von Apache2 für Shopware"
cat <<EOF > /etc/apache2/sites-available/shopware.conf
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html/shopware/
    ServerName CS-TestInstanz

    <Directory /var/www/html/shopware/>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

# Aktiviere die Shopware-Konfiguration und Apache2-Module
a2ensite shopware.conf
a2enmod rewrite

#Aktiviere benötigte PHP Extensions

phpenmod mbstring
phpenmod gd
phpenmod mysqli
phpenmod pdo_mysql
phpenmod curl
phpenmod fileinfo
phpenmod opcache
phpenmod xsl
phpenmod zip
phpenmod pdo
phpenmod xmlreader
phpenmod xmlwriter
phpenmod calendar
phpenmod simplexml

# Starte Apache2 neu
systemctl restart apache2

echo "Die Installation von Shopware ist abgeschlossen. Öffnen Sie Ihre Website, um den Installationsprozess abzuschließen."


echo "DONT FORGET TO CHANGE PATH OF DOCUMENT ROOT AFTER INSTALLATION"
