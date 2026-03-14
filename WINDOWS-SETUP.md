# WAF Lab - Windows Setup Guide

This guide provides step-by-step instructions for setting up and running the WAF Lab on Windows.

## Prerequisites

### Step 1: Install Docker Desktop for Windows

1. **Download Docker Desktop:**
   - Visit: https://www.docker.com/products/docker-desktop
   - Click "Download for Windows"
   - Select the appropriate version:
     - **System Requirements:** Windows 10 or 11, 64-bit processor

2. **Install Docker Desktop:**
   - Run the installer (`Docker Desktop Installer.exe`)
   - Accept the license agreement
   - Select "Use WSL 2 instead of Hyper-V" (recommended for better performance)
   - Complete the installation
   - Restart your computer when prompted

3. **Verify Installation:**
   ```powershell
   docker --version
   docker compose --version
   ```

### Step 2: Enable WSL 2 (Recommended)

WSL 2 provides better performance than Hyper-V.

```powershell
# Run as Administrator
wsl --install
# Restart your computer
```

---

## Starting the Lab

### Option 1: Using PowerShell

```powershell
# Navigate to project directory
cd "d:\UIT\HKVII\atmnc\doan"

# Start the lab (will take 2-3 minutes)
docker compose up --build

# In output, you should see:
# waf-lab-mysql  | ready for connections
# waf-lab-dvwa   | Apache/... started
# waf-lab-waf    | nginx: .... started
```

### Option 2: Using Quick Start Script (PowerShell)

```powershell
cd "d:\UIT\HKVII\atmnc\doan"

# Make scripts executable (Windows)
Get-ChildItem -Path ".\attack-scripts\*" -Filter "*.sh" | ForEach-Object {
    icacls $_.FullName /grant:r "${env:USERNAME}:(F)"
}

# Run using bash (if Git Bash is installed)
bash quick-start.sh

# Or convert to PowerShell
powershell -ExecutionPolicy Bypass -File setup.ps1
```

---

## Running Attack Tests on Windows

### Option 1: PowerShell

```powershell
cd "d:\UIT\HKVII\atmnc\doan"

# SQL Injection Test
curl -i "http://localhost/vulnerabilities/sqli/?id=' OR '1'='1&Submit=Submit"

# XSS Test
curl -i "http://localhost/vulnerabilities/xss_r/?name=<script>alert(1)</script>"

# Command Injection Test
curl -i "http://localhost/vulnerabilities/exec/?ip=127.0.0.1;ls"

# LFI Test
curl -i "http://localhost/vulnerabilities/fi/?page=../../../../etc/passwd"
```

### Option 2: Using Git Bash

```bash
cd /d/UIT/HKVII/atmnc/doan

# Run attack scripts
./attack-scripts/sql_injection.sh
./attack-scripts/xss_test.sh
./attack-scripts/command_injection.sh
./attack-scripts/lfi_test.sh
./attack-scripts/brute_force.sh
```

### Option 3: Using WSL 2

```bash
# Open WSL terminal
wsl

# Navigate to project
cd /mnt/d/UIT/HKVII/atmnc/doan

# Run scripts
./attack-scripts/sql_injection.sh
```

---

## Viewing Logs on Windows

### PowerShell

```powershell
# Real-time WAF logs
docker logs -f waf-lab-waf

# ModSecurity audit log (tail last 20 lines)
Get-Content logs/audit.log -Tail 20

# Follow log (equivalent to tail -f)
Get-Content logs/audit.log -Wait

# Format as JSON (requires jq or ConvertFrom-Json)
Get-Content logs/audit.log | ConvertFrom-Json | Format-Table
```

### PowerShell Script for Formatted Logs

```powershell
# Create file: view-logs.ps1
$logFile = "logs/audit.log"
if (Test-Path $logFile) {
    Write-Host "Last 10 audit log entries:"
    Get-Content $logFile -Tail 10 | ForEach-Object {
        $json = $_ | ConvertFrom-Json
        Write-Host ("Rule ID: {0}, Message: {1}" -f $json.rule_id, $json.message)
    }
} else {
    Write-Host "Log file not found"
}

# Run it
powershell -ExecutionPolicy Bypass -File view-logs.ps1
```

---

## Docker Desktop GUI

You can also use Docker Desktop GUI:

1. **Open Docker Desktop:**
   - Click the Docker icon in system tray
   - Or search "Docker Desktop" in Windows search

2. **View Containers:**
   - Click on "Containers"
   - You'll see: `waf-lab-waf`, `waf-lab-dvwa`, `waf-lab-mysql`

3. **View Logs:**
   - Click on a container
   - Click "Logs" tab
   - View real-time output

4. **Open Terminal:**
   - Right-click a container
   - Select "Open in Terminal"
   - Execute commands in the container

---

## Stopping the Lab

### PowerShell

```powershell
cd "d:\UIT\HKVII\atmnc\doan"

# Stop all services (keep containers)
docker compose stop

# Stop and remove containers
docker compose down

# Stop and remove everything including volumes
docker compose down -v
```

---

## Troubleshooting on Windows

### Issue: Port 80 Already in Use

```powershell
# Find what process is using port 80
netstat -ano | findstr :80

# Kill the process (replace PID)
taskkill /PID <PID> /F

# Or change the port in docker compose.yml
# Edit ports: "8080:80"
```

### Issue: Docker Daemon Not Running

```powershell
# Start Docker Desktop
Start-Service Docker

# Or open Docker Desktop manually from Start menu
```

### Issue: WSL 2 Installation Fails

```powershell
# Check Windows version (requires 21H2 or later)
Get-ComputerInfo | Select-Object OsVersion

# Update Windows if needed
# Settings > Update & Security > Windows Update > Check for updates
```

### Issue: Permission Denied on Scripts

```powershell
# Set execution policy for current user
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Or bypass for one script
powershell -ExecutionPolicy Bypass -File script.ps1
```

### Issue: Cannot Connect to http://localhost

```powershell
# Check if WAF is running
docker ps | findstr waf-lab-waf

# Check WAF logs for errors
docker logs waf-lab-waf | Select-Object -Last 20

# Try connecting with verbose output
curl -v http://localhost

# If still fails, check Docker networking
docker network ls
```

---

## Performance Tips

### 1. Allocate More Resources
- Open Docker Desktop Settings
- Go to "Resources"
- Increase CPUs and Memory
- Recommended: 4 CPUs, 4GB RAM

### 2. Use WSL 2
- Provides better performance than Hyper-V
- Already recommended in setup steps

### 3. Disable Unnecessary Windows Services
```powershell
# Run as Administrator
Get-Service "WSearch" | Stop-Service  # Windows Search
```

---

## File Path Notes

### Windows vs Unix Paths

In PowerShell, use backslashes:
```powershell
cd "d:\UIT\HKVII\atmnc\doan"
Get-Content "logs\audit.log"
```

In Git Bash/WSL, use forward slashes:
```bash
cd /d/UIT/HKVII/atmnc/doan
cat logs/audit.log
```

---

## Accessing from Other Machines

### Access from Another Computer on Network

```powershell
# Get your machine's IP address
ipconfig | findstr "IPv4"

# Access from other machine (replace IP)
curl http://<YOUR_IP>:80
curl http://192.168.1.100:80
```

### Note: Firewall Configuration

Windows Firewall may need to be configured:
1. Settings > Firewall & Network Protection
2. Allow an app through firewall
3. Add Docker Desktop or port 80

---

## Additional Resources

- [Docker Desktop for Windows Guide](https://docs.docker.com/desktop/install/windows-install/)
- [WSL 2 Guide](https://docs.microsoft.com/en-us/windows/wsl/install)
- [PowerShell Documentation](https://docs.microsoft.com/en-us/powershell/)
- [Git Bash for Windows](https://gitforwindows.org/)

---

## Next Steps

After successful setup:

1. Read [README.md](README.md) - Project overview
2. Read [TESTING.md](TESTING.md) - Comprehensive testing guide
3. Run [QUICK-REFERENCE.sh](QUICK-REFERENCE.sh) - Common commands
4. Start attacking with `attack-scripts/`

---

**Last Updated:** 2024
**Windows Version:** Windows 10 21H2+, Windows 11
