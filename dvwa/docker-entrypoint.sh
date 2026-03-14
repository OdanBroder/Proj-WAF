#!/bin/bash
set -e

# Set default values if not provided
DB_SERVER=${DB_SERVER:-localhost}
DB_USER=${DB_USER:-dvwa}
DB_PASSWORD=${DB_PASSWORD:-dvwa123}
DB_DATABASE=${DB_DATABASE:-dvwa}

export DB_SERVER
export DB_USER
export DB_PASSWORD
export DB_DATABASE

# Run initialization scripts if they exist
if [ -d '/docker-entrypoint-initdb.d' ]; then
    echo "Running database initialization scripts..."
    /bin/bash /docker-entrypoint-initdb.d/init-db.sh
fi

# Execute the main command
exec "$@"
