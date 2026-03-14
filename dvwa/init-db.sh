#!/bin/bash
# Database initialization script for DVWA with proper SQL syntax fixes

# Wait for MySQL to be ready
while ! mysqladmin ping -h"$DB_SERVER" -u"$DB_USER" -p"$DB_PASSWORD" --silent; do
    echo 'waiting for mysql...'
    sleep 1
done

# Create the database if it doesn't exist
mysql -h"$DB_SERVER" -u"$DB_USER" -p"$DB_PASSWORD" <<EOF
CREATE DATABASE IF NOT EXISTS dvwa;
EOF

# Run DVWA setup with fixed SQL  
cd /var/www/html

# Create a fixed setup SQL script that doesn't use the problematic "IF NOT EXISTS" syntax
mysql -h"$DB_SERVER" -u"$DB_USER" -p"$DB_PASSWORD" dvwa <<'SQL'
DROP TABLE IF EXISTS guestbook;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
    user_id int(6) NOT NULL auto_increment,
    user varchar(15) NOT NULL,
    password varchar(32) NOT NULL,
    first_name varchar(15) NOT NULL,
    last_name varchar(15) NOT NULL,
    avatar varchar(70) NOT NULL,
    last_login timestamp NULL DEFAULT NULL,
    failed_login int(3) NOT NULL DEFAULT 0,
    role VARCHAR(20) DEFAULT 'user',
    PRIMARY KEY (user_id),
    UNIQUE KEY user (user)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

INSERT INTO users VALUES 
(1,'admin','5f4dcc3b5aa765d61d8327deb882cf99','admin','admin','/hackable/users/admin.jpg','2022-10-20 04:55:34',0,'admin'),
(2,'gordonb','e0e1940a8c002bb8b52ff9e953234401','Gordon','Brown','/hackable/users/gordonb.jpg','2022-10-20 04:55:34',0,'user'),
(3,'1337','8d3533648f2c9d612c11cefc375552e7','Hack','Me','/hackable/users/1337.jpg','2022-10-20 04:55:34',0,'user'),
(4,'pablo','0d107d09f5bbe40cade3de5c71e9e9b7','Pablo','Picasso','/hackable/users/pablo.jpg','2022-10-20 04:55:34',0,'user'),
(5,'mo','5f4dcc3b5aa765d61d8327deb882cf99','Mo','Money','/hackable/users/mo.jpg','2022-10-20 04:55:34',0,'user');

CREATE TABLE guestbook (
    ID int(6) NOT NULL auto_increment,
    user_id int(6),
    name varchar(15) NOT NULL DEFAULT '',
    comments varchar(300) NOT NULL DEFAULT '',
    posttime timestamp NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (ID),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SQL

echo "DVWA database initialized successfully"
