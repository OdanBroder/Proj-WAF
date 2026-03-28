#!/bin/bash

##############################################################################
# WAF Lab - Quick Reference & Cheat Sheet
# One-liner commands for quick testing
##############################################################################

echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║   WAF Lab Quick Reference - Common Commands                      ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""

# Setup Commands
echo "═════════════════════════════════════════════════════════════════"
echo "SETUP"
echo "═════════════════════════════════════════════════════════════════"
echo "docker compose up --build                  # Start lab"
echo "docker compose down                        # Stop lab"
echo "docker compose ps                          # Check status"
echo ""

# Testing Commands
echo "═════════════════════════════════════════════════════════════════"
echo "QUICK ATTACKS"
echo "═════════════════════════════════════════════════════════════════"
echo "# SQL Injection"
echo 'curl "http://localhost/vulnerabilities/sqli/?id=1'"'" OR 1=1--&Submit=Submit"'
echo ""
echo "# XSS"
echo 'curl "http://localhost/vulnerabilities/xss_r/?name=<script>alert(1)</script>"'
echo ""
echo "# Command Injection"
echo 'curl "http://localhost/vulnerabilities/exec/?ip=127.0.0.1;ls%20-la"'
echo ""
echo "# LFI"
echo 'curl "http://localhost/vulnerabilities/fi/?page=../../../../etc/passwd"'
echo ""

# Logging Commands
echo "═════════════════════════════════════════════════════════════════"
echo "LOGGING & MONITORING"
echo "═════════════════════════════════════════════════════════════════"
echo "docker logs -f waf-lab-waf                 # Watch WAF logs"
echo "tail -f logs/audit.log                     # Watch audit logs"
echo "tail -50 logs/audit.log | jq .             # Pretty-print logs"
echo "grep 'SQL Injection' logs/audit.log | wc -l # Count blocks"
echo "docker stats                               # Container stats"
echo ""

# Script Commands
echo "═════════════════════════════════════════════════════════════════"
echo "AUTOMATED TESTS"
echo "═════════════════════════════════════════════════════════════════"
echo "./attack-scripts/sql_injection.sh          # Test SQL injection"
echo "./attack-scripts/xss_test.sh               # Test XSS"
echo "./attack-scripts/command_injection.sh      # Test command injection"
echo "./attack-scripts/lfi_test.sh               # Test LFI"
echo "./attack-scripts/brute_force.sh            # Test brute force"
echo "./attack-scripts/bot_detection.sh          # Test bot detection"
echo "./attack-scripts/slow_ddos.sh              # Test slow DDoS detection"
echo ""

# Analysis Commands
echo "═════════════════════════════════════════════════════════════════"
echo "ANALYSIS"
echo "═════════════════════════════════════════════════════════════════"
echo "grep '\"rule_id\"' logs/audit.log | sort | uniq -c | sort -rn"
echo "  # Top triggered rules"
echo ""
echo "docker exec waf-lab-waf curl http://dvwa"
echo "  # Test backend from WAF container"
echo ""
echo "docker logs waf-lab-mysql --tail 20"
echo "  # MySQL logs"
echo ""

# Debug Commands
echo "═════════════════════════════════════════════════════════════════"
echo "DEBUGGING"
echo "═════════════════════════════════════════════════════════════════"
echo "docker logs waf-lab-waf 2>&1 | grep -i error"
echo "  # Find WAF errors"
echo ""
echo "docker exec waf-lab-waf ps aux | grep nginx"
echo "  # Check if nginx is running"
echo ""
echo "docker exec waf-lab-mysql mysql -p root -u root -e 'SHOW DATABASES;'"
echo "  # Query database"
echo ""

# Cleanup Commands
echo "═════════════════════════════════════════════════════════════════"
echo "CLEANUP"
echo "═════════════════════════════════════════════════════════════════"
echo "./clean-all.sh                             # Remove all"
echo "rm -rf logs/*                              # Clear logs"
echo "docker system prune -a --volumes            # Full cleanup"
echo ""

# HTTP Status Codes for WAF
echo "═════════════════════════════════════════════════════════════════"
echo "EXPECTED HTTP RESPONSE CODES"
echo "═════════════════════════════════════════════════════════════════"
echo "200 OK                - Legitimate requests pass through"
echo "302 Redirect          - DVWA redirects (login, etc.)"
echo "403 Forbidden         - WAF blocks malicious request"
echo "429 Too Many Requests - Brute force rate limit triggered"
echo "400 Bad Request       - Invalid HTTP request"
echo "500 Server Error      - DVWA or backend error"
echo ""

# TCP Ports
echo "═════════════════════════════════════════════════════════════════"
echo "EXPOSED PORTS"
echo "═════════════════════════════════════════════════════════════════"
echo "80/tcp   - HTTP (WAF/Nginx)"
echo "443/tcp  - HTTPS (WAF/Nginx, self-signed cert)"
echo "3306/tcp - MySQL (if exposed)"
echo ""

# File Locations
echo "═════════════════════════════════════════════════════════════════"
echo "KEY FILES"
echo "═════════════════════════════════════════════════════════════════"
echo "docker compose.yml           - Service configuration"
echo "waf/Dockerfile               - WAF container build"
echo "waf/nginx.conf               - Nginx configuration"
echo "waf/modsecurity.conf         - ModSecurity base config"
echo "waf/rules/custom_rules.conf  - Custom detection rules"
echo "dvwa/Dockerfile              - DVWA container build"
echo "attack-scripts/              - Attack test scripts"
echo "test-payloads/               - Reference payload lists"
echo "logs/audit.log               - ModSecurity audit log"
echo ""

# Common Payloads
echo "═════════════════════════════════════════════════════════════════"
echo "QUICK PAYLOAD REFERENCE"
echo "═════════════════════════════════════════════════════════════════"
echo ""
echo "SQL INJECTION:        ' OR '1'='1"
echo "XSS:                  <script>alert(1)</script>"
echo "COMMAND INJECTION:    ; ls -la"
echo "LFI:                  ../../../../etc/passwd"
echo "BRUTE FORCE:          Multiple login attempts"
echo ""

echo "═════════════════════════════════════════════════════════════════"
echo "For detailed information, see README.md and TESTING.md"
echo "═════════════════════════════════════════════════════════════════"
