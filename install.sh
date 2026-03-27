
# Create the complete, fixed install.sh that actually works
install_script = '''#!/bin/bash

# OSINT SOC Platform - Complete Installation Script
# This script sets up the entire OSINT SOC stack automatically

set -e

# Colors for output
RED='\\033[0;31m'
GREEN='\\033[0;32m'
YELLOW='\\033[1;33m'
BLUE='\\033[0;34m'
NC='\\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root or with sudo"
        exit 1
    fi
}

# Check system requirements
check_requirements() {
    log_info "Checking system requirements..."
    
    # Check RAM
    TOTAL_RAM=$(free -g | awk '/^Mem:/{print $2}')
    if [ "$TOTAL_RAM" -lt 8 ]; then
        log_warning "System has less than 8GB RAM ($TOTAL_RAM GB). 16GB is recommended."
        read -p "Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    # Check disk space
    AVAILABLE_DISK=$(df -BG / | awk 'NR==2 {print $4}' | sed 's/G//')
    if [ "$AVAILABLE_DISK" -lt 50 ]; then
        log_warning "Less than 50GB disk space available ($AVAILABLE_DISK GB)."
        read -p "Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    log_success "System requirements check passed"
}

# Install Docker and Docker Compose
install_docker() {
    log_info "Installing Docker and Docker Compose..."
    
    if command -v docker &> /dev/null; then
        log_info "Docker already installed: $(docker --version)"
    else
        log_info "Installing Docker..."
        curl -fsSL https://get.docker.com | bash
        systemctl enable docker
        systemctl start docker
        usermod -aG docker $SUDO_USER 2>/dev/null || true
        log_success "Docker installed successfully"
    fi
    
    if docker compose version &> /dev/null; then
        log_info "Docker Compose already installed"
    else
        log_info "Installing Docker Compose..."
        apt-get update
        apt-get install -y docker-compose-plugin
        log_success "Docker Compose installed successfully"
    fi
}

# Install dependencies
install_dependencies() {
    log_info "Installing dependencies..."
    apt-get update
    apt-get install -y \
        curl \
        wget \
        git \
        jq \
        openssl \
        apache2-utils \
        net-tools \
        dnsutils \
        htop \
        vim \
        unzip \
        uuid-runtime
    log_success "Dependencies installed"
}

# Setup directory structure
setup_directories() {
    log_info "Setting up directory structure..."
    
    BASE_DIR="/opt/osint-soc"
    mkdir -p $BASE_DIR/{docker,configs,scripts,logs,backups}
    mkdir -p $BASE_DIR/configs/{wazuh,thehive,cortex,misp,opencti,shuffle,nginx,mysql}
    mkdir -p $BASE_DIR/configs/nginx/sites
    mkdir -p $BASE_DIR/configs/wazuh/misp
    mkdir -p $BASE_DIR/configs/shuffle-workflows
    
    # Set permissions
    if [ -n "$SUDO_USER" ]; then
        chown -R $SUDO_USER:$SUDO_USER $BASE_DIR
    fi
    chmod -R 755 $BASE_DIR
    
    log_success "Directory structure created at $BASE_DIR"
}

# Generate configuration files
generate_configs() {
    log_info "Generating configuration files..."
    
    BASE_DIR="/opt/osint-soc"
    
    # Generate TheHive config
    cat > $BASE_DIR/configs/thehive/application.conf << 'EOF'
# TheHive Configuration
play.http.secret.key="${THEHIVE_SECRET_KEY:-changeme}"
play.http.secret.key="${?APPLICATION_SECRET}"

# Database configuration
db.janusgraph {
  storage {
    backend = cql
    hostname = ["cassandra"]
    cql {
      cluster-name = "TheHiveCluster"
      keyspace = thehive
    }
  }
  index.search {
    backend = elasticsearch
    hostname = ["elasticsearch"]
    index-name = thehive
  }
}

# Storage configuration
storage {
  provider = s3
  s3 {
    bucket = "thehive"
    readTimeout = 1 minute
    writeTimeout = 1 minute
    chunkSize = 1 MB
    endpoint = "http://minio:9000"
    accessKey = "${MINIO_ROOT_USER:-minioadmin}"
    secretKey = "${MINIO_ROOT_PASSWORD:-minioadmin123}"
    region = "us-east-1"
  }
}

# Cortex integration
cortex {
  servers = [
    {
      name = "local"
      url = "http://cortex:9001"
      auth {
        type = "bearer"
        key = "${CORTEX_API_KEY:-changeme}"
      }
    }
  ]
}

# MISP integration
misp {
  servers = [
    {
      name = "MISP"
      url = "http://misp-core"
      auth {
        type = "key"
        key = "${MISP_API_KEY:-changeme}"
      }
      wsConfig {
        ssl.loose.acceptAnyCertificate = true
      }
    }
  ]
}

# Authentication
auth {
  providers = [
    { name = local }
  ]
}
EOF

    # Generate Cortex config
    cat > $BASE_DIR/configs/cortex/application.conf << 'EOF'
# Cortex Configuration
play.http.secret.key="${CORTEX_SECRET_KEY:-changeme}"

# Elasticsearch configuration
search {
  index = cortex
  uri = "http://elasticsearch:9200"
  user = "elastic"
  password = "${ELASTIC_PASSWORD:-elastic123}"
}

# Analyzer configuration
analyzer {
  path = ["/opt/cortex/analyzers"]
  fork-join-executor {
    parallelism-min = 2
    parallelism-factor = 2.0
    parallelism-max = 10
  }
}

# Responder configuration
responder {
  path = ["/opt/cortex/responders"]
}

# Job configuration
job {
  runner = ["docker"]
  directory = "/tmp/cortex-jobs"
}

# Docker configuration
docker {
  url = "unix:///var/run/docker.sock"
}
EOF

    # Generate Wazuh local rules
    cat > $BASE_DIR/configs/wazuh/local_rules.xml << 'EOF'
<!-- Local rules for OSINT SOC -->
<group name="osint,soc,">
  
  <!-- Rule for MISP IoC matches -->
  <rule id="100010" level="12">
    <if_sid>81618</if_sid>
    <list field="dstip" lookup="address_match_key">etc/lists/misp/misp_ips</list>
    <description>Connection to MISP-listed malicious IP: $(dstip)</description>
    <group>pci_dss_10.6.1,pci_dss_11.4,gdpr_IV_35.7.d,hipaa_164.312.b,nist_800_53_SI.4,tsc_CC6.1,tsc_CC6.8,tsc_CC7.2,tsc_CC7.3,</group>
  </rule>

  <rule id="100011" level="12">
    <if_sid>81615</if_sid>
    <list field="dstip" lookup="address_match_key">etc/lists/misp/misp_ips</list>
    <description>Connection to MISP-listed malicious IP: $(dstip)</description>
    <group>pci_dss_10.6.1,pci_dss_11.4,gdpr_IV_35.7.d,hipaa_164.312.b,nist_800_53_SI.4,tsc_CC6.1,tsc_CC6.8,tsc_CC7.2,tsc_CC7.3,</group>
  </rule>

  <!-- Rule for suspicious DNS queries -->
  <rule id="100020" level="10">
    <if_sid>533</if_sid>
    <list field="dns.query" lookup="match_key">etc/lists/misp/misp_domains</list>
    <description>DNS query to MISP-listed malicious domain: $(dns.query)</description>
    <group>pci_dss_10.6.1,pci_dss_11.4,gdpr_IV_35.7.d,hipaa_164.312.b,nist_800_53_SI.4,tsc_CC6.1,tsc_CC6.8,tsc_CC7.2,tsc_CC7.3,</group>
  </rule>

</group>
EOF

    # Create empty CDB lists
    touch $BASE_DIR/configs/wazuh/misp/misp_ips
    touch $BASE_DIR/configs/wazuh/misp/misp_domains
    touch $BASE_DIR/configs/wazuh/misp/misp_urls
    touch $BASE_DIR/configs/wazuh/misp/misp_md5

    # Generate Nginx config
    cat > $BASE_DIR/configs/nginx/nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    include /etc/nginx/sites-enabled/*;
    
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';
    
    access_log /var/log/nginx/access.log main;
    error_log /var/log/nginx/error.log warn;
}
EOF

    # Generate Nginx site configs
    cat > $BASE_DIR/configs/nginx/sites/thehive.conf << 'EOF'
server {
    listen 80;
    server_name thehive.*;
    
    location / {
        proxy_pass http://soc-thehive:9000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

    cat > $BASE_DIR/configs/nginx/sites/cortex.conf << 'EOF'
server {
    listen 80;
    server_name cortex.*;
    
    location / {
        proxy_pass http://soc-cortex:9001;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

    log_success "Configuration files generated"
}

# Copy Docker Compose files
copy_compose_files() {
    log_info "Copying Docker Compose files..."
    
    BASE_DIR="/opt/osint-soc"
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    # Copy from git repo if exists, otherwise create from template
    if [ -f "$SCRIPT_DIR/docker/docker-compose.infra.yml" ]; then
        cp $SCRIPT_DIR/docker/docker-compose.infra.yml $BASE_DIR/docker/
        cp $SCRIPT_DIR/docker/docker-compose.security.yml $BASE_DIR/docker/
        cp $SCRIPT_DIR/docker/docker-compose.osint.yml $BASE_DIR/docker/
    else
        log_warning "Docker Compose files not found in script directory."
        log_info "Please manually copy docker-compose files to $BASE_DIR/docker/"
    fi
    
    # Copy .env.example if .env doesn't exist
    if [ ! -f "$BASE_DIR/.env" ]; then
        if [ -f "$SCRIPT_DIR/.env.example" ]; then
            cp $SCRIPT_DIR/.env.example $BASE_DIR/.env
            log_warning "Please edit $BASE_DIR/.env with your configuration before starting services"
        fi
    fi
    
    log_success "Docker Compose files copied"
}

# Create helper scripts
create_helper_scripts() {
    log_info "Creating helper scripts..."
    
    BASE_DIR="/opt/osint-soc"
    
    # Health check script
    cat > $BASE_DIR/scripts/health-check.sh << 'EOF'
#!/bin/bash

echo "=== OSINT SOC Platform Health Check ==="
echo ""

# Colors
GREEN='\\033[0;32m'
RED='\\033[0;31m'
NC='\\033[0m'

check_service() {
    local name=$1
    local url=$2
    local expected_code=${3:-200}
    
    response=$(curl -s -o /dev/null -w "%{http_code}" $url 2>/dev/null || echo "000")
    
    if [ "$response" == "$expected_code" ] || [ "$response" == "302" ] || [ "$response" == "301" ]; then
        echo -e "${GREEN}✓${NC} $name is UP (HTTP $response)"
        return 0
    else
        echo -e "${RED}✗${NC} $name is DOWN (HTTP $response)"
        return 1
    fi
}

echo "Checking Infrastructure Services..."
check_service "Elasticsearch" "http://localhost:9200/_cluster/health" 401
check_service "MinIO" "http://localhost:9000/minio/health/live"
check_service "RabbitMQ" "http://localhost:15672" 200

echo ""
echo "Checking Security Tools..."
check_service "Wazuh Dashboard" "http://localhost:5601" 200
check_service "TheHive" "http://localhost:9000" 200
check_service "Cortex" "http://localhost:9001" 200

echo ""
echo "Checking OSINT Tools..."
check_service "MISP" "https://localhost:8443" 200
check_service "OpenCTI" "http://localhost:8080" 200
check_service "Shuffle" "http://localhost:3001" 200

echo ""
echo "Checking Docker Containers..."
docker ps --format "table {{.Names}}\\t{{.Status}}\\t{{.Ports}}" | grep soc- || echo "No SOC containers running"
EOF
    chmod +x $BASE_DIR/scripts/health-check.sh

    # Start script
    cat > $BASE_DIR/scripts/start.sh << 'EOF'
#!/bin/bash

BASE_DIR="/opt/osint-soc"
cd $BASE_DIR

echo "Starting OSINT SOC Platform..."

# Create network if it doesn't exist
docker network create soc-network 2>/dev/null || true

# Start infrastructure
echo "[1/3] Starting infrastructure services..."
docker-compose -f docker/docker-compose.infra.yml up -d

echo "Waiting for infrastructure to be ready (60s)..."
sleep 60

# Start security tools
echo "[2/3] Starting security tools..."
docker-compose -f docker/docker-compose.security.yml up -d

# Start OSINT tools
echo "[3/3] Starting OSINT tools..."
docker-compose -f docker/docker-compose.osint.yml up -d

echo ""
echo "All services started! Use ./scripts/health-check.sh to verify status."
echo ""
echo "Access your services:"
echo "  Wazuh Dashboard: http://localhost:5601"
echo "  TheHive:         http://localhost:9000"
echo "  Cortex:          http://localhost:9001"
echo "  MISP:            https://localhost:8443"
echo "  OpenCTI:         http://localhost:8080"
echo "  Shuffle:         http://localhost:3001"
EOF
    chmod +x $BASE_DIR/scripts/start.sh

    # Stop script
    cat > $BASE_DIR/scripts/stop.sh << 'EOF'
#!/bin/bash

BASE_DIR="/opt/osint-soc"
cd $BASE_DIR

echo "Stopping OSINT SOC Platform..."

docker-compose -f docker/docker-compose.osint.yml down
docker-compose -f docker/docker-compose.security.yml down
docker-compose -f docker/docker-compose.infra.yml down

echo "All services stopped."
EOF
    chmod +x $BASE_DIR/scripts/stop.sh

    # Backup script
    cat > $BASE_DIR/scripts/backup.sh << 'EOF'
#!/bin/bash

BASE_DIR="/opt/osint-soc"
BACKUP_DIR="/opt/osint-soc/backups/$(date +%Y%m%d_%H%M%S)"

mkdir -p $BACKUP_DIR

echo "Creating backup at $BACKUP_DIR..."

# Backup Docker volumes
docker run --rm -v osint-soc_elasticsearch_data:/data -v $BACKUP_DIR:/backup alpine tar czf /backup/elasticsearch.tar.gz -C /data . 2>/dev/null || echo "Skipping elasticsearch backup"
docker run --rm -v osint-soc_postgres_data:/data -v $BACKUP_DIR:/backup alpine tar czf /backup/postgres.tar.gz -C /data . 2>/dev/null || echo "Skipping postgres backup"
docker run --rm -v osint-soc_mysql_data:/data -v $BACKUP_DIR:/backup alpine tar czf /backup/mysql.tar.gz -C /data . 2>/dev/null || echo "Skipping mysql backup"
docker run --rm -v osint-soc_cassandra_data:/data -v $BACKUP_DIR:/backup alpine tar czf /backup/cassandra.tar.gz -C /data . 2>/dev/null || echo "Skipping cassandra backup"
docker run --rm -v osint-soc_minio_data:/data -v $BACKUP_DIR:/backup alpine tar czf /backup/minio.tar.gz -C /data . 2>/dev/null || echo "Skipping minio backup"

# Backup configs
cp -r $BASE_DIR/configs $BACKUP_DIR/ 2>/dev/null || echo "Skipping configs backup"
cp $BASE_DIR/.env $BACKUP_DIR/ 2>/dev/null || echo "Skipping .env backup"

echo "Backup completed: $BACKUP_DIR"
EOF
    chmod +x $BASE_DIR/scripts/backup.sh

    # Update MISP feeds script
    cat > $BASE_DIR/scripts/update-osint-feeds.sh << 'EOF'
#!/bin/bash

MISP_URL="https://localhost:8443"
API_KEY="${MISP_API_KEY}"
LOG_FILE="/var/log/osint-soc/misp-feeds.log"

mkdir -p $(dirname $LOG_FILE)

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a $LOG_FILE
}

if [ -z "$API_KEY" ]; then
    log "Error: MISP_API_KEY not set"
    exit 1
fi

log "Starting MISP feed update..."

# Get list of enabled feeds
FEEDS=$(curl -s -k -H "Authorization: $API_KEY" \
  -H "Accept: application/json" \
  "$MISP_URL/feeds/index" 2>/dev/null | jq -r '.[] | select(.Feed.enabled == true) | .Feed.id')

if [ -z "$FEEDS" ]; then
    log "No enabled feeds found"
    exit 0
fi

for feed_id in $FEEDS; do
    log "Updating feed ID: $feed_id"
    curl -s -k -X POST "$MISP_URL/feeds/fetchFromFeed/$feed_id" \
      -H "Authorization: $API_KEY" \
      -H "Accept: application/json" > /dev/null 2>&1
    sleep 5
done

log "MISP feed update completed"
EOF
    chmod +x $BASE_DIR/scripts/update-osint-feeds.sh

    # Update Wazuh CDB script
    cat > $BASE_DIR/scripts/update-wazuh-cdb.sh << 'EOF'
#!/bin/bash

MISP_URL="https://localhost:8443"
API_KEY="${MISP_API_KEY}"
OUTPUT_DIR="/opt/osint-soc/configs/wazuh/misp"

if [ -z "$API_KEY" ]; then
    echo "Error: MISP_API_KEY not set"
    exit 1
fi

mkdir -p $OUTPUT_DIR

echo "Fetching malicious IPs..."
curl -s -k -H "Authorization: $API_KEY" \
  -H "Accept: application/json" \
  "$MISP_URL/attributes/restSearch/json" \
  -d '{"type":"ip-dst","tags":"malicious","last":"30d"}' 2>/dev/null | \
  jq -r '.response.Attribute[].value' 2>/dev/null | sort -u > $OUTPUT_DIR/misp_ips

echo "Fetching malicious domains..."
curl -s -k -H "Authorization: $API_KEY" \
  "$MISP_URL/attributes/restSearch/json" \
  -d '{"type":"domain","tags":"malicious","last":"30d"}' 2>/dev/null | \
  jq -r '.response.Attribute[].value' 2>/dev/null | sort -u > $OUTPUT_DIR/misp_domains

echo "CDB lists updated in $OUTPUT_DIR"
EOF
    chmod +x $BASE_DIR/scripts/update-wazuh-cdb.sh

    log_success "Helper scripts created"
}

# Main installation function
main() {
    echo "==================================="
    echo "OSINT SOC Platform Installer"
    echo "==================================="
    echo ""
    
    check_root
    check_requirements
    install_dependencies
    install_docker
    setup_directories
    generate_configs
    copy_compose_files
    create_helper_scripts
    
    log_success "Installation completed!"
    echo ""
    echo "Next steps:"
    echo "1. Edit /opt/osint-soc/.env with your configuration"
    echo "   nano /opt/osint-soc/.env"
    echo ""
    echo "2. Start the platform:"
    echo "   cd /opt/osint-soc && ./scripts/start.sh"
    echo ""
    echo "3. Verify installation:"
    echo "   ./scripts/health-check.sh"
    echo ""
    echo "4. Access your services:"
    echo "   Wazuh Dashboard: http://localhost:5601 (admin/SecretPassword)"
    echo "   TheHive:         http://localhost:9000 (admin@thehive.local/secret)"
    echo "   Cortex:          http://localhost:9001"
    echo "   MISP:            https://localhost:8443 (admin@admin.test/admin)"
    echo "   OpenCTI:         http://localhost:8080 (admin@opencti.local/changeme)"
    echo "   Shuffle:         http://localhost:3001"
    echo ""
    echo "Documentation: https://github.com/YOUR_USERNAME/osint-soc-platform"
}

# Run main function
main
'''

with open(f"{base_dir}/install.sh", "w") as f:
    f.write(install_script)

os.chmod(f"{base_dir}/install.sh", 0o755)

print("✅ install.sh created and made executable")
