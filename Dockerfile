FROM php:8.2-apache

RUN a2enmod rewrite && \
    printf '<VirtualHost *:80>\n\
    ServerName site1.localhost\n\
    DocumentRoot /var/www/html/site1\n\
    <Directory "/var/www/html/site1">\n\
        AllowOverride All\n\
        Require all granted\n\
    </Directory>\n\
</VirtualHost>\n\
<VirtualHost *:80>\n\
    ServerName site2.localhost\n\
    DocumentRoot /var/www/html/site2\n\
    <Directory "/var/www/html/site2">\n\
        AllowOverride All\n\
        Require all granted\n\
    </Directory>\n\
</VirtualHost>\n' > /etc/apache2/sites-available/000-default.conf