#!/bin/bash

##############################################################################
# WAF Lab Quick Start Script
# Automates Docker build and initial testing
##############################################################################

set -e

echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║         WAF (ModSecurity) Lab - Quick Start Script              ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""

# Check Docker
if ! command -v docker &> /dev/null; then
    echo "[✗] Docker is not installed. Please install Docker first."
    exit 1
fi

if ! command -v docker compose &> /dev/null; then
    echo "[✗] Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

echo "[✓] Docker and Docker Compose found"
echo ""

# Make scripts executable
echo "[*] Making scripts executable..."
chmod +x attack-scripts/*.sh
echo "[✓] Scripts are executable"
echo ""

# Check if logs directory exists
if [ ! -d "logs" ]; then
    echo "[*] Creating logs directory..."
    mkdir -p logs
fi
echo "[✓] Logs directory ready"
echo ""

# Build and start services
echo "[*] Starting Docker services (this may take 2-3 minutes)..."
echo ""
docker compose up --build -d

echo ""
echo "[*] Waiting for services to be healthy..."
sleep 5

# Check services
echo ""
echo "[*] Service Status:"
docker compose ps
echo ""

# Wait for MySQL
echo "[*] Waiting for MySQL to be ready..."
for i in {1..30}; do
    if docker compose exec -T mysql mysqladmin ping -h localhost -u root -proot &> /dev/null; then
        echo "[✓] MySQL is ready"
        break
    fi
    sleep 1
done
echo ""

# Test WAF
echo "[*] Testing WAF connectivity..."
if curl -s http://localhost > /dev/null 2>&1; then
    echo "[✓] WAF is responding"
else
    echo "[!] WAF not responding yet, services still starting..."
    sleep 5
fi
echo ""

echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║                    Lab Setup Complete!                          ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""
echo "📝 Next Steps:"
echo ""
echo "1. View DVWA Homepage:"
echo "   curl http://localhost"
echo ""
echo "2. Run Attack Tests (in a new terminal):"
echo "   ./attack-scripts/sql_injection.sh"
echo "   ./attack-scripts/xss_test.sh"
echo "   ./attack-scripts/command_injection.sh"
echo "   ./attack-scripts/lfi_test.sh"
echo "   ./attack-scripts/brute_force.sh"
echo ""
echo "3. View WAF Logs:"
echo "   docker logs -f waf-lab-waf"
echo "   tail -f logs/audit.log"
echo ""
echo "4. Stop Services:"
echo "   docker compose down"
echo ""
echo "📚 Read README.md for detailed documentation"
echo ""
