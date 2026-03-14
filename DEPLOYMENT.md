# WAF Lab - Deployment & Production Considerations

⚠️ **WARNING:** This lab is designed for **educational purposes only** in isolated environments. Never deploy DVWA or intentionally vulnerable applications in production.

## Important Security Notes

### What This Lab Is
✅ Educational tool for learning WAF concepts
✅ Safe testing environment for security researchers
✅ Demonstration of attack patterns and defense mechanisms
✅ Isolated Docker environment (no external exposure required)

### What This Lab Is NOT
❌ Production-ready security solution
❌ Suitable for protecting real applications
❌ Suitable for random internet deployment
❌ Designed for handling real user data

---

## Deployment Scenarios

### Scenario 1: University Lab Environment (Recommended)

```yaml
Setup:
- Isolated network only
- No internet connectivity required
- Accessible only from lab computers
- Controlled student access
- Time-limited execution (e.g., during lab hours)

Docker Compose Configuration:
  - All services in containers
  - No port forwarding beyond localhost
  - Internal Docker network only
```

**Network Diagram:**
```
University Network
    ↓
Lab Machine (Isolated)
    ├─ Docker Network (Internal)
    │   ├─ WAF (localhost:80)
    │   ├─ DVWA (backend)
    │   └─ MySQL (backend)
    └─ No external exposure
```

### Scenario 2: Home Lab / Personal Study

```bash
# Setup for your personal machine only
# In docker compose.yml, restrict to localhost:
ports:
  - "127.0.0.1:80:80"  # Only accessible from localhost
  - "127.0.0.1:443:443"
```

### Scenario 3: Restricted Network Lab

```bash
# Deploy on internal network with firewall rules

# Firewall: Only allow lab network IPs
# router → firewall (port 80/443) → lab. machines
```

---

## Security Hardening (If Deployed Beyond Localhost)

### 1. Network Isolation

```dockerfile
# Add network restrictions to docker compose.yml
networks:
  waf-lab-network:
    driver: bridge
    driver_opts:
      com.docker.network.bridge.name: waf_br0
```

### 2. Resource Limits

```yaml
services:
  waf:
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 512M
  dvwa:
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 256M
  mysql:
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 256M
```

### 3. User Access Control

```bash
# Run containers with restricted user (not root)
# In Dockerfile:
USER nobody:nogroup
```

### 4. Read-Only Filesystems

```yaml
services:
  waf:
    read_only: true
    tmpfs:
      - /tmp
      - /var/tmp
```

### 5. Security Scanning

```bash
# Scan images for vulnerabilities
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image waf-lab-waf

# Scan running containers
docker run --rm --net host \
  aquasec/trivy image --severity HIGH waf-lab-waf
```

---

## Monitoring & Logging

### 1. Centralized Log Collection

```yaml
# Add to docker compose.yml for ELK Stack
services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.0.0
  logstash:
    image: docker.elastic.co/logstash/logstash:8.0.0
  kibana:
    image: docker.elastic.co/kibana/kibana:8.0.0
```

### 2. Alerting

```bash
# Example: Alert on high attack rate
# Scripts can monitor logs and send alerts via email

* * * * * /opt/waf-lab/check-alerts.sh
```

### 3. Audit Logging

```bash
# Enable comprehensive audit logging
docker compose exec waf-lab-waf \
  tail -f /var/log/modsecurity/audit.log | tee audit-archive.log
```

---

## Backup & Recovery

### 1. Database Backup

```bash
# Backup MySQL database
docker compose exec mysql mysqldump -u dvwa -pdvwa123 dvwa > backup.sql

# Restore from backup
docker compose exec -T mysql mysql -u dvwa -pdvwa123 dvwa < backup.sql
```

### 2. Configuration Backup

```bash
# Backup all configuration files
tar -czf waf-config-backup.tar.gz waf/ dvwa/ docker compose.yml

# Restore
tar -xzf waf-config-backup.tar.gz
```

### 3. Volume Backup

```bash
# Backup Docker volumes
docker run --rm \
  -v waf-lab_mysql_data:/data \
  -v $(pwd):/backup \
  ubuntu tar czf /backup/mysql-backup.tar.gz /data
```

---

## Scaling Considerations

### 1. Multiple WAF Instances

```yaml
# Load balance across multiple WAF instances
services:
  waf1:
    build: ./waf
    ports: ["80:80"]
  waf2:
    build: ./waf
    ports: ["81:80"]
  nginx-lb:  # Nginx Load Balancer
    image: nginx
    ports: ["8080:80"]
    volumes:
      - ./lb.conf:/etc/nginx/nginx.conf
```

### 2. Multiple DVWA Instances

```yaml
services:
  dvwa1:
    build: ./dvwa
    expose: ["80"]
  dvwa2:
    build: ./dvwa
    expose: ["80"]
  # WAF routes to both
```

---

## Disaster Recovery

### 1. Automated Daily Backups

```bash
#!/bin/bash
# backup-daily.sh

BACKUP_DIR="/backups"
DATE=$(date +%Y%m%d_%H%M%S)

# Backup database
docker compose exec -T mysql mysqldump -u dvwa -pdvwa123 dvwa > \
  $BACKUP_DIR/dvwa_$DATE.sql

# Backup logs
cp -r logs/audit.log $BACKUP_DIR/audit_$DATE.log

# Compress
tar -czf $BACKUP_DIR/waf-backup_$DATE.tar.gz $BACKUP_DIR/*.sql

# Cleanup old backups (keep 7 days)
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete

echo "Backup completed: $BACKUP_DIR/backup_$DATE.tar.gz"
```

### 2. Recovery Procedure

```bash
# 1. Stop all services
docker compose down -v

# 2. Restore from backup
tar -xzf waf-backup_20240115_120000.tar.gz

# 3. Restore database
docker compose up -d mysql
sleep 10
docker compose exec -T mysql mysql -u dvwa -pdvwa123 dvwa < dvwa_backup.sql

# 4. Restart all services
docker compose up -d
```

---

## Compliance & Documentation

### 1. Usage Policy

Create USAGE-POLICY.txt:
```
WAF Lab Usage Policy
====================
- This lab is for authorized educational use only
- No malicious use against external systems
- No storage of personal/sensitive data
- Logs are kept for 30 days
- Unauthorized access is prohibited
- By using this lab, you agree to this policy
```

### 2. Incident Reporting

```
If security incidents are discovered:
1. Document the incident details
2. Note timestamp and affected systems
3. Report to security team/instructor
4. Do NOT modify logs
```

### 3. Training Curriculum

Document what students learn:
- WAF fundamentals
- ModSecurity rules
- OWASP Top 10 attacks
- Web security best practices
- Defense mechanisms

---

## Performance Optimization

### 1. Database Optimization

```bash
# Enable MySQL query caching
docker compose exec mysql mysql -u root -proot \
  -e "SHOW VARIABLES LIKE 'query_cache%';"
```

### 2. WAF Tuning

```conf
# In modsecurity.conf, adjust for performance
SecRequestBodyLimit 1048576  # Reduce from 13MB if needed
SecAuditLogType Parallel     # Instead of Concurrent
```

### 3. Nginx Optimization

```conf
# In nginx.conf
worker_processes auto;
worker_connections 2048;
keepalive_timeout 30;
```

---

## Long-Term Maintenance

### Weekly Tasks
- Review audit logs for anomalies
- Check disk space usage
- Verify all services are running

### Monthly Tasks
- Update Docker images
- Review and update WAF rules
- Backup all data
- Test recovery procedures

### Quarterly Tasks
- Security audit
- Performance evaluation
- Student feedback collection
- Documentation updates

---

## Version Management

### Track Changes

```bash
# Initialize Git repository
git init
git add -A
git commit -m "Initial WAF lab setup"

# Tag releases
git tag -a v1.0 -m "Initial release"
git tag -a v1.1 -m "Added custom rules"
```

### Update Procedures

```bash
# Update OWASP CRS
# Edit docker compose.yml
ARG CRS_VERSION=v3.3.6

# Rebuild
docker compose up --build --force-recreate
```

---

## Support & Troubleshooting

### Getting Help

1. Check [README.md](README.md)
2. Review [TESTING.md](TESTING.md)
3. Check Docker logs: `docker logs waf-lab-waf`
4. Check ModSecurity logs: `tail logs/audit.log`

### Common Issues

| Issue | Solution |
|-------|----------|
| Services won't start | Check `docker logs`, free up resources |
| Port conflicts | Change port in docker compose.yml |
| Database errors | Restart MySQL, check logs |
| WAF not blocking | Check if rules are loaded, review logs |

---

## Legal & Ethical Considerations

### Authorized Use Only
- Only run against systems you own or have permission to test
- Respect all applicable laws and regulations
- Comply with your institution's acceptable use policy

### Data Protection
- Use DVWA test data only
- Don't store personal information
- Follow GDPR/data protection laws if applicable

### Responsible Disclosure
- If vulnerabilities are found in ModSecurity/CRS, report responsibly
- Use proper disclosure channels
- Allow time for fixes before public disclosure

---

## References

- [OWASP Security Testing](https://owasp.org/www-project-web-security-testing-guide/)
- [ModSecurity Best Practices](https://github.com/SpiderLabs/ModSecurity)
- [Docker Security](https://docs.docker.com/engine/security/)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)

---

**Last Updated:** 2024
**Status:** For Educational Use Only ⚠️
