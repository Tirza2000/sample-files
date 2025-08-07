#!/bin/bash

# Update and install software-properties-common for add-apt-repository
sudo apt update -y
sudo apt install software-properties-common -y

# Add PHP repository and update
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update -y

# Install Apache, PHP 8.2 and required PHP extensions
sudo apt install -y apache2 php8.2 php8.2-cli php8.2-common php8.2-mysql php8.2-curl php8.2-mbstring php8.2-xml php8.2-bcmath php8.2-gd php8.2-zip php8.2-tokenizer unzip curl git

# Install MySQL (optional if using Cloud SQL)
///
sudo apt install mysql-server -y
sudo mysql_secure_installation 
sudo mysql -u root -p
CREATE DATABASE snipeit;
CREATE USER 'snipeuser'@'localhost' IDENTIFIED BY 'StrongPassword123';
GRANT ALL PRIVILEGES ON snipeit.* TO 'snipeuser'@'localhost';
FLUSH PRIVILEGES;
EXIT;
///


# Install Composer globally
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# Clone the Snipe-IT repository
cd /var/www/
sudo git clone https://github.com/snipe/snipe-it.git
cd snipe-it

# Set correct permissions
sudo chown -R $USER:www-data /var/www/snipe-it
sudo chmod -R 775 /var/www/snipe-it/storage

# Copy .env file and prompt manual edits later
cp .env.example .env
nano .env
#add below things
#APP_URL=http://<your-vm-external-ip>
#APP_KEY= #This will be generated later using php artisan key:generate
#DB_CONNECTION=mysql
#DB_HOST=127.0.0.1
#DB_PORT=3306
#DB_DATABASE=snipeit
#DB_USERNAME=snipeuser
#DB_PASSWORD=StrongPassword123

# Install PHP dependencies
composer install --no-dev --prefer-source #Installs all required Laravel dependencies.(in json file)

#Generate App Key
php artisan key:generate #Generates Laravel application encryption key.(which helps to app secure from Session hijack, URL tampering, Token forgery etc)

#Run database migrations
php artisan migrate #Creates all necessary tables in your MySQL DB

#Set permissions 
sudo chown -R www-data:www-data /var/www/snipe-it 
sudo chmod -R 755 /var/www/snipe-it


# Apache virtual host setup (adjust domain/IP manually)
VHOST_FILE="/etc/apache2/sites-available/snipeit.conf"
sudo bash -c "cat > $VHOST_FILE" <<EOL
<VirtualHost *:80>
    ServerAdmin admin@example.com
    DocumentRoot /var/www/snipe-it/public
    ServerName 34.134.95.220

    <Directory /var/www/snipe-it/public>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog /var/log/apache2/snipeit_error.log
    CustomLog /var/log/apache2/snipeit_access.log combined
</VirtualHost>
EOL

# Enable required Apache modules and site
sudo a2ensite snipeit.conf 
sudo a2enmod rewrite 
sudo systemctl restart apache2
sudo apache2ctl configtest # checking sysntax


#Visit http://<your-vm-ip> and complete the setup wizard.
#Finish setting up your admin account and settings.

