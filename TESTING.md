# WAF Lab - Comprehensive Testing Guide

## Overview

This guide provides detailed instructions for testing the WAF lab environment and understanding the attack scenarios.

---

## Table of Contents

1. [Setup & Prerequisites](#setup--prerequisites)
2. [SQL Injection Testing](#sql-injection-testing)
3. [XSS Testing](#xss-testing)
4. [Command Injection Testing](#command-injection-testing)
5. [LFI Testing](#lfi-testing)
6. [Brute Force Testing](#brute-force-testing)
7. [Log Analysis](#log-analysis)
8. [Advanced Testing](#advanced-testing)

---

## Setup & Prerequisites

### System Requirements
- Docker Desktop or Docker Engine
- 4GB RAM minimum
- 5GB free disk space
- curl or wget (for testing)
- bash shell (Linux/macOS) or PowerShell (Windows)

### Verify Installation
```bash
docker --version
docker compose --version
curl --version
```

### Start the Lab
```bash
# From project root
docker compose up --build

# Wait for all services (2-3 minutes)
# Expected output:
# waf-lab-mysql | ready for connections
# waf-lab-dvwa | Apache/2.4.X started
# waf-lab-waf | nginx: master process started
```

### Verify Services Are Running
```bash
docker compose ps

# Should show:
# NAME              STATUS
# waf-lab-mysql     Up
# waf-lab-dvwa      Up
# waf-lab-waf       Up (healthy)
```

### Test Basic Connectivity
```bash
curl -I http://localhost

# Expected response:
# HTTP/1.1 200 OK
```

---

## SQL Injection Testing

### Attack Surface
DVWA SQL Injection vulnerability: `/vulnerabilities/sqli/`

### Test 1: Basic OR Condition Injection
```bash
curl -i 'http://localhost/vulnerabilities/sqli/?id=' OR '1'='1&Submit=Submit'

# Expected:
# HTTP/1.1 403 Forbidden
# Message: SQL Injection - OR Operator Attack
```

### Test 2: UNION SELECT Injection
```bash
curl -i 'http://localhost/vulnerabilities/sqli/?id=1' UNION SELECT user,password FROM users--&Submit=Submit'

# Expected:
# HTTP/1.1 403 Forbidden
# Message: SQL Injection Attack Detected
```

### Test 3: Time-based Blind SQL Injection
```bash
curl -i 'http://localhost/vulnerabilities/sqli/?id=1' AND SLEEP(5)--&Submit=Submit'

# Expected (should respond immediately, not after 5 seconds):
# HTTP/1.1 403 Forbidden
# Message: SQL Injection Attack Detected
```

### Test 4: Error-based Injection
```bash
curl -i "http://localhost/vulnerabilities/sqli/?id=' UNION SELECT ExtractValue(1,CONCAT(0x7e,(SELECT user())))--&Submit=Submit"

# Expected:
# HTTP/1.1 403 Forbidden
```

### Test 5: Comment-based Injection
```bash
curl -i 'http://localhost/vulnerabilities/sqli/?id=1' OR 1=1--&Submit=Submit'

# Expected:
# HTTP/1.1 403 Forbidden
```

### Verify Legitimate Requests Pass
```bash
curl -i 'http://localhost/vulnerabilities/sqli/?id=1&Submit=Submit'

# Expected:
# HTTP/1.1 200 OK
# (DVWA page loads without filtering)
```

---

## XSS Testing

### Attack Surface
DVWA Reflected XSS: `/vulnerabilities/xss_r/`

### Test 1: Simple Script Tag Injection
```bash
curl -i "http://localhost/vulnerabilities/xss_r/?name=<script>alert('XSS')</script>"

# Expected:
# HTTP/1.1 403 Forbidden
# Message: XSS Attack - Script Tag or Event Handler Detected
```

### Test 2: Event Handler (onerror)
```bash
curl -i "http://localhost/vulnerabilities/xss_r/?name=<img src=x onerror=alert('XSS')>"

# Expected:
# HTTP/1.1 403 Forbidden
```

### Test 3: SVG-based XSS
```bash
curl -i "http://localhost/vulnerabilities/xss_r/?name=<svg onload=alert('XSS')>"

# Expected:
# HTTP/1.1 403 Forbidden
```

### Test 4: JavaScript Protocol
```bash
curl -i "http://localhost/vulnerabilities/xss_r/?name=<a href=javascript:alert('XSS')>click</a>"

# Expected:
# HTTP/1.1 403 Forbidden
```

### Test 5: URL-encoded XSS
```bash
curl -i "http://localhost/vulnerabilities/xss_r/?name=%3Cscript%3Ealert(%27XSS%27)%3C/script%3E"

# Expected:
# HTTP/1.1 403 Forbidden
```

### Test 6: Event Handler onclick
```bash
curl -i "http://localhost/vulnerabilities/xss_r/?name=<input onclick=alert('XSS')>"

# Expected:
# HTTP/1.1 403 Forbidden
```

### Verify Legitimate Requests Pass
```bash
curl -i "http://localhost/vulnerabilities/xss_r/?name=John"

# Expected:
# HTTP/1.1 200 OK
```

---

## Command Injection Testing

### Attack Surface
DVWA Command Injection: `/vulnerabilities/exec/`

### Test 1: Semicolon Command Separator
```bash
curl -i "http://localhost/vulnerabilities/exec/?ip=127.0.0.1;ls%20-la"

# Expected:
# HTTP/1.1 403 Forbidden
# Message: Command Injection Attack Detected
```

### Test 2: Pipe Operator
```bash
curl -i "http://localhost/vulnerabilities/exec/?ip=127.0.0.1%20|%20whoami"

# Expected:
# HTTP/1.1 403 Forbidden
```

### Test 3: Command Substitution with $()
```bash
curl -i "http://localhost/vulnerabilities/exec/?ip=127.0.0.1;%24(id)"

# Expected:
# HTTP/1.1 403 Forbidden
```

### Test 4: Backtick Substitution
```bash
curl -i "http://localhost/vulnerabilities/exec/?ip=127.0.0.1;%60whoami%60"

# Expected:
# HTTP/1.1 403 Forbidden
```

### Test 5: Logical AND Operator
```bash
curl -i "http://localhost/vulnerabilities/exec/?ip=127.0.0.1;%20cat%20/etc/passwd%20%26%26%20whoami"

# Expected:
# HTTP/1.1 403 Forbidden
```

### Test 6: Newline Injection
```bash
curl -i "http://localhost/vulnerabilities/exec/?ip=127.0.0.1%0Acat%20/etc/shadow"

# Expected:
# HTTP/1.1 403 Forbidden
```

### Verify Legitimate Requests Pass
```bash
curl -i "http://localhost/vulnerabilities/exec/?ip=127.0.0.1"

# Expected:
# HTTP/1.1 200 OK
# (Ping result shown)
```

---

## LFI Testing

### Attack Surface
DVWA Local File Inclusion: `/vulnerabilities/fi/?page=`

### Test 1: Basic Directory Traversal
```bash
curl -i "http://localhost/vulnerabilities/fi/?page=../../../../etc/passwd"

# Expected:
# HTTP/1.1 403 Forbidden
# Message: Local File Inclusion (LFI) Attack Detected
```

### Test 2: Null Byte Injection
```bash
curl -i "http://localhost/vulnerabilities/fi/?page=../../../../etc/passwd%00"

# Expected:
# HTTP/1.1 403 Forbidden
# Message: LFI - Null Byte Attack Detected
```

### Test 3: Deep Traversal
```bash
curl -i "http://localhost/vulnerabilities/fi/?page=../../../../../../../../../../etc/passwd"

# Expected:
# HTTP/1.1 403 Forbidden
```

### Test 4: Encoded Traversal
```bash
curl -i "http://localhost/vulnerabilities/fi/?page=%2e%2e%2f%2e%2e%2f%2e%2e%2fetc%2fpasswd"

# Expected:
# HTTP/1.1 403 Forbidden
# Message: LFI - Encoded Traversal Detected
```

### Test 5: File Protocol
```bash
curl -i "http://localhost/vulnerabilities/fi/?page=file:///etc/passwd"

# Expected:
# HTTP/1.1 403 Forbidden
```

### Test 6: Shadow File Access
```bash
curl -i "http://localhost/vulnerabilities/fi/?page=../../../../etc/shadow"

# Expected:
# HTTP/1.1 403 Forbidden
```

### Verify Legitimate Requests Pass
```bash
curl -i "http://localhost/vulnerabilities/fi/?page=file1"

# Expected:
# HTTP/1.1 200 OK
```

---

## Brute Force Testing

### Attack Surface
DVWA Brute Force: `/vulnerabilities/brute/`

### Manual Brute Force Simulation
```bash
# Simulate 15 failed login attempts
for i in {1..15}; do
  echo "[Attempt $i]"
  curl -s -i -X POST \
    -d "username=admin&password=wrong${i}&Login=Login" \
    "http://localhost/vulnerabilities/brute/" | head -1
  sleep 1
done

# Expected:
# First 10 attempts: 200 OK or 401 Unauthorized
# Attempts 11+: 429 Too Many Requests or 403 Forbidden
```

### Automated Script
```bash
./attack-scripts/brute_force.sh

# This script demonstrates progressive blocking
```

### Expected Behavior
```
[Attempt 1] 200 OK
[Attempt 2] 200 OK
[Attempt 3] 200 OK
[Attempt 4] 200 OK
[Attempt 5] 200 OK
[Attempt 6] 200 OK
[Attempt 7] 200 OK
[Attempt 8] 200 OK
[Attempt 9] 200 OK
[Attempt 10] 200 OK
[Attempt 11] 403 FORBIDDEN  ← WAF Blocks!
[Attempt 12] 403 FORBIDDEN
```

---

## Log Analysis

### View Real-time Logs
```bash
docker logs -f waf-lab-waf
```

### Check ModSecurity Audit Log
```bash
tail -f logs/audit.log
```

### Extract Specific Attack Types
```bash
# SQL Injection attempts
grep "SQL Injection" logs/audit.log | wc -l

# XSS attempts
grep "XSS" logs/audit.log | wc -l

# Command injection attempts
grep "Command Injection" logs/audit.log | wc -l
```

### View Last Blocked Request Details
```bash
tail -1 logs/audit.log | jq '.'
```

### Count Blocks by Rule ID
```bash
grep '"rule_id"' logs/audit.log | sort | uniq -c | sort -rn
```

### Extract Attack Payloads from Logs
```bash
# This shows what payloads were attempted
grep 'ARGS.*@rx' logs/audit.log | jq '.request.content' -r
```

---

## Advanced Testing

### Test WAF Bypass Attempts

#### Double Encoding
```bash
# SELECT encoded as %25%53%45%4C%45%43%54
curl -i "http://localhost/vulnerabilities/sqli/?id=%25%35%33%25%34%35%25%34%43%25%34%35%25%34%33%25%34%54"
```

#### Case Variation
```bash
# sElEcT instead of SELECT
curl -i "http://localhost/vulnerabilities/sqli/?id=1' sElEcT * FROM users--"
```

#### Unicode Encoding
```bash
# <script> as Unicode
curl -i "http://localhost/vulnerabilities/xss_r/?name=\u003cscript\u003ealert(1)\u003c/script\u003e"
```

### Test WAF Performance
```bash
# Generate 100 requests with concurrent connections
ab -n 100 -c 10 http://localhost/

# Expected:
# Requests per second: ~500-1000
# Failed requests: 0 (unless attacks are being sent)
```

### Test Response Time Impact
```bash
# Compare legitimate request response time
time curl -s http://localhost/vulnerabilities/sqli/?id=1 > /dev/null

# Expected: Minimal overhead (< 100ms difference)
```

### Test Different Content Types
```bash
# JSON payload
curl -i -H "Content-Type: application/json" \
  -X POST http://localhost/vulnerabilities/sqli/ \
  -d '{"id":"1 OR 1=1"}'

# XML payload
curl -i -H "Content-Type: application/xml" \
  -X POST http://localhost/vulnerabilities/sqli/ \
  -d '<root><id>1 OR 1=1</id></root>'
```

### Test API Endpoints
```bash
# Test HTTP methods
curl -i -X DELETE http://localhost/vulnerabilities/sqli/?id=1

# Expected: 405 Method Not Allowed or WAF rule
```

---

## Troubleshooting

### Requests Not Being Blocked
1. Check if services are running: `docker compose ps`
2. Verify WAF is healthy: `docker ps | grep waf-lab-waf`
3. Check if ModSecurity is enabled: `docker logs waf-lab-waf | grep -i modsecurity`
4. Verify rules are loaded: `docker exec waf-lab-waf cat /opt/owasp-modsecurity-crs/rules/custom_rules.conf`

### Port 80 Already in Use
```bash
# Find process using port 80
sudo lsof -i :80

# Either kill it or change docker compose port mapping
# Edit docker compose.yml: "8080:80"
```

### Services Won't Start
```bash
# Check docker compose logs
docker compose logs

# Rebuild images
docker compose down -v
docker compose up --build
```

### MySQL Connection Issues
```bash
# Check DVWA logs
docker logs waf-lab-dvwa

# Verify MySQL is ready
docker compose exec mysql mysqladmin ping -u root -proot
```

### Custom Rules Not Loading
```bash
# Verify custom rules syntax
docker exec waf-lab-waf modsec-rules-check -f /opt/owasp-modsecurity-crs/rules/custom_rules.conf
```

---

## Performance Metrics

### Expected Metrics
- WAF response time: < 50ms overhead per request
- Blocked attack detection: < 100ms
- Max concurrent connections: 1000+
- CPU usage: 5-15% at normal load
- Memory usage: 100-200MB

### Monitoring
```bash
# Real-time container stats
docker stats waf-lab-waf

# Memory usage
docker inspect -f '{{.State.Pid}}' waf-lab-waf | xargs -I {} ps aux | grep {}
```

---

## Cleanup

### Stop Services
```bash
docker compose down
```

### Remove All Data
```bash
docker compose down -v
```

### Remove Logs
```bash
rm -rf logs/*
```

---

## References

- ModSecurity Documentation: https://modsecurity.org/
- OWASP CoreRuleSet: https://coreruleset.org/
- DVWA Documentation: https://github.com/digininja/DVWA
- OWASP Top 10: https://owasp.org/Top10/

---

**Last Updated:** 2024
**Version:** 1.0
