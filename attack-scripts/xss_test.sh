#!/bin/bash

##############################################################################
# Cross-Site Scripting (XSS) Attack Test Script
# Tests XSS vulnerabilities in DVWA
# The WAF should block these requests
##############################################################################

echo "=========================================="
echo "Cross-Site Scripting (XSS) Attack Test"
echo "=========================================="
echo ""

TARGET="http://localhost"

echo "[*] Testing XSS payloads..."
echo ""

# Test 1: Basic script tag injection
echo "[1] Basic Script Tag Injection:"
echo "[*] Payload: <script>alert('XSS')</script>"
curl -s -i -X GET "${TARGET}/vulnerabilities/xss_r/?name=<script>alert('XSS')</script>" | head -20
echo ""
echo ""

# Test 2: Event handler injection (onerror)
echo "[2] Event Handler Injection (onerror):"
echo "[*] Payload: <img src=x onerror=alert('XSS')>"
curl -s -i -X GET "${TARGET}/vulnerabilities/xss_r/?name=<img src=x onerror=alert('XSS')>" | head -20
echo ""
echo ""

# Test 3: JavaScript protocol
echo "[3] JavaScript Protocol:"
echo "[*] Payload: <a href=javascript:alert('XSS')>click</a>"
curl -s -i -X GET "${TARGET}/vulnerabilities/xss_r/?name=<a href=javascript:alert('XSS')>click</a>" | head -20
echo ""
echo ""

# Test 4: onload event handler
echo "[4] Onload Event Handler:"
echo "[*] Payload: <body onload=alert('XSS')>"
curl -s -i -X GET "${TARGET}/vulnerabilities/xss_r/?name=<body onload=alert('XSS')>" | head -20
echo ""
echo ""

# Test 5: SVG-based XSS
echo "[5] SVG-based XSS:"
echo "[*] Payload: <svg onload=alert('XSS')>"
curl -s -i -X GET "${TARGET}/vulnerabilities/xss_r/?name=<svg onload=alert('XSS')>" | head -20
echo ""
echo ""

# Test 6: Encoded XSS
echo "[6] Encoded XSS payload:"
echo "[*] Payload: %3Cscript%3Ealert(%27XSS%27)%3C/script%3E"
curl -s -i -X GET "${TARGET}/vulnerabilities/xss_r/?name=%3Cscript%3Ealert(%27XSS%27)%3C/script%3E" | head -20
echo ""
echo ""

# Test 7: onclick handler
echo "[7] Onclick Event Handler:"
echo "[*] Payload: <input onclick=alert('XSS')>"
curl -s -i -X GET "${TARGET}/vulnerabilities/xss_r/?name=<input onclick=alert('XSS')>" | head -20
echo ""
echo ""

echo "[*] XSS Tests Completed"
echo "[*] Check logs at: docker logs waf-lab-waf"
echo "[*] View ModSecurity audit logs in: logs/audit.log"
