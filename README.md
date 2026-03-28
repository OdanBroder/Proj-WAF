# WAF (ModSecurity) Lab - OWASP Top 10 Protection

## 📋 Project Overview

This is a complete, reproducible Web Application Firewall (WAF) lab project demonstrating how ModSecurity protects vulnerable web applications against OWASP Top 10 attacks. The lab implements a three-tier architecture with Nginx + ModSecurity acting as a reverse proxy/WAF in front of DVWA (Damn Vulnerable Web Application).

**Architecture:**
```
Attacker Machine  →  WAF (Nginx + ModSecurity)  →  DVWA + MySQL
   (localhost)        (Port 80/443)              (Backend)
```

---

## 🔒 What This Lab Demonstrates

### Protected Attack Vectors:
- ✅ **SQL Injection** - Full protection with anomaly scoring
- ✅ **Cross-Site Scripting (XSS)** - Script tags, event handlers, encoded payloads
- ✅ **Command Injection** - Shell metacharacters, command chaining, substitution
- ✅ **Local File Inclusion (LFI)** - Directory traversal, null bytes, encoded traversal
- ✅ **Brute Force Attacks** - Failed login attempt tracking and blocking
- ✅ **Protocol Attacks** - Null bytes, suspicious characters, unsupported methods

---

## 📦 Project Structure

```
project-root/
├── docker compose.yml              # Docker services orchestration
├── README.md                        # This file
│
├── waf/                             # WAF service (Nginx + ModSecurity)
│   ├── Dockerfile                   # WAF container build
│   ├── nginx.conf                   # Nginx configuration
│   ├── modsecurity.conf             # ModSecurity main config
│   ├── crs-setup.conf               # OWASP CRS setup
│   └── rules/
│       └── custom_rules.conf        # Custom detection rules
│
├── dvwa/                            # DVWA service
│   └── Dockerfile                   # DVWA container build
│
├── attack-scripts/                  # Attack simulation scripts
│   ├── sql_injection.sh             # SQL injection tests
│   ├── xss_test.sh                  # XSS tests
│   ├── brute_force.sh               # Brute force login tests
│   ├── lfi_test.sh                  # LFI/directory traversal tests
│   └── command_injection.sh         # Command injection tests
│
├── test-payloads/                   # Reference payload files
│   ├── sql.txt                      # SQL injection payloads
│   ├── xss.txt                      # XSS payloads
│   ├── lfi.txt                      # LFI payloads
│   └── cmd.txt                      # Command injection payloads
│
└── logs/                            # ModSecurity audit logs (created at runtime)
    └── audit.log                    # WAF event log in JSON format
```

---

## 🚀 Quick Start

### Prerequisites
- Docker and Docker Compose installed
- Linux/macOS terminal or Windows PowerShell
- ~2GB RAM available
- 5-10 minutes build time

### Step 1: Clone/Setup Project
```bash
cd project-root
chmod +x attack-scripts/*.sh  # On Linux/macOS
```

### Step 2: Start the Lab
```bash
docker compose up --build
```

**Expected output:**
```
waf-lab-waf      | nginx: [notice] master process started
waf-lab-mysql    | ready for connections
waf-lab-dvwa     | Apache/2.4.48 started
```

Wait for all services to be healthy (1-2 minutes).

### Step 3: Verify DVWA Access
```bash
curl http://localhost
```
You should see the DVWA login page HTML.

---

## 🎯 Running Attack Tests

Open a new terminal in the project directory:

### SQL Injection Test
```bash
./attack-scripts/sql_injection.sh
```
**Expected:** 403 Forbidden responses (WAF blocks all payloads)

### XSS Test
```bash
./attack-scripts/xss_test.sh
```
**Expected:** 403 Forbidden responses (script tags blocked)

### Command Injection Test
```bash
./attack-scripts/command_injection.sh
```
**Expected:** 403 Forbidden responses (shell metacharacters blocked)

### LFI/Directory Traversal Test
```bash
./attack-scripts/lfi_test.sh
```
**Expected:** 403 Forbidden responses (directory traversal blocked)

### Brute Force Test
```bash
./attack-scripts/brute_force.sh
```
**Expected:** 403/429 after ~10 failed attempts (rate limiting)

### Bot Detection Test
```bash
./attack-scripts/bot_detection.sh
```
**Expected:** 403 Forbidden for known automated User-Agent signatures

### Slow DDoS Test
```bash
./attack-scripts/slow_ddos.sh
```
**Expected:** 429 Too Many Requests after repeated DVWA endpoint floods

---

## 📊 Viewing WAF Logs

### Real-time WAF Activity
```bash
docker logs -f waf-lab-waf
```

### ModSecurity Audit Log (JSON format)
```bash
tail -f logs/audit.log
```

### Pretty-print Recent Blocks
```bash
tail -100 logs/audit.log | jq . | grep -A 5 '"message"'
```

### Analytics
```bash
# Count blocked requests by type
grep '"message"' logs/audit.log | grep -o "'[^']*'" | sort | uniq -c | sort -rn

# Find all SQL injection attempts
grep "SQL Injection" logs/audit.log | wc -l

# List unique attacking IP addresses
grep '"remote_address"' logs/audit.log | sort -u
```

---

## 📝 Expected Results Example

### Blocked SQL Injection Request
```
REQUEST:
GET /vulnerabilities/sqli/?id=' OR '1'='1&Submit=Submit HTTP/1.1
Host: localhost

RESPONSE:
HTTP/1.1 403 Forbidden
ModSecurity: Access Denied
X-ModSecurity-Message: SQL Injection - OR Operator Attack

AUDIT LOG:
{
  "timestamp": "2024-01-15T10:23:45Z",
  "rule_id": 10003,
  "message": "SQL Injection - OR Operator Attack",
  "severity": "CRITICAL",
  "action": "DENY",
  "http_code": 403,
  "tags": ["OWASP_TOP_10/A03:2021-Injection"]
}
```

### Blocked XSS Request
```
REQUEST:
GET /vulnerabilities/xss_r/?name=<script>alert('XSS')</script>

RESPONSE:
HTTP/1.1 403 Forbidden
ModSecurity: Access Denied
X-ModSecurity-Message: XSS Attack - Script Tag or Event Handler Detected

AUDIT LOG:
Rule 10011 triggered: XSS Attack detected and blocked
```

---

## 🔧 WAF Configuration Details

### Key ModSecurity Features Enabled:
1. **Rule Engine:** On (strict mode)
2. **Request Body Processing:** 13MB limit
3. **Audit Logging:** JSON format, concurrent writes
4. **Anomaly Scoring:** SQL Injection, XSS, Command Injection tracking
5. **OWASP CRS v3.3.5:** Deployed and active

### Custom Rules (waf/rules/custom_rules.conf):
- **10001-10003:** SQL Injection detection (Keywords, OR operators)
- **10010-10012:** XSS detection (Script tags, event handlers, encoded)
- **10020-10021:** Command Injection (Pipes, subshells, redirects)
- **10030-10032:** LFI/Directory Traversal (../../../, null bytes)
- **10040-10042:** Brute Force tracking (Failed login counter)
- **10050-10052:** Anomaly score triggers
- **10060-10071:** Protocol attacks prevention

### Anomaly Scoring System:
```
SQL Injection Points:    ≥8 = BLOCK
XSS Points:              ≥8 = BLOCK
Command Injection:       ≥10 = BLOCK
Brute Force:             ≥10 attempts = BLOCK (429)
```

---

## 🧪 Lab Exercises

### Exercise 1: Disable WAF and See Vulnerabilities
```bash
# Comment out modsecurity line in nginx.conf
# Rebuild: docker compose up --build
./attack-scripts/sql_injection.sh
# Now requests succeed - DVWA shows SQL errors!
```

### Exercise 2: Modify WAF Rules
Edit `waf/rules/custom_rules.conf`, rebuild, test custom rule behavior.

### Exercise 3: Analyze Traffic
```bash
docker exec waf-lab-waf tcpdump -i eth0 -A "tcp port 80"
```

### Exercise 4: Bypass Attempts
Test URL encoding, case variation, encoding chains:
```bash
curl "http://localhost/?id=%25%32%65%25%32%65%2f" # ../../ encoded
```

---

## 🧹 Cleanup

### Stop Services
```bash
docker compose down
```

### Remove Volumes
```bash
docker compose down -v
```

### Remove Images
```bash
docker compose down --rmi all
```

---

## 📚 References

- **OWASP Top 10:** https://owasp.org/Top10/
- **ModSecurity:** https://modsecurity.org/
- **OWASP CRS:** https://coreruleset.org/
- **DVWA:** https://github.com/digininja/DVWA
- **NGINX:** https://nginx.org/

---

## ⚠️ Important Notes

1. **Lab Purpose Only:** This environment is vulnerable by design. Only run in isolated networks.
2. **Not for Production:** DVWA is intentionally insecure. Never deploy in production.
3. **Educational Tool:** Use for learning. All attacks are logged and visible.
4. **Legal:** Only test on systems you own or have explicit permission to test.

---

## 🛠️ Troubleshooting

### Services Won't Start
```bash
docker compose logs
# Check MySQL health: docker ps | grep mysql
```

### Permission Denied on Scripts
```bash
chmod +x attack-scripts/*.sh
```

### Port 80 Already in Use
```bash
sudo lsof -i :80
# Edit docker compose.yml, change ports: "8080:80"
curl http://localhost:8080
```

### ModSecurity Not Blocking
Check logs:
```bash
docker logs waf-lab-waf | grep -i modsecurity
cat logs/audit.log | jq '.details.action'
```

---

## 📞 Support

For issues specific to:
- **ModSecurity:** https://github.com/SpiderLabs/ModSecurity/issues
- **DVWA:** https://github.com/digininja/DVWA/issues
- **Docker:** https://docs.docker.com/

---

**Last Updated:** 2024
**Status:** Production Ready ✅
# Proj-WAF
