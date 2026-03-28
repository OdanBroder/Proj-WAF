#!/bin/bash

##############################################################################
# SQL Injection Attack Test Script
# Tests SQL Injection vulnerabilities in DVWA
# The WAF should block these requests
##############################################################################

echo "=========================================="
echo "SQL Injection Attack Test"
echo "=========================================="
echo ""

TARGET="http://localhost:8080"

echo "[*] Testing basic SQL Injection payload..."
echo "[*] Payload: ' OR '1'='1"
echo ""

# Test 1: Basic OR injection
echo "[1] Basic OR 1=1 injection:"
curl -s -i -X GET "${TARGET}/vulnerabilities/sqli/?id=' OR '1'='1&Submit=Submit" | head -20
echo ""
echo ""

# Test 2: UNION SELECT injection
echo "[2] UNION SELECT injection:"
curl -s -i -X GET "${TARGET}/vulnerabilities/sqli/?id=1' UNION SELECT user,password FROM users--&Submit=Submit" | head -20
echo ""
echo ""

# Test 3: Blind SQL Injection
echo "[3] Blind SQL Injection - Time-based:"
curl -s -i -X GET "${TARGET}/vulnerabilities/sqli/?id=1' AND SLEEP(5)--&Submit=Submit" | head -20
echo ""
echo ""

# Test 4: Error-based injection
echo "[4] Error-based SQL Injection:"
curl -s -i -X GET "${TARGET}/vulnerabilities/sqli/?id=' UNION SELECT ExtractValue(1,CONCAT(0x7e,(SELECT user())))--&Submit=Submit" | head -20
echo ""
echo ""

# Test 5: Comment-based injection
echo "[5] Comment-based SQL Injection:"
curl -s -i -X GET "${TARGET}/vulnerabilities/sqli/?id=1' OR 1=1--&Submit=Submit" | head -20
echo ""
echo ""

echo "[*] SQL Injection Tests Completed"
echo "[*] Check logs at: docker logs waf-lab-waf"
echo "[*] View ModSecurity audit logs in: logs/audit.log"
