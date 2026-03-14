#!/bin/bash

##############################################################################
# Command Injection Attack Test Script
# Tests command injection vulnerabilities
# The WAF should block these requests
##############################################################################

echo "=========================================="
echo "Command Injection Attack Test"
echo "=========================================="
echo ""

TARGET="http://localhost"

echo "[*] Testing command injection payloads..."
echo ""

# Test 1: Basic command injection with semicolon
echo "[1] Basic Command Injection (semicolon):"
echo "[*] Payload: 127.0.0.1; ls -la"
curl -s -i -X GET "${TARGET}/vulnerabilities/exec/?ip=127.0.0.1;ls%20-la" | head -25
echo ""
echo ""

# Test 2: Command injection with pipe
echo "[2] Command Injection (pipe):"
echo "[*] Payload: 127.0.0.1 | whoami"
curl -s -i -X GET "${TARGET}/vulnerabilities/exec/?ip=127.0.0.1%20|%20whoami" | head -25
echo ""
echo ""

# Test 3: Command injection with command substitution
echo "[3] Command Substitution with \$():"
echo "[*] Payload: 127.0.0.1; \$(cat /etc/passwd)"
curl -s -i -X GET "${TARGET}/vulnerabilities/exec/?ip=127.0.0.1;%24(cat%20/etc/passwd)" | head -25
echo ""
echo ""

# Test 4: Command injection with backticks
echo "[4] Command Injection with Backticks:"
echo "[*] Payload: 127.0.0.1; \`id\`"
curl -s -i -X GET "${TARGET}/vulnerabilities/exec/?ip=127.0.0.1;%60id%60" | head -25
echo ""
echo ""

# Test 5: Chained commands
echo "[5] Command Injection - Chained Commands:"
echo "[*] Payload: 127.0.0.1; cat /etc/passwd && whoami"
curl -s -i -X GET "${TARGET}/vulnerabilities/exec/?ip=127.0.0.1;%20cat%20/etc/passwd%20%26%26%20whoami" | head -25
echo ""
echo ""

# Test 6: Command injection with OR operator
echo "[6] Command Injection - OR Operator:"
echo "[*] Payload: 127.0.0.1; id || whoami"
curl -s -i -X GET "${TARGET}/vulnerabilities/exec/?ip=127.0.0.1;%20id%20||%20whoami" | head -25
echo ""
echo ""

# Test 7: Command injection attempting reverse shell
echo "[7] Command Injection - Reverse Shell Attempt:"
echo "[*] Payload: 127.0.0.1; bash -i"
curl -s -i -X GET "${TARGET}/vulnerabilities/exec/?ip=127.0.0.1;%20bash%20-i" | head -25
echo ""
echo ""

# Test 8: New line command injection
echo "[8] Command Injection - Newline:"
echo "[*] Payload: 127.0.0.1%0Acat%20/etc/shadow"
curl -s -i -X GET "${TARGET}/vulnerabilities/exec/?ip=127.0.0.1%0Acat%20/etc/shadow" | head -25
echo ""
echo ""

echo "[*] Command Injection Tests Completed"
echo "[*] Check logs at: docker logs waf-lab-waf"
echo "[*] View ModSecurity audit logs in: logs/audit.log"
