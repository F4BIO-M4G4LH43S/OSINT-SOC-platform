# 🛡️ OSINT SOC Platform
### Open Source Intelligence Security Operations Center

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Docker](https://img.shields.io/badge/Docker-Ready-blue?logo=docker)](https://docker.com)
[![Wazuh](https://img.shields.io/badge/Wazuh-4.7-blue)](https://wazuh.com)
[![MISP](https://img.shields.io/badge/MISP-Latest-red)](https://www.misp-project.org)

A fully integrated, open-source SOC platform leveraging OSINT for threat detection, incident response, and security automation.

### 🏗️ Architecture Overview

| Component | Purpose | Port | Documentation |
|-----------|---------|------|---------------|
| **Wazuh** | SIEM/XDR/Endpoint Detection | 443 | [Install Guide](docs/02-wazuh-installation.md) |
| **MISP** | Threat Intelligence Platform | 443 | [Install Guide](docs/03-misp-installation.md) |
| **TheHive** | Case Management | 9000 | [Install Guide](docs/04-thehive-cortex-installation.md) |
| **Cortex** | Observable Analysis | 9001 | [Install Guide](docs/04-thehive-cortex-installation.md) |
| **Shuffle** | SOAR Automation | 3001 | [Install Guide](docs/05-shuffle-installation.md) |
| **OpenCTI** | Cyber Threat Intelligence | 8080 | [Install Guide](docs/06-opencti-installation.md) |

### 🚀 Quick Start (5 Minutes)

### Prerequisites
- Ubuntu 22.04 LTS (recommended) or 20.04 LTS
- 16GB RAM minimum (32GB recommended)
- 4 CPU cores minimum
- 100GB free disk space (SSD recommended)
- Internet connection


| Service   |    URL     | Default Credentials |
|-----------|------------|---------------------|
| **Wazuh** | https://localhost | admin / (generated) |
| **MISP** | https://localhost | admin@admin.test / admin | 
| **TheHive** | http://localhost:9000 | admin@thehive.local / secret | 
| **Cortex** | http://localhost:9001 | admin / (set on first login) | 
| **Shuffle** | http://localhost:3001 | (create on first login) | 
| **OpenCTI** | http://localhost:8080 | admin@opencti.io / (from .env) | 

### 1. Clone the repository
```bash
git clone https://github.com/yourusername/osint-soc-platform.git
cd osint-soc-platform
```
### 2. Install Docker and dependencies
```bash
sudo bash scripts/install-docker.sh
```
### 3. Generate secure secrets
```bash
bash scripts/generate-secrets.sh
```
### 4. Deploy the entire stack
```bash
sudo docker compose up -d
```
### 5. Check health status
```bash
bash scripts/health-check.sh

```bash
┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐
│  Wazuh  │───▶│  MISP   │───▶│ Shuffle │───▶│TheHive  │───▶│  Cortex │
│  (SIEM) │    │ (Intel) │    │ (SOAR)  │    │ (Cases) │    │(Analysis)│
└─────────┘    └─────────┘    └─────────┘    └─────────┘    └─────────┘
     │              │              ▲              ▲              │
     │              │              │              │              │
     └──────────────┴──────────────┴──────────────┴──────────────┘
                                 │
                          ┌─────────────┐
                          │   OpenCTI   │
                          │  (MITRE ATT&CK) │
                          └─────────────┘

```
### Automated Installation

🛠️ Post-Installation Configuration
After installation, configure these essential integrations:

    Enable OSINT Feeds in MISP (CIRCL, Abuse.ch, Botvrij)
    Connect TheHive to Cortex for automated analysis
    Link TheHive to MISP for threat intelligence lookup
    Configure Shuffle workflows for Wazuh → TheHive automation
    Import MITRE ATT&CK into OpenCTI

See Integration Guide for detailed steps.
🔄 Maintenance

### Update all containers 
```bash 
sudo docker compose pull
sudo docker compose up -d
```
### Backup data
```bash
sudo bash scripts/backup.sh
```
### View logs
```bash
sudo docker compose logs -f [service-name]
```
### Stop all services
```bash
sudo docker compose down
```

01-prerequisites

# Prerequisites & System Requirements

## Hardware Requirements

| Component | Minimum | Recommended | Production |
|-----------|---------|-------------|------------|
| **CPU** | 4 cores | 8 cores | 16+ cores |
| **RAM** | 16 GB | 32 GB | 64+ GB |
| **Storage** | 100 GB HDD | 200 GB SSD | 500 GB+ NVMe |
| **Network** | 10 Mbps | 20 Mbps | 100 Mbps |

## Software Requirements

- **Operating System**: Ubuntu 22.04 LTS (recommended) or 20.04 LTS
- **Kernel**: Linux 5.15 or newer
- **Docker**: 24.0.0 or newer
- **Docker Compose**: 2.20.0 or newer (plugin)

## Pre-Installation Steps

### 1. System Update

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y git curl wget jq openssl
```

2. Network Configuration
Ensure the following ports are available:

Port	Service	Direction
443	Wazuh    	Inbound
8081	MISP Web	Inbound
9000	TheHive	Inbound
9001	Cortex	Inbound
3001	Shuffle	Inbound
8080	OpenCTI	Inbound
9200	Elasticsearch	Internal
1514	Wazuh Agents	Inbound

3. System Tuning
For Elasticsearch/OpenSearch performance:

Increase virtual memory map count
sudo sysctl -w vm.max_map_count=262144
echo 'vm.max_map_count=262144' | sudo tee -a /etc/sysctl.conf

Disable swap (required for OpenSearch)
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

Apply changes
sudo sysctl -p

Security Hardening
Before Production Deployment
Firewall Configuration

    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    sudo ufw allow 443/tcp
    sudo ufw allow 22/tcp  # SSH
    sudo ufw enable
'
    SSL/TLS Certificates
        Use Let's Encrypt for production
        Replace self-signed certificates in Wazuh
        Configure HTTPS for all web interfaces
    Authentication
        Change ALL default passwords
        Enable 2FA where supported
        Use API keys instead of passwords for automation
    Backup Strategy
        Daily automated backups of persistent volumes
        Offsite backup storage
        Test restoration procedures monthly

Verification
Run the system check script:
```
bash scripts/check-prerequisites.sh
```
Expected output:

✓ Ubuntu 22.04 LTS detected
✓ 4+ CPU cores available
✓ 16+ GB RAM available
✓ 100+ GB disk space available
✓ Docker not installed (will be installed)
✓ Ports available

Next Steps
Proceed to Wazuh Installation

---

02-wazuh-installation.md

# Wazuh Installation Guide

Wazuh provides SIEM, XDR, and endpoint security monitoring capabilities.

## Installation Methods

We use the official Wazuh Docker images for easy deployment.

## Step-by-Step Installation

### Step 1: Verify Docker Installation

```bash
docker --version
docker compose version
```
Step 2: Wazuh Configuration
The Wazuh services are included in the main docker-compose.yml. Key configuration files:

    configs/wazuh/ossec.conf - Main Wazuh manager configuration
    configs/wazuh/local_rules.xml - Custom detection rules
    configs/wazuh/misp-integration.sh - MISP IoC integration script

Step 3: Deploy Wazuh

# From the project root
```
sudo docker compose up -d wazuh.manager wazuh.indexer wazuh.dashboard
```
Step 4: Verify Installation

# Check container status
```
sudo docker compose ps | grep wazuh
```
# View logs
```
sudo docker compose logs -f wazuh.manager
```
# Check Wazuh API
```
curl -k -u wazuh-wui:MyS3cr37P450r.*- https://localhost:55000/security/user/authenticate
```
Step 5: Access Dashboard
`
    Open https://localhost (accept self-signed certificate)
    Login with:
        Username: admin
        Password: (from .env file WAZUH_INDEXER_PASSWORD)

Post-Installation Configuration
1. Change Default Passwords

# Generate new password hash
```
docker exec -it wazuh.indexer bash
/usr/share/wazuh-indexer/plugins/opensearch-security/tools/hash.sh -p 'NewStrongPassword123!'
# Update opensearch.yml with new hash
```
2. Configure Agent Enrollment

# Get enrollment password
```
docker exec wazuh.manager grep enrollment /var/ossec/etc/ossec.conf
```
3. Install Agents
Linux Agent:
```
curl -sO https://packages.wazuh.com/4.7/wazuh-agent_4.7.2-1_amd64.deb
sudo dpkg -i wazuh-agent_4.7.2-1_amd64.deb
sudo systemctl daemon-reload
sudo systemctl enable wazuh-agent
sudo systemctl start wazuh-agent
```
Windows Agent:
Download from Wazuh dashboard → Agents → Deploy new agent
MISP Integration
Wazuh automatically integrates with MISP for threat intelligence:
`
    Edit configs/wazuh/misp-integration.sh
    Add your MISP API key
    Restart Wazuh manager

Troubleshooting

Dashboard not loading Check wazuh.indexer is healthy: curl http://localhost:9200/_cluster/health
Agent not connecting Verify firewall allows port 1514/tcp and 1515/tcp
High memory usage Increase OPENSEARCH_JAVA_OPTS to -Xms2g -Xmx2g
Next Steps
Proceed to MISP Installation
---

03-misp-installation

MISP Installation Guide

MISP (Malware Information Sharing Platform) is the threat intelligence platform for sharing and storing information about malware, indicators of compromise, and related threat data.

Installation

MISP is deployed via Docker Compose as part of the main stack.

Step 1: Deploy MISP

``
# MISP is included in docker-compose.yml
```
sudo docker compose up -d misp misp-db
```
Step 2: Wait for Initialization
First startup takes 3-5 minutes for database initialization:

Monitor logs
```
sudo docker compose logs -f misp
```
Wait for "Ready to serve requests" message

Step 3: Access MISP
`
    Open https://localhost:8443 (accept self-signed certificate)
    Default credentials:
        Email: admin@admin.test (or from .env)
        Password: admin (or from .env)

Step 4: Initial Configuration
Change Admin Password
`
    Login → Administration → My Profile → Change Password
    Use strong password (20+ characters)

Enable Feeds
Navigate to Sync Actions → List Feeds:
Enable these essential OSINT feeds:

CIRCL OSINT |	https://www.circl.lu/doc/misp/feed-osint |	Daily
Abuse.ch URLhaus	https://urlhaus.abuse.ch/downloads/misp/	Hourly
Botvrij.eu	https://www.botvrij.eu/data/feed-osint/	Daily
DigitalSide	https://osint.digitalside.it/	Daily
Enable via API:
bash
Copy

# Get API key from MISP UI: Administration → My Profile → Auth keys
MISP_API_KEY="your-api-key"

curl -k -X POST https://localhost:8443/feeds/enableFeed/1 \
  -H "Authorization: $MISP_API_KEY" \
  -H "Accept: application/json"

# Fetch all enabled feeds
curl -k -X POST https://localhost:8443/feeds/fetchFromAllFeeds \
  -H "Authorization: $MISP_API_KEY" \
  -H "Accept: application/json"

Step 5: Configure Taxonomies and Galaxies
bash
Copy

# Update taxonomies
docker exec -it misp bash
cd /var/www/MISP/app/Console
./cake Admin updateTaxonomies

# Update galaxies
./cake Admin updateGalaxies

# Update warning lists
./cake Admin updateWarningLists

MISP Configuration for SOC Integration
1. Enable API Access

    Administration → My Profile → Auth keys → Add authentication key
    Copy the key for TheHive and Shuffle integration

2. Configure Export Settings
Administration → Server Settings → MISP settings:

    MISP.live: True
    MISP.enable_feed_correlations: True
    MISP.default_event_threat_level: 3

3. Set Up Organizations

    Administration → Add Organization
        Name: Your SOC Name
        UUID: (auto-generated)
        Description: Security Operations Center

Automation Scripts
Use the provided script to automate feed management:
bash
Copy

# Setup all recommended feeds
bash scripts/setup-misp-feeds.sh

This script will:

    Enable CIRCL, Abuse.ch, Botvrij feeds
    Set appropriate update frequencies
    Configure tags and filters

Verification
Check MISP is properly receiving threat data:

    Events → List Events
    Should see events from enabled feeds
    Check last update timestamps

Troubleshooting
Table
Issue	Solution
Database connection error	Check misp-db container is running: docker compose ps
Feeds not updating	Check feed URLs are accessible from container
High disk usage	Prune old events: Administration → Server Settings → MISP settings
Next Steps
Proceed to TheHive & Cortex Installation
plain
Copy


---

### 10. docs/04-thehive-cortex-installation.md

```markdown
# TheHive & Cortex Installation Guide

TheHive is a scalable security incident response platform. Cortex is the analysis engine that integrates with TheHive for observable analysis.

## Architecture

- **TheHive**: Case management, collaboration, and incident tracking
- **Cortex**: Automated analysis of observables (IPs, hashes, URLs)
- **Cassandra**: Database for TheHive
- **Elasticsearch**: Indexing for TheHive

## Installation

### Step 1: Deploy Services

```bash
sudo docker compose up -d thehive-cassandra thehive-elasticsearch thehive cortex

Step 2: Wait for Database Initialization
Cassandra and Elasticsearch need time to initialize:
bash
Copy

# Check Cassandra status (wait for "UN" - Up Normal)
docker exec -it thehive-cassandra nodetool status

# Check Elasticsearch
curl http://localhost:9200/_cluster/health

Step 3: Access TheHive

    Open http://localhost:9000
    Default credentials:
        Username: admin@thehive.local
        Password: secret

Step 4: Initial TheHive Configuration
Create Organization

    Login as Global Admin
    Administration → Organizations → Add organization
        Name: SOC
        Description: Security Operations Center
        Status: Active

Create User Account

    Administration → Users → Add user
        Login: analyst@soc.local
        Name: SOC Analyst
        Organization: SOC (set as default)
        Profile: org-admin (for setup) or analyst
    Set password for the new user
    Logout and login as the new user

Step 5: Cortex Configuration
Access Cortex

    Open http://localhost:9001
    Create organization matching TheHive
    Create user and generate API key

Configure Analyzers

    Login to Cortex as admin
    Organization → Analyzers
    Enable analyzers:
        VirusTotal_GetReport
        AbuseIPDB
        GreyNoise
        URLScan
        MISP_2_0

Configure Analyzer via API:
bash
Copy

# Get Cortex API key from UI
CORTEX_API_KEY="your-cortex-key"

# List available analyzers
curl -H "Authorization: Bearer $CORTEX_API_KEY" \
  http://localhost:9001/api/analyzer

Step 6: Connect TheHive to Cortex
Edit configs/thehive/application.conf:
hocon
Copy

cortex {
  servers = [
    {
      name = "local-cortex"
      url = "http://cortex:9001"
      auth {
        type = "bearer"
        key = "YOUR_CORTEX_API_KEY"
      }
    }
  ]
}

Restart TheHive:
bash
Copy

sudo docker compose restart thehive

Step 7: Connect TheHive to MISP
Add to configs/thehive/application.conf:
hocon
Copy

misp {
  servers = [
    {
      name = "local-misp"
      url = "http://misp:80"
      auth {
        type = "key"
        key = "YOUR_MISP_API_KEY"
      }
      wsConfig.ssl.loose.acceptAnyCertificate = true
    }
  ]
}

Restart TheHive:
bash
Copy

sudo docker compose restart thehive

Verification
Create a test case:

    Cases → Create case
    Add observable (IP: 8.8.8.8)
    Run Cortex analyzers
    Verify MISP lookup returns results

Troubleshooting
Table
Issue	Solution
TheHive won't start	Check Cassandra is fully up: nodetool status
Cortex analyzers fail	Check analyzer configuration and API keys
MISP integration error	Verify API key and MISP URL in config
Next Steps
Proceed to Shuffle SOAR Installation
plain
Copy


---

### 11. docs/05-shuffle-installation.md

```markdown
# Shuffle SOAR Installation Guide

Shuffle is an open-source SOAR (Security Orchestration, Automation and Response) platform for automating security workflows.

## Installation

Shuffle is deployed via Docker Compose.

### Step 1: Deploy Shuffle

```bash
sudo docker compose up -d shuffle-opensearch shuffle-frontend shuffle-backend

Step 2: Wait for OpenSearch Initialization
bash
Copy

# Monitor logs
sudo docker compose logs -f shuffle-opensearch

# Wait for "Cluster health status changed from [YELLOW] to [GREEN]"

Step 3: Access Shuffle

    Open http://localhost:3001
    Create admin account on first login
    Verify email (if configured)

Step 4: Install Apps
Shuffle requires apps for integrations:
bash
Copy

# Apps are auto-downloaded, but can be manually updated
docker exec -it shuffle-backend python3 /shuffle/shuffle-apps/updates.py

Step 5: Configure Workflows
Import the provided workflow templates:

    Workflows → Import
    Upload playbooks/shuffle-workflows/wazuh-to-thehive.json
    Upload playbooks/shuffle-workflows/enrichment-pipeline.json

Key Workflows
1. Wazuh Alert → TheHive Case
Trigger: Wazuh webhook (Level 12+ alerts)
Actions:

    Receive Wazuh alert
    Extract observables (IP, hash, URL)
    Query MISP for threat intel
    Create TheHive case with observables
    Trigger Cortex analysis
    Notify via Slack/Discord

2. Enrichment Pipeline
Trigger: New observable in TheHive
Actions:

    VirusTotal lookup
    AbuseIPDB check
    GreyNoise noise classification
    Update TheHive case with results

Integration Configuration
Wazuh Integration

    In Shuffle: Create webhook trigger
    Copy webhook URL
    In Wazuh: Configure custom integration

bash
Copy

# Add to Wazuh manager configuration
<integration>
  <name>shuffle</name>
  <hook_url>http://shuffle-backend:5001/api/v1/hooks/webhook_xxx</hook_url>
  <level>12</level>
  <alert_format>json</alert_format>
</integration>

TheHive Integration

    Apps → Find TheHive app
    Add TheHive node to workflow
    Configure:
        URL: http://thehive:9000
        API Key: (from TheHive user profile)

MISP Integration

    Apps → Find MISP app
    Configure:
        URL: http://misp:80
        API Key: (from MISP auth keys)

Custom App Development
For custom integrations:
bash
Copy

# Create new app structure
mkdir -p shuffle-apps/my-custom-app
cd shuffle-apps/my-custom-app

# Create app.yaml and src/app.py
# See Shuffle documentation for SDK

Troubleshooting
Table
Issue	Solution
OpenSearch fails to start	Increase vm.max_map_count: sysctl -w vm.max_map_count=262144
Apps not loading	Check shuffle-apps volume is mounted correctly
Workflow execution fails	Check app authentication credentials
Next Steps
Proceed to OpenCTI Installation
plain
Copy


---

### 12. docs/06-opencti-installation.md

```markdown
# OpenCTI Installation Guide

OpenCTI is an open-source cyber threat intelligence platform for managing and analyzing threat intelligence data with MITRE ATT&CK mapping.

## Installation

OpenCTI is deployed via Docker Compose with multiple dependencies.

### Step 1: Deploy OpenCTI Stack

```bash
sudo docker compose up -d opencti-redis opencti-elasticsearch opencti-minio opencti-rabbitmq

Wait for dependencies to be healthy (2-3 minutes).
Step 2: Deploy OpenCTI Platform
bash
Copy

sudo docker compose up -d opencti opencti-worker

Step 3: Wait for Initialization
First startup takes 5-10 minutes:
bash
Copy

# Monitor logs
sudo docker compose logs -f opencti

# Wait for "Platform is ready" message

Step 4: Access OpenCTI

    Open http://localhost:8080
    Login with credentials from .env:
        Email: admin@opencti.io (or your configured email)
        Password: (from OPENCTI_ADMIN_PASSWORD)

Step 5: Initial Configuration
Create Organization

    Settings → Access → Organizations → Add
        Name: SOC
        Description: Security Operations Center

Configure Connectors
OpenCTI uses connectors to import data. Key connectors for SOC:
MITRE ATT&CK Connector:
yaml
Copy

# Already configured in docker-compose.yml
# Verify it's running:
docker compose ps | grep connector-mitre

MISP Connector:
Add to docker-compose.yml:
yaml
Copy

  connector-misp:
    image: opencti/connector-misp:latest
    environment:
      - OPENCTI_URL=http://opencti:8080
      - OPENCTI_TOKEN=${OPENCTI_ADMIN_TOKEN}
      - CONNECTOR_ID=GENERATE_UUID_V4
      - CONNECTOR_TYPE=EXTERNAL_IMPORT
      - CONNECTOR_NAME=MISP
      - MISP_URL=http://misp:80
      - MISP_API_KEY=${MISP_API_KEY}
      - MISP_SSL_VERIFY=false
    depends_on:
      - opencti
    networks:
      - soc-network

AlienVault OTX Connector:
yaml
Copy

  connector-alienvault:
    image: opencti/connector-alienvault:latest
    environment:
      - OPENCTI_URL=http://opencti:8080
      - OPENCTI_TOKEN=${OPENCTI_ADMIN_TOKEN}
      - CONNECTOR_ID=GENERATE_UUID_V4
      - ALIENVAULT_API_KEY=your-otx-key
    networks:
      - soc-network

Step 6: Data Import
After connectors start, data will automatically import:

    MITRE ATT&CK framework (TTPs, techniques)
    MISP events (as STIX2 objects)
    AlienVault pulses

Monitor import status:
Data → Connectors → Select connector → View logs
Integration with TheHive
Connect TheHive to OpenCTI for enriched threat context:

    TheHive Administration → Platforms → OpenCTI
    Add configuration:
        Name: OpenCTI
        URL: http://opencti:8080
        Token: ${OPENCTI_ADMIN_TOKEN}

Verification
Check data is flowing:

    Threats → Threat Actors (should see MITRE groups)
    Arsenal → Malware (should see MITRE malware)
    Events → Observations (should see MISP data)

Troubleshooting
Table
Issue	Solution
OpenCTI won't start	Check Elasticsearch is green: curl http://localhost:9200/_cluster/health
Connectors failing	Verify API keys and network connectivity
Out of memory	Increase ES_JAVA_OPTS to -Xms4g -Xmx4g
RabbitMQ connection refused	Wait for RabbitMQ to fully start before starting OpenCTI
Next Steps
Proceed to Integration Guide to connect all components.
plain
Copy


---

### 13. docs/07-integration-guide.md

```markdown
# Complete Integration Guide

This guide connects all SOC platform components into a unified workflow.

## Integration Architecture

┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Wazuh     │────▶│   Shuffle   │────▶│  TheHive    │
│   (SIEM)    │     │   (SOAR)    │     │ (Cases)     │
└─────────────┘     └──────┬──────┘     └──────┬──────┘
│                     │
▼                     ▼
┌─────────────┐      ┌─────────────┐
│    MISP     │      │   Cortex    │
│  (Threat    │      │ (Analysis)  │
│   Intel)    │      └─────────────┘
└──────┬──────┘              │
│                     │
└─────────────────────┘
│
▼
┌─────────────┐
│   OpenCTI   │
│  (MITRE     │
│  ATT&CK)    │
└─────────────┘
plain
Copy


## Step 1: Wazuh → Shuffle Integration

### Configure Wazuh Custom Integration

Edit `configs/wazuh/ossec.conf` or use local configuration:

```xml
<ossec_config>
  <integration>
    <name>shuffle</name>
    <hook_url>http://shuffle-backend:5001/api/v1/hooks/YOUR_WEBHOOK_ID</hook_url>
    <level>12</level>
    <alert_format>json</alert_format>
  </integration>
</ossec_config>

Get Webhook URL from Shuffle:

    Shuffle → Triggers → Webhook
    Create new webhook
    Copy URL

Test Integration
bash
Copy

# Trigger test alert
logger -t wazuh-test "Test alert for Shuffle integration"

# Check Shuffle execution logs

Step 2: Shuffle → TheHive Integration
Configure TheHive App in Shuffle

    Shuffle → Apps → Search "TheHive"
    Add TheHive node to workflow
    Configuration:
        URL: http://thehive:9000
        API Key: (from TheHive user profile → API key)

Create Case Workflow
Workflow Steps:

    Webhook Trigger (Wazuh alert)
    Extract Observables (Regex IP, hash, URL)
    MISP Lookup (Check threat intel)
    TheHive: Create Case
        Title: Wazuh Alert: {{rule.description}}
        Description: Full alert JSON
        Severity: {{rule.level}}
        Tags: wazuh, automated, {{rule.groups}}
    TheHive: Add Observable (extracted IPs/hashes)
    Cortex: Run Analyzers
    Notification (Slack/Discord/Email)

Step 3: TheHive ↔ Cortex Integration
Already configured in configs/thehive/application.conf:
hocon
Copy

cortex {
  servers = [
    {
      name = "local-cortex"
      url = "http://cortex:9001"
      auth {
        type = "bearer"
        key = "YOUR_CORTEX_API_KEY"
      }
    }
  ]
}

Verify:

    TheHive → Cases → Create case
    Add observable
    Click "Run Analyzers"
    Should see Cortex results

Step 4: TheHive ↔ MISP Integration
Configuration in configs/thehive/application.conf:
hocon
Copy

misp {
  servers = [
    {
      name = "local-misp"
      url = "http://misp:80"
      auth {
        type = "key"
        key = "YOUR_MISP_API_KEY"
      }
      wsConfig.ssl.loose.acceptAnyCertificate = true
    }
  ]
}

Features:

    Lookup observables in MISP
    Create MISP events from cases
    Import MISP events as cases

Step 5: MISP → OpenCTI Integration
Add MISP connector to OpenCTI (see OpenCTI installation doc).
Benefits:

    MISP events become STIX2 objects in OpenCTI
    Correlation with MITRE ATT&CK
    Visual relationship mapping

Step 6: OpenCTI → TheHive Integration
Enable in TheHive:

    Administration → Settings → Platforms
    Add OpenCTI platform
    Configure enrichment lookups

Automation Scenarios
Scenario 1: Malware Detection

    Wazuh detects suspicious file hash
    Shuffle receives alert
    MISP lookup → known malware
    TheHive case created automatically
    Cortex runs VirusTotal analysis
    OpenCTI maps to MITRE technique
    Analyst receives enriched case

Scenario 2: Phishing Response

    Wazuh detects connection to known phishing domain
    Shuffle triggers workflow
    URLScan analysis via Cortex
    TheHive case with screenshot
    MISP event created for sharing
    Active response blocks domain

Verification Checklist

    [ ] Wazuh alerts trigger Shuffle workflows
    [ ] Shuffle creates TheHive cases automatically
    [ ] TheHive runs Cortex analyzers successfully
    [ ] MISP lookups return threat intel
    [ ] OpenCTI shows correlated data
    [ ] All services communicate without errors

Troubleshooting Integration Issues
Table
Symptom	Check
No alerts in Shuffle	Verify Wazuh integration config and webhook URL
Cases not created	Check TheHive API key and Shuffle app configuration
Cortex timeout	Verify Cortex container is healthy and analyzers enabled
MISP lookup fails	Check MISP API key and network connectivity
Next Steps
Configure OSINT Feeds for comprehensive threat intelligence.
plain
Copy


---

### 14. docs/08-osint-feeds-configuration.md

```markdown
# OSINT Feeds Configuration

Configure comprehensive open-source intelligence feeds for your SOC platform.

## MISP Feeds Configuration

### Essential Feeds

| Feed Name | Provider | Type | Frequency |
|-----------|----------|------|-----------|
| CIRCL OSINT | CIRCL (Luxembourg) | General | Daily |
| Abuse.ch URLhaus | Abuse.ch | Malware URLs | Hourly |
| Abuse.ch MalwareBazaar | Abuse.ch | Malware samples | Hourly |
| Botvrij.eu | Botvrij.eu | IOCs | Daily |
| DigitalSide | OSINT.digitalside.it | Multi-category | Daily |
| Blocklist.de | Blocklist.de | Attackers | Hourly |

### Feed Configuration Script

Use the provided script:

```bash
bash scripts/setup-misp-feeds.sh

Or configure manually:

    MISP → Sync Actions → List Feeds
    Click "Load default feed metadata"
    Enable desired feeds
    Set update frequency

Custom Feed Addition
For proprietary or custom feeds:
bash
Copy

# Add via API
curl -k -X POST https://localhost:8443/feeds/add \
  -H "Authorization: $MISP_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "Feed": {
      "name": "Custom OSINT Feed",
      "provider": "Internal Team",
      "url": "https://your-feed-server/feed.json",
      "source_format": "misp",
      "enabled": true,
      "fixed_event": true,
      "delta_merge": true,
      "publish": false,
      "override_ids": false,
      "settings": {
        "csv": {
          "value": "ip-dst",
          "comment": "description"
        }
      }
    }
  }'

OpenCTI Connectors
External Import Connectors
Table
Connector	Data Source	Value
MITRE ATT&CK	MITRE	TTPs, techniques, groups
MISP	Internal MISP	Events as STIX2
AlienVault OTX	AlienVault	Community pulses
VirusTotal	VirusTotal	File/URL reputation
CVE	MITRE/NVD	Vulnerability data
Connector Configuration
Add to docker-compose.yml:
yaml
Copy

  connector-mitre:
    image: opencti/connector-mitre:latest
    environment:
      - OPENCTI_URL=http://opencti:8080
      - OPENCTI_TOKEN=${OPENCTI_ADMIN_TOKEN}
      - CONNECTOR_ID=${CONNECTOR_MITRE_ID}
      - CONNECTOR_TYPE=EXTERNAL_IMPORT
      - CONNECTOR_NAME=MITRE_ATT&CK
      - CONNECTOR_SCOPE=marking-definition,identity,attack-pattern,course-of-action,intrusion-set,campaign,malware,tool,report,narrative,channel,origin,threat-actor
      - CONNECTOR_CONFIDENCE_LEVEL=75
      - CONNECTOR_UPDATE_EXISTING_DATA=true
      - CONNECTOR_RUN_AND_TERMINATE=false
      - CONNECTOR_LOG_LEVEL=info
      - MITRE_INTERVAL=7
    depends_on:
      - opencti
    networks:
      - soc-network

Cortex Analyzers OSINT
Free/OSINT Analyzers
Table
Analyzer	Source	Purpose	API Key Required
AbuseIPDB	AbuseIPDB	IP reputation	Yes (free tier)
GreyNoise	GreyNoise	Internet noise	Yes (community)
URLScan	URLScan.io	URL analysis	Yes (free)
VirusTotal	VirusTotal	File/URL/Domain	Yes (free tier)
MISP_Search	Internal MISP	Threat lookup	No
OpenCTI_Search	OpenCTI	Intel lookup	No
Analyzer Configuration

    Cortex → Organization → Analyzers
    Enable desired analyzers
    Configure API keys in analyzer config

Example: AbuseIPDB
JSON
Copy

{
  "api_key": "your-abuseipdb-key",
  "max_age_in_days": 30,
  "check_tor": true
}

Wazuh CDB Lists
IP Reputation Lists
Create custom lists from OSINT feeds:
bash
Copy

# Download IP blocklist
curl -o /tmp/blocklist.txt https://lists.blocklist.de/lists/all.txt

# Convert to Wazuh CDB format
awk '{print $1 ":1:"}' /tmp/blocklist.txt > /var/ossec/etc/lists/osint-blocklist

# Update Wazuh config
# Add to ossec.conf:
# <list>etc/lists/osint-blocklist</list>

Automated List Updates
Add to crontab:
bash
Copy

# Update OSINT lists daily at 2 AM
0 2 * * * /var/ossec/integrations/update-osint-lists.sh

Threat Intelligence Platforms (TIP) Integration
MISP to OpenCTI Sync
Configure MISP connector in OpenCTI to pull:

    Events as Incidents
    Attributes as Observables
    Tags as Labels
    Galaxies as Threat Actors/Malware

STIX/TAXII Feeds
For TAXII 2.1 feeds:

    OpenCTI → Data → Ingestion → TAXII 2.1
    Add feed:
        Name: FS-ISAC (or other)
        URL: https://api.ctm.cyberthreat-intelligence.com/taxii2/
        Collection: default
        Authentication: (API key)

OSINT Automation with Shuffle
Automated Enrichment Workflow
Create Shuffle workflow:

    Trigger: New observable in TheHive
    Parallel Actions:
        VirusTotal lookup
        AbuseIPDB check
        GreyNoise classification
        MISP correlation
        URLScan (if URL)
    Decision: If malicious score > 7
    Action: Update TheHive case, notify team
    Optional: Create MISP event for sharing

Threat Hunting Automation

    Schedule: Daily at 09:00
    Query: OpenCTI for new threat actors
    Check: Wazuh for related TTPs
    Alert: If correlation found, create TheHive case

Quality Assurance
Feed Health Monitoring
bash
Copy

# Check feed freshness
curl -s -H "Authorization: $MISP_API_KEY" \
  https://localhost:8443/feeds | jq '.Feed[] | {name, last_fetch}'

# Verify OpenCTI connector status
curl -s http://localhost:8080/opencti/connectors

False Positive Management

    MISP: Use warning lists for known good IPs
    Wazuh: Create exception rules for false positives
    Cortex: Configure confidence thresholds
    TheHive: Tag false positives for ML training

Next Steps
Review Troubleshooting Guide for common issues.
plain
Copy


---

### 15. docs/09-troubleshooting.md

```markdown
# Troubleshooting Guide

Common issues and solutions for the OSINT SOC Platform.

## Installation Issues

### Docker Compose Fails to Start

**Symptom:** `docker compose up` fails with errors

**Solutions:**
```bash
# Check Docker service
sudo systemctl status docker
sudo systemctl start docker

# Check disk space
df -h

# Check memory
free -h

# Reset and retry
sudo docker compose down -v
sudo docker compose up -d

Port Conflicts
Symptom: bind: address already in use
Check:
bash
Copy

# Find process using port
sudo lsof -i :9000

# Kill process or change port in docker-compose.yml

Permission Denied
Symptom: Cannot access Docker socket
Fix:
bash
Copy

# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Or use sudo for all commands

Service-Specific Issues
Wazuh
Dashboard not loading:
bash
Copy

# Check indexer health
curl -k -u admin:password https://localhost:9200/_cluster/health

# Restart stack
sudo docker compose restart wazuh.indexer wazuh.dashboard

# Check logs
sudo docker compose logs -f wazuh.indexer

High memory usage:

    Increase OPENSEARCH_JAVA_OPTS to -Xms2g -Xmx2g
    Add more RAM to host

MISP
Database connection error:
bash
Copy

# Check MySQL container
sudo docker compose ps misp-db
sudo docker compose logs misp-db

# Reset database (WARNING: data loss)
sudo docker compose down -v misp-db
sudo docker compose up -d misp-db

Feeds not updating:

    Check feed URLs are accessible: curl -I https://www.circl.lu/doc/misp/feed-osint
    Verify MISP can reach internet: docker exec misp ping -c 3 google.com

TheHive
Won't start (Cassandra issues):
bash
Copy

# Check Cassandra status
docker exec -it thehive-cassandra nodetool status

# If UN (Up Normal) not shown, wait longer
# Or reset Cassandra (data loss):
sudo docker compose down -v thehive-cassandra
sudo docker compose up -d thehive-cassandra
sleep 60
sudo docker compose up -d thehive

Elasticsearch connection error:
bash
Copy

# Verify Elasticsearch
curl http://localhost:9200

# Check TheHive config
cat configs/thehive/application.conf | grep elasticsearch

Cortex
Analyzers not working:
bash
Copy

# Check Cortex logs
sudo docker compose logs -f cortex

# Verify analyzers are enabled
curl -H "Authorization: Bearer API_KEY" http://localhost:9001/api/analyzer

# Check job directory permissions
docker exec cortex ls -la /tmp/cortex-jobs

Shuffle
OpenSearch fails:
bash
Copy

# System requirement
sudo sysctl -w vm.max_map_count=262144

# Check logs
sudo docker compose logs -f shuffle-opensearch

# Reset
sudo docker compose down -v shuffle-opensearch
sudo docker compose up -d shuffle-opensearch

OpenCTI
Platform won't start:
bash
Copy

# Check dependencies
curl http://localhost:9200/_cluster/health
docker exec opencti-redis redis-cli ping

# Check RabbitMQ
docker exec opencti-rabbitmq rabbitmqctl status

# View OpenCTI logs
sudo docker compose logs -f opencti | grep ERROR

🤝 Contributing
Contributions are welcome! Please read our Contributing Guide first.
📄 License
This project is licensed under the GPL-3.0 License - see the LICENSE file.
🙏 Acknowledgments

    Wazuh - Security monitoring
    MISP Project - Threat intelligence
    StrangeBee - TheHive & Cortex
    Shuffle - SOAR platform
    OpenCTI - Cyber threat intelligence
    Filigran - OpenCTI development

⚠️ Security Notice
This platform handles sensitive security data. Before production deployment:

    Change all default passwords
    Enable HTTPS/TLS for all services
    Configure proper firewall rules
    Set up regular backups
    Review Security Hardening Guide

```
```bash

```



