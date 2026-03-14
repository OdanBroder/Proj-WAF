#!/bin/bash

##############################################################################
# Show Detailed WAF Attack Logs
# Displays formatted ModSecurity audit log
##############################################################################

if [ ! -f "logs/audit.log" ]; then
    echo "No audit log found. Run attacks first:"
    echo "  ./attack-scripts/sql_injection.sh"
    exit 1
fi

echo "╔═════════════════════════════════════════════════════════════════╗"
echo "║        WAF Attack Log - Recent Blocked Requests                ║"
echo "╚═════════════════════════════════════════════════════════════════╝"
echo ""

# Check if jq is available for pretty printing
if command -v jq &> /dev/null; then
    echo "[*] Last 5 blocked requests (formatted):"
    echo ""
    tail -50 logs/audit.log | jq . 2>/dev/null | head -100
else
    echo "[*] Last 20 audit log lines:"
    echo ""
    tail -20 logs/audit.log
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Statistics
echo "[*] Attack Statistics:"
echo ""

if [ -s logs/audit.log ]; then
    echo "Total events logged: $(wc -l < logs/audit.log)"
    
    if command -v jq &> /dev/null; then
        echo ""
        echo "Blocked by rule type:"
        grep '"rule_id"' logs/audit.log 2>/dev/null | sort | uniq -c | sort -rn | head -10
        
        echo ""
        echo "Attack types (top 5):"
        grep '"message"' logs/audit.log 2>/dev/null | grep -o "'[^']*'" | sort | uniq -c | sort -rn | head -5
    fi
else
    echo "No attack logs yet. Run the attack scripts:"
    echo "  ./attack-scripts/sql_injection.sh"
fi

echo ""
echo "For continuous monitoring:"
echo "  tail -f logs/audit.log"
