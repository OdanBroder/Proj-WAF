#!/bin/bash

##############################################################################
# Brute Force Attack Test Script
# Tests brute force login vulnerabilities
# The WAF should detect and block after multiple failed attempts
##############################################################################

echo "=========================================="
echo "Brute Force Attack Test"
echo "=========================================="
echo ""

TARGET="http://localhost:8080:8080"
USERNAME="admin"
ATTEMPT_COUNT=15

echo "[*] Simulating brute force login attempts..."
echo "[*] Target: ${TARGET}/vulnerabilities/brute/"
echo "[*] Username: ${USERNAME}"
echo "[*] Number of attempts: ${ATTEMPT_COUNT}"
echo ""

# Common passwords to try
PASSWORDS=(
    "password"
    "123456"
    "admin"
    "admin123"
    "password123"
    "11111111"
    "abc123"
    "123123"
    "000000"
    "654321"
    "111111"
    "welcome"
    "letmein"
    "sunshine"
    "qwerty"
)

for ((i=0; i<ATTEMPT_COUNT; i++)); do
    PASSWORD=${PASSWORDS[$((i % ${#PASSWORDS[@]}))]}
    echo "[${i}] Attempt $((i+1))/${ATTEMPT_COUNT} - Testing password: ${PASSWORD}"
    
    RESPONSE=$(curl -s -i -X POST \
        -d "username=${USERNAME}&password=${PASSWORD}&Login=Login&user_token=" \
        "${TARGET}/vulnerabilities/brute/")
    
    # Extract status code
    STATUS=$(echo "${RESPONSE}" | head -1)
    echo "    Response: ${STATUS}"
    
    # Check if blocked
    if echo "${RESPONSE}" | grep -q "429\|403\|Forbidden"; then
        echo "    [!] REQUEST BLOCKED by WAF!"
        break
    fi
    
    # Small delay between attempts
    sleep 1
done

echo ""
echo "[*] Brute Force Tests Completed"
echo "[*] Check logs at: docker logs waf-lab-waf"
echo "[*] View ModSecurity audit logs in: logs/audit.log"
