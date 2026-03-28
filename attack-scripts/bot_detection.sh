#!/bin/bash

# Fix PATH (QUAN TRỌNG)
export PATH=/usr/bin:/bin:/usr/local/bin

echo "=========================================="
echo "Bot Detection Attack Test"
echo "=========================================="

TARGET="http://localhost:8080"

# Method | Path | User-Agent
TESTS=(
    "GET|/vulnerabilities/login/|sqlmap/1.0"
    "GET|/vulnerabilities/xss_r/?name=bottest|curl/7.68.0"
    "GET|/vulnerabilities/sqli/?id=1&Submit=Submit|EMPTY"
)

echo "[*] Target: ${TARGET}"
echo ""

COUNT=1
for TEST in "${TESTS[@]}"; do
    IFS="|" read -r METHOD PATH UA <<< "$TEST"

    echo "[${COUNT}] Request: ${METHOD} ${PATH}"

    # Handle User-Agent
    if [ "$UA" == "EMPTY" ]; then
        echo "    User-Agent: (empty)"
        RESPONSE=$(curl -s -i -X "$METHOD" -H "User-Agent:" "${TARGET}${PATH}")
    else
        echo "    User-Agent: ${UA}"
        RESPONSE=$(curl -s -i -X "$METHOD" -A "$UA" "${TARGET}${PATH}")
    fi

    # Extract status code
    STATUS=$(echo "$RESPONSE" | head -n 1)

    echo "    Response status: ${STATUS}"

    # Detect block
    if echo "$STATUS" | grep -qE "403|429"; then
        echo "    [✔] Bot request BLOCKED by WAF"
    else
        echo "    [✘] Bot request NOT blocked"
    fi

    echo ""
    COUNT=$((COUNT + 1))
done