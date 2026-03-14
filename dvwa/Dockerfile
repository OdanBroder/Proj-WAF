FROM php:7.4-apache
ENV DEFAULT_SECURITY_LEVEL=low
ENV RECAPTCHA_PUBLIC_KEY=6LcExamplePublicKey123456
ENV RECAPTCHA_PRIVATE_KEY=6LcExamplePrivateKey123456
# Install required PHP extensions and dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    default-mysql-client \
    iputils-ping \
    git \
    wget \
    zip \
    unzip \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev && \
    docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install mysqli pdo pdo_mysql gd && \
    a2enmod rewrite

# Download and install DVWA
WORKDIR /var/www/html
RUN git clone https://github.com/digininja/DVWA.git . && \
    cp config/config.inc.php.dist config/config.inc.php

# Copy the database initialization script and entrypoint
COPY init-db.sh /docker-entrypoint-initdb.d/
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /docker-entrypoint-initdb.d/init-db.sh && \
    chmod +x /usr/local/bin/docker-entrypoint.sh

# Set up file permissions
RUN chmod -R 755 /var/www/html && \
    chown -R www-data:www-data /var/www/html && \
    chmod 777 /var/www/html/hackable/uploads

# Configure DVWA for MySQL
RUN sed -i "s/\$_DVWA\['db_server'\] = '.*';/\$_DVWA['db_server'] = 'mysql';/" config/config.inc.php && \
    sed -i "s/\$_DVWA\['db_user'\] = '.*';/\$_DVWA['db_user'] = 'dvwa';/" config/config.inc.php && \
    sed -i "s/\$_DVWA\['db_password'\] = '.*';/\$_DVWA['db_password'] = 'dvwa123';/" config/config.inc.php && \
    sed -i "s/\$_DVWA\['db_database'\] = '.*';/\$_DVWA['db_database'] = 'dvwa';/" config/config.inc.php

# Set up Apache configuration
RUN echo '<Directory /var/www/html>' >> /etc/apache2/apache2.conf && \
    echo '    AllowOverride All' >> /etc/apache2/apache2.conf && \
    echo '    Options Indexes FollowSymLinks' >> /etc/apache2/apache2.conf && \
    echo '    Require all granted' >> /etc/apache2/apache2.conf && \
    echo '</Directory>' >> /etc/apache2/apache2.conf

EXPOSE 80

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["apache2-foreground"]
