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
# sudo apt install mysql-server -y

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

# Install PHP dependencies
composer install --no-dev --prefer-source

# Apache virtual host setup (adjust domain/IP manually)
VHOST_FILE="/etc/apache2/sites-available/snipeit.conf"
sudo bash -c "cat > $VHOST_FILE" <<EOL
<VirtualHost *:80>
    ServerAdmin admin@example.com
    DocumentRoot /var/www/snipe-it/public
    ServerName your_domain_or_ip

    <Directory /var/www/snipe-it/public>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/snipeit_error.log
    CustomLog \${APACHE_LOG_DIR}/snipeit_access.log combined
</VirtualHost>
EOL

# Enable required Apache modules and site
sudo a2enmod rewrite
sudo a2ensite snipeit.conf
sudo a2dissite 000-default.conf
sudo systemctl restart apache2

echo "✅ Script execution complete. Please manually edit the .env file with your DB and app details:"
echo "   sudo nano /var/www/snipe-it/.env"
