#!/bin/bash

##############################################################################
# Local File Inclusion (LFI) Attack Test Script
# Tests LFI vulnerabilities in DVWA
# The WAF should block these requests
##############################################################################

echo "=========================================="
echo "Local File Inclusion (LFI) Attack Test"
echo "=========================================="
echo ""

TARGET="http://localhost"

echo "[*] Testing LFI payloads..."
echo ""

# Test 1: Direct file inclusion
echo "[1] Direct File Inclusion - /etc/passwd:"
echo "[*] Payload: ../../../../etc/passwd"
curl -s -i -X GET "${TARGET}/vulnerabilities/fi/?page=../../../../etc/passwd" | head -20
echo ""
echo ""

# Test 2: File inclusion with null byte
echo "[2] Null Byte Injection:"
echo "[*] Payload: ../../../../etc/passwd%00"
curl -s -i -X GET "${TARGET}/vulnerabilities/fi/?page=../../../../etc/passwd%00.html" | head -20
echo ""
echo ""

# Test 3: Multiple traversal attempts
echo "[3] Deep Directory Traversal:"
echo "[*] Payload: ../../../../../../../../../../etc/passwd"
curl -s -i -X GET "${TARGET}/vulnerabilities/fi/?page=../../../../../../../../../../etc/passwd" | head -20
echo ""
echo ""

# Test 4: Windows file inclusion
echo "[4] Windows File Inclusion (if on Windows server):"
echo "[*] Payload: ..\\..\\..\\windows\\win.ini"
curl -s -i -X GET "${TARGET}/vulnerabilities/fi/?page=..\\..\\..\\windows\\win.ini" | head -20
echo ""
echo ""

# Test 5: Encoded traversal
echo "[5] Encoded Traversal Sequence:"
echo "[*] Payload: %2e%2e%2f%2e%2e%2f%2e%2e%2fetc%2fpasswd"
curl -s -i -X GET "${TARGET}/vulnerabilities/fi/?page=%2e%2e%2f%2e%2e%2f%2e%2e%2fetc%2fpasswd" | head -20
echo ""
echo ""

# Test 6: Shadow file inclusion
echo "[6] Attempting /etc/shadow access:"
echo "[*] Payload: ../../../../etc/shadow"
curl -s -i -X GET "${TARGET}/vulnerabilities/fi/?page=../../../../etc/shadow" | head -20
echo ""
echo ""

# Test 7: Configuration files
echo "[7] Configuration File Access:"
echo "[*] Payload: ../../../../etc/apache2/apache2.conf"
curl -s -i -X GET "${TARGET}/vulnerabilities/fi/?page=../../../../etc/apache2/apache2.conf" | head -20
echo ""
echo ""

echo "[*] LFI Tests Completed"
echo "[*] Check logs at: docker logs waf-lab-waf"
echo "[*] View ModSecurity audit logs in: logs/audit.log"
