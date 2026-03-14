# WAF Lab - Complete File Manifest

## 📋 Master File List & Descriptions

### Root Directory Files

#### 📄 Documentation Files
- **INDEX.md** (This is your starting point!)
  - Complete project guide with learning paths
  - Covers structure, concepts, and usage
  - ⏱️ Read time: 10-15 minutes
  - 🎯 Best for: First-time understanding of the project

- **README.md**
  - Quick start guide and architecture overview
  - How to run the lab in 4 steps
  - Expected results and examples
  - ⏱️ Read time: 5 minutes
  - 🎯 Best for: Getting started immediately

- **TESTING.md**
  - Detailed testing procedures for each attack
  - Troubleshooting guide
  - Advanced testing techniques
  - ⏱️ Read time: 30 minutes
  - 🎯 Best for: Hands-on learning and testing

- **WINDOWS-SETUP.md**
  - Windows-specific installation steps
  - PowerShell commands and troubleshooting
  - Docker Desktop configuration for Windows
  - ⏱️ Read time: 10 minutes
  - 🎯 Best for: Windows users (replaces standard setup steps)

- **DEPLOYMENT.md**
  - Production deployment considerations
  - Security hardening options
  - Backup and recovery procedures
  - Monitoring and logging setup
  - ⏱️ Read time: 15 minutes
  - 🎯 Best for: Advanced users and system administrators

#### 🛠️ Utility Scripts (Bash/Shell)

- **quick-start.sh**
  - Automated setup script
  - Checks prerequisites
  - Makes scripts executable
  - Starts Docker services
  - 🚀 Usage: `bash quick-start.sh`

- **view-logs.sh**
  - Display formatted ModSecurity logs
  - Show attack statistics
  - Count blocked requests by type
  - 🚀 Usage: `bash view-logs.sh`

- **clean-all.sh**
  - Remove all containers, images, volumes
  - Clean up logs
  - Safe full reset
  - ⚠️ Warning: Cannot be undone
  - 🚀 Usage: `bash clean-all.sh`

- **QUICK-REFERENCE.sh**
  - Cheat sheet of all common commands
  - Quick attack examples
  - Logging commands
  - HTTP status codes
  - 🚀 Usage: `bash QUICK-REFERENCE.sh` (for display)

#### ⚙️ Docker Configuration

- **docker compose.yml**
  - Orchestration file for 3 services:
    - **MySQL:** Database backend
    - **DVWA:** Vulnerable web app
    - **WAF:** Nginx + ModSecurity
  - Network configuration
  - Volume mounting
  - Health checks
  - 🔧 Role: Core infrastructure file

#### 📂 .gitignore
- Version control ignore patterns
- Excludes: logs/, *.swp, __pycache__/, etc.

---

### `/waf/` Directory - WAF Configuration & Build

#### 🐳 Docker Build
- **Dockerfile**
  - Base image: `owasp/modsecurity:latest-nginx-alpine`
  - Pulls OWASP Core Rule Set v3.3.5
  - Installs tools and dependencies
  - Sets up file permissions
  - 🎯 Result: Container with Nginx + ModSecurity ready

#### 🔧 Configuration Files

- **nginx.conf**
  - Nginx server configuration
  - Reverse proxy to DVWA backend
  - Request/response headers
  - Client body size limits
  - 📊 Lines: ~60
  - 🔑 Key section: `upstream backend`, `location /`

- **modsecurity.conf**
  - ModSecurity engine configuration
  - Rule engine initialization
  - Request/response body handling
  - Audit logging (JSON format)
  - Anomaly scoring setup
  - 📊 Lines: ~50
  - 🔑 Key features: Enabled, concurrent logging, debug mode

- **crs-setup.conf**
  - OWASP Core Rule Set initialization
  - Paranoia level configuration
  - Anomaly mode setup
  - Anomaly thresholds (inbound: 5, outbound: 4)
  - 📊 Lines: ~40

#### 📋 Detection Rules

- **rules/custom_rules.conf** ⭐ (MAIN DETECTION FILE)
  - 30+ custom ModSecurity rules
  - Organized by attack type:
    - 10001-10003: SQL Injection (3 rules)
    - 10010-10012: XSS (3 rules)
    - 10020-10021: Command Injection (2 rules)
    - 10030-10032: LFI (3 rules)
    - 10040-10042: Brute Force (3 rules)
    - 10050-10072: Protocol Attacks (23 rules)
  - Anomaly scoring
  - 📊 Lines: ~200
  - 🔑 Format: `SecRule` directives with actions

- **rules/sql_keywords.txt**
  - SQL keyword detection list
  - 15 common SQL keywords
  - Used by ModSecurity rule 10002

- **rules/xss_keywords.txt**
  - XSS keyword detection list
  - 14 JavaScript/HTML keywords
  - Used by ModSecurity rule 10010

- **rules/xss_advanced.txt**
  - Advanced XSS encoding patterns
  - 8 encoded XSS variations
  - Used by ModSecurity rule 10012

---

### `/dvwa/` Directory - Vulnerable Web Application

#### 🐳 Docker Build
- **Dockerfile**
  - Base image: `php:7.4-apache`
  - Installs DVWA from GitHub
  - Configures MySQL connection
  - Sets file permissions
  - Enables Apache rewrite module
  - 🎯 Result: Running DVWA on http://dvwa:80

---

### `/attack-scripts/` Directory - Attack Simulation Tools

#### 🔴 Attack Test Scripts

- **sql_injection.sh** (TESTING SQL INJECTION)
  - 5 SQL injection tests:
    1. Basic OR '1'='1
    2. UNION SELECT
    3. Blind time-based
    4. Error-based
    5. Comment-based
  - Shows requests and responses
  - Displays whether WAF blocked
  - 🎯 Target: `/vulnerabilities/sqli/`
  - 📊 Expected: 5/5 blocked (HTTP 403)

- **xss_test.sh** (TESTING XSS)
  - 7 XSS tests:
    1. Basic script tag
    2. Event handler (onerror)
    3. JavaScript protocol
    4. onload event
    5. SVG-based XSS
    6. Encoded XSS
    7. onclick handler
  - Shows requests and responses
  - 🎯 Target: `/vulnerabilities/xss_r/`
  - 📊 Expected: 7/7 blocked (HTTP 403)

- **command_injection.sh** (TESTING COMMAND INJECTION)
  - 8 command injection tests:
    1. Semicolon separator
    2. Pipe operator
    3. $() substitution
    4. Backtick substitution
    5. Logical AND (&&)
    6. Logical OR (||)
    7. Reverse shell attempt
    8. Newline injection
  - Shows requests and responses
  - 🎯 Target: `/vulnerabilities/exec/`
  - 📊 Expected: 8/8 blocked (HTTP 403)

- **lfi_test.sh** (TESTING LFI/TRAVERSAL)
  - 7 LFI tests:
    1. /etc/passwd direct
    2. Null byte injection
    3. Deep directory traversal
    4. Windows file access
    5. Encoded traversal
    6. /etc/shadow access
    7. Config file access
  - Shows requests and responses
  - 🎯 Target: `/vulnerabilities/fi/`
  - 📊 Expected: 7/7 blocked (HTTP 403)

- **brute_force.sh** (TESTING BRUTE FORCE)
  - Simulates 15 failed login attempts
  - Tracks progressive blocking
  - 🎯 Target: `/vulnerabilities/brute/`
  - 📊 Expected:
    - Attempts 1-10: HTTP 200/401 (allowed)
    - Attempts 11-15: HTTP 403 (blocked by WAF)

---

### `/test-payloads/` Directory - Reference Payload Lists

#### 📝 Payload Reference Files

- **sql.txt**
  - 17 SQL injection payload examples
  - Organized by attack type
  - Reference for manual testing
  - 🎯 Format: One payload per line

- **xss.txt**
  - 20 XSS payload examples
  - Includes: tags, events, protocols
  - Reference for WAF rule development
  - 🎯 Format: One payload per line

- **lfi.txt**
  - 24 LFI/traversal payload examples
  - Includes: encoding, null bytes
  - Reference for filter testing
  - 🎯 Format: One payload per line

- **cmd.txt**
  - 19 command injection payloads
  - Includes: shells, redirects, operators
  - Reference for rule tuning
  - 🎯 Format: One payload per line

---

### `/logs/` Directory - ModSecurity Audit Logs

#### 📊 Log Files (Created at Runtime)

- **audit.log**
  - JSON-formatted ModSecurity audit log
  - Created when attacks are performed
  - Contains:
    - Timestamp
    - HTTP request details
    - Rule triggered information
    - Action taken (ALLOW/DENY)
    - HTTP response code
    - Attack classification
  - 📈 Grows with each attack attempt
  - 🔍 Viewable with: `tail logs/audit.log`

---

## 📊 File Statistics

### Code Files
- **Configuration files:** 4 files
- **Detection rules:** 4 files (1 main + 3 keyword lists)
- **Attack scripts:** 5 files
- **Documentation:** 6 files
- **Utility scripts:** 4 files
- **Application files:** 2 files (Docker builds)

### Total Files Created: ~30 files

### Total Lines of Code: ~2,500 lines
- WAF configuration: ~300 lines
- Detection rules: ~200 lines
- Attack scripts: ~400 lines
- Documentation: ~1,600 lines

---

## 🎯 File Relationships

```
docker compose.yml
├── Orchestrates all 3 services
│
├─→ waf/Dockerfile
│   ├─→ waf/nginx.conf
│   ├─→ waf/modsecurity.conf
│   ├─→ waf/crs-setup.conf
│   └─→ waf/rules/
│       ├─→ custom_rules.conf (PROCESSES via ModSecurity)
│       ├─→ sql_keywords.txt (REFERENCED by rule 10002)
│       ├─→ xss_keywords.txt (REFERENCED by rule 10010)
│       └─→ xss_advanced.txt (REFERENCED by rule 10012)
│
├─→ dvwa/Dockerfile
│   └─→ Builds DVWA with MySQL config
│
└─→ attack-scripts/
    ├─→ sql_injection.sh (TESTS against waf/rules/custom_rules.conf)
    ├─→ xss_test.sh
    ├─→ command_injection.sh
    ├─→ lfi_test.sh
    └─→ brute_force.sh

Logging:
└─→ logs/audit.log (WRITTEN by ModSecurity in waf container)
    └─→ VIEWED by view-logs.sh
```

---

## 🔐 Rule Coverage Matrix

| Attack Type | Payloads| Rules | Detection Method |
|--------------|---------|-------|------------------|
| SQL Injection | 17 | 3 | Keywords, OR patterns |
| XSS | 20 | 3 | Tags, events, encoding |
| Command Injection | 19 | 2 | Shell metacharacters |
| LFI | 24 | 3 | Traversal patterns |
| Brute Force | - | 3 | Failed auth tracking |
| Protocol | - | 23+ | Method, encoding, null bytes |
| **TOTAL** | **80** | **> 30** | - |

---

## ✅ Completeness Checklist

- [x] Docker infrastructure files
- [x] WAF configuration files
- [x] DVWA container setup
- [x] 30+ detection rules
- [x] 5 attack simulation scripts
- [x] 4 payload reference files
- [x] 6 comprehensive documentation files
- [x] 4 utility scripts
- [x] Logging setup
- [x] Volume management
- [x] Network configuration
- [x] Health checks
- [x] Comments and descriptions
- [x] Error handling in scripts

**Status:** ✅ 100% Complete - All Files Present & Functional

---

## 🎓 Recommended Reading Order

For **First-Time Users:**
1. **INDEX.md** ← You are here (10 min)
2. **README.md** (5 min)
3. **quick-start.sh** (understand setup)
4. **TESTING.md** (hands-on testing)

For **Windows Users:**
1. **WINDOWS-SETUP.md** (10 min)
2. **README.md** (5 min)
3. **TESTING.md** (30 min)

For **Advanced Users:**
1. **DEPLOYMENT.md** (15 min)
2. **waf/rules/custom_rules.conf** (understand rules)
3. Modify rules and test

For **University Assignment:**
1. **INDEX.md** (this document)
2. **README.md**
3. **TESTING.md**
4. **QUICK-REFERENCE.sh**
5. Perform all required tests
6. Document findings

---

## 📦 File Downloads Summary

When you clone/download this project, you get:

```
✓ Complete Docker infrastructure
✓ 5 attack simulation scripts (ready to run)
✓ 4 payload reference files (80+ payloads)
✓ 6 documentation files (complete guides)
✓ 30+ detection rules (OWASP Top 10)
✓ Setup automation scripts
✓ Cross-platform support (Windows/Mac/Linux)
✓ Logging infrastructure (JSON audit logs)
```

**Total download size:** ~50 MB (including Docker build layers)
**Setup time:** 5-10 minutes
**First test time:** 2-5 minutes

---

## 🚀 Quick Navigation

- **I want to start immediately** → Go to README.md
- **I'm on Windows** → Read WINDOWS-SETUP.md
- **I want command reference** → Run QUICK-REFERENCE.sh
- **I want detailed testing procedures** → Read TESTING.md
- **I'm an admin/deployment specialist** → Read DEPLOYMENT.md
- **I want to understand everything** → Read INDEX.md (this file)
- **I want to analyze logs** → Run view-logs.sh
- **I want to reset everything** → Run clean-all.sh

---

## 🎯 Key Files for Different Users

### Students
- README.md (understand project)
- TESTING.md (hands-on exercises)
- attack-scripts/ (run tests)
- waf/rules/custom_rules.conf (understand rules)

### Instructors
- INDEX.md (complete overview)
- DEPLOYMENT.md (setup guidance)
- TESTING.md (exercise procedures)
- All documentation files

### System Administrators
- WINDOWS-SETUP.md (setup for Windows)
- DEPLOYMENT.md (production considerations)
- docker compose.yml (infrastructure)
- view-logs.sh (monitoring)

### Security Researchers
- waf/rules/custom_rules.conf (rule analysis)
- test-payloads/ (payload reference)
- attack-scripts/ (test patterns)
- TESTING.md (testing procedures)

---

## 📞 Support Quick Links

| Question | Answer Source |
|----------|---|
| How do I start? | README.md |
| How do I test? | TESTING.md |
| How do I on Windows? | WINDOWS-SETUP.md |
| What commands exist? | QUICK-REFERENCE.sh |
| What files do I have? | This file (MANIFEST.md) |
| How are rules written? | waf/rules/custom_rules.conf |
| What attacks are tested? | attack-scripts/ directory |
| How do I see logs? | view-logs.sh |

---

**Last Updated:** 2024  
**Version:** 1.0  
**Status:** ✅ Complete & Ready to Use

---

**Next Step:** Open **README.md** to start the lab!

