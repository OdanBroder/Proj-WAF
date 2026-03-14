#!/bin/bash

##############################################################################
# Clean All - Remove all containers, images, and volumes
# Use with caution!
##############################################################################

echo "⚠️  WARNING: This will delete all containers, images, and volumes!"
echo "This action cannot be undone."
echo ""
read -p "Continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Cancelled."
    exit 0
fi

echo ""
echo "Stopping containers..."
docker compose down

echo "Removing volumes..."
docker compose down -v

echo "Removing images..."
docker compose down --rmi all

echo ""
echo "Removing leftover images..."
docker rmi waf-lab-waf 2>/dev/null || true
docker rmi waf-lab-dvwa 2>/dev/null || true

echo ""
echo "✓ All cleaned up"
echo ""
echo "To start fresh:"
echo "  ./quick-start.sh"
