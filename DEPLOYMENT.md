
# Create a deployment checklist and final verification
import os

base_dir = "/mnt/kimi/output/osint-soc-platform"

# Create DEPLOYMENT.md - Step by step for GitHub
deployment_guide = '''# 🚀 Complete Deployment Guide

This guide walks you through creating this repository on GitHub and deploying it from start to finish.

## Phase 1: Create GitHub Repository

### Step 1: Prepare Local Repository

```bash
# Navigate to the generated repository
cd /mnt/kimi/output/osint-soc-platform

# Initialize git repository
git init

# Add all files
git add .

# Commit
git commit -m "Initial commit: OSINT SOC Platform v1.0"
```

### Step 2: Create GitHub Repository

1. Go to https://github.com/new
2. Repository name: `osint-soc-platform`
3. Description: `Production-ready OSINT SOC Platform with Wazuh, MISP, TheHive, OpenCTI, and Shuffle`
4. Make it **Public** (or Private if preferred)
5. **DO NOT** initialize with README (we already have one)
6. Click **Create repository**

### Step 3: Push to GitHub

```bash
# Add remote (replace YOUR_USERNAME with your GitHub username)
git remote add origin https://github.com/YOUR_USERNAME/osint-soc-platform.git

# Push to main branch
git branch -M main
git push -u origin main
```

### Step 4: Verify Repository

1. Visit: `https://github.com/YOUR_USERNAME/osint-soc-platform`
2. You should see all files:
   - README.md
   - install.sh
   - docker/
   - configs/
   - docs/
   - scripts/
   - .github/

## Phase 2: Deploy on Server

### Option A: One-Line Installation (Fastest)

On your target server:

```bash
# Download and run installer
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/osint-soc-platform/main/install.sh | sudo bash

# Configure environment
sudo nano /opt/osint-soc/.env

# Start services
sudo /opt/osint-soc/scripts/start.sh

# Verify
sudo /opt/osint-soc/scripts/verify-setup.sh
```

### Option B: Clone and Install (Recommended for Development)

```bash
# Clone repository
git clone https://github.com/YOUR_USERNAME/osint-soc-platform.git
cd osint-soc-platform

# Copy and edit environment
cp .env.example .env
nano .env  # Change all passwords!

# Run installer
sudo ./install.sh

# Start services
cd /opt/osint-soc
sudo ./scripts/start.sh

# Verify
sudo ./scripts/verify-setup.sh
```

### Option C: Ansible Deployment (For Multiple Servers)

```bash
# On your Ansible control node
ansible-playbook -i ansible/inventory/production.ini ansible/playbooks/deploy-soc.yml
```

## Phase 3: Post-Installation Configuration

### 1. Change Default Passwords

**Wazuh Dashboard** (http://localhost:5601):
```bash
# Login: admin / SecretPassword
# Change password in UI: Stack Management > Security > Users
```

**TheHive** (http://localhost:9000):
```bash
# Login: admin@thehive.local / secret
# Create new organization and users
# Admin > Users > Change Password
```

**MISP** (https://localhost:8443):
```bash
# Login: admin@admin.test / admin
# Admin > My Profile > Change Password
# Admin > Server Settings > MISP Settings > Change site admin password
```

**OpenCTI** (http://localhost:8080):
```bash
# Login: admin@opencti.local / changeme
# Settings > Access > Change password
```

### 2. Configure OSINT Feeds

```bash
# SSH to server
ssh user@your-server

# Update MISP feeds
sudo /opt/osint-soc/scripts/update-osint-feeds.sh

# Or manually enable feeds in MISP UI:
# https://your-server:8443/feeds/index
```

### 3. Set Up SSL/TLS (Production)

```bash
# Using Let's Encrypt (requires domain)
sudo apt install certbot
sudo certbot certonly --standalone -d soc.yourdomain.com

# Copy certificates
sudo cp /etc/letsencrypt/live/soc.yourdomain.com/fullchain.pem /opt/osint-soc/configs/nginx/ssl/
sudo cp /etc/letsencrypt/live/soc.yourdomain.com/privkey.pem /opt/osint-soc/configs/nginx/ssl/

# Update nginx config and restart
docker restart soc-nginx
```

### 4. Configure Email Notifications

Edit `/opt/osint-soc/.env`:
```bash
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASSWORD=your-app-password
```

Restart services:
```bash
sudo /opt/osint-soc/scripts/stop.sh
sudo /opt/osint-soc/scripts/start.sh
```

### 5. Add Wazuh Agents

On endpoints to monitor:
```bash
# Linux
curl -so wazuh-agent.tar.gz https://packages.wazuh.com/4.x/linux/wazuh-agent.tar.gz
sudo tar -xzf wazuh-agent.tar.gz -C /opt/
sudo /opt/wazuh-agent/bin/wazuh-control start

# Or use deployment script from Wazuh Dashboard
# Agents > Deploy New Agent
```

## Phase 4: Verification

### Run Verification Script

```bash
sudo /opt/osint-soc/scripts/verify-setup.sh
```

Expected output:
```
===================================
OSINT SOC Platform - Setup Verification
===================================

[1/10] Checking Docker installation...
✓ PASS: Docker is installed (Docker version 24.0.7)

[2/10] Checking Docker Compose...
✓ PASS: Docker Compose is installed

[3/10] Checking directory structure...
✓ PASS: Base directory exists (/opt/osint-soc)
✓ PASS: Environment file exists

[4/10] Checking Docker network...
✓ PASS: Docker network 'soc-network' exists

[5/10] Checking running containers...
✓ PASS: 15 SOC containers are running

[6/10] Checking Elasticsearch...
✓ PASS: Elasticsearch is responding

[7/10] Checking Wazuh Dashboard...
✓ PASS: Wazuh Dashboard is accessible (HTTP 200)

[8/10] Checking TheHive...
✓ PASS: TheHive is accessible (HTTP 200)

[9/10] Checking MISP...
✓ PASS: MISP is accessible (HTTP 200)

[10/10] Checking OpenCTI...
✓ PASS: OpenCTI is accessible (HTTP 200)

===================================
Verification Summary
===================================
Passed: 10
Failed: 0

✓ All tests passed! Your OSINT SOC Platform is ready.
```

### Access Services

Open your browser and verify:

1. **Wazuh Dashboard**: http://your-server:5601
   - Login with new credentials
   - Check that agents are connected

2. **TheHive**: http://your-server:9000
   - Create a test case
   - Verify Cortex integration

3. **MISP**: https://your-server:8443
   - Check feeds are updating
   - Create a test event

4. **OpenCTI**: http://your-server:8080
   - Verify connectors are running
   - Check for imported data

5. **Shuffle**: http://your-server:3001
   - Create admin account
   - Download apps

## Phase 5: Maintenance

### Daily

```bash
# Check health
sudo /opt/osint-soc/scripts/health-check.sh

# View logs
sudo docker logs -f soc-wazuh-manager
sudo docker logs -f soc-thehive
```

### Weekly

```bash
# Update OSINT feeds
sudo /opt/osint-soc/scripts/update-osint-feeds.sh

# Update Wazuh CDB lists
sudo /opt/osint-soc/scripts/update-wazuh-cdb.sh

# Backup
sudo /opt/osint-soc/scripts/backup.sh
```

### Monthly

```bash
# Update containers
cd /opt/osint-soc
docker-compose -f docker/docker-compose.infra.yml pull
docker-compose -f docker/docker-compose.security.yml pull
docker-compose -f docker/docker-compose.osint.yml pull

# Restart with updates
sudo ./scripts/stop.sh
sudo ./scripts/start.sh
```

## Troubleshooting Deployment

### Issue: Git push fails
```bash
# Check remote URL
git remote -v

# Fix if needed
git remote set-url origin https://github.com/YOUR_USERNAME/osint-soc-platform.git

# Or use SSH
git remote set-url origin git@github.com:YOUR_USERNAME/osint-soc-platform.git
```

### Issue: Docker not installed
```bash
# Manual Docker installation
curl -fsSL https://get.docker.com | sudo bash
sudo usermod -aG docker $USER
newgrp docker
```

### Issue: Permission denied on install.sh
```bash
chmod +x install.sh
sudo ./install.sh
```

### Issue: Services not accessible
```bash
# Check firewall
sudo ufw status
sudo ufw allow 5601/tcp
sudo ufw allow 9000/tcp
sudo ufw allow 8443/tcp
sudo ufw allow 8080/tcp
sudo ufw allow 3001/tcp

# Check if containers are running
sudo docker ps | grep soc-

# Check logs
sudo docker logs soc-wazuh-dashboard
sudo docker logs soc-thehive
```

## Next Steps

1. **Read the Documentation**:
   - [OSINT Feeds Setup](docs/OSINT-FEEDS.md)
   - [Automation Guide](docs/AUTOMATION.md)
   - [Installation Details](docs/INSTALLATION.md)

2. **Customize Your Deployment**:
   - Add custom Wazuh rules
   - Configure additional MISP feeds
   - Create Shuffle workflows

3. **Production Hardening**:
   - Enable SSL/TLS
   - Configure backup automation
   - Set up monitoring

4. **Join the Community**:
   - Star the repository
   - Report issues
   - Contribute improvements

## Support

- **GitHub Issues**: https://github.com/YOUR_USERNAME/osint-soc-platform/issues
- **Documentation**: https://github.com/YOUR_USERNAME/osint-soc-platform/wiki
- **Discussions**: https://github.com/YOUR_USERNAME/osint-soc-platform/discussions

---

**🎉 Congratulations! Your OSINT SOC Platform is now deployed and ready to use!**
'''

with open(f"{base_dir}/DEPLOYMENT.md", "w") as f:
    f.write(deployment_guide)

print("✅ DEPLOYMENT.md created with complete GitHub + deployment instructions")
