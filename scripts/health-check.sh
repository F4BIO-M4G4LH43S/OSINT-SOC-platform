#!/bin/bash
# Health check script for OSINT SOC Platform

echo "=========================================="
echo "OSINT SOC Platform Health Check"
echo "=========================================="

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

check_service() {
    local name=$1
    local url=$2
    local expected_status=${3:-200}
    
    echo -n "Checking $name... "
    
    status=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null || echo "000")
    
    if [ "$status" == "$expected_status" ] || [ "$status" == "302" ] || [ "$status" == "301" ]; then
        echo -e "${GREEN}✓ UP${NC} (HTTP $status)"
        return 0
    else
        echo -e "${RED}✗ DOWN${NC} (HTTP $status)"
        return 1
    fi
}

check_docker() {
    echo -n "Checking Docker service... "
    if systemctl is-active --quiet docker; then
        echo -e "${GREEN}✓ Running${NC}"
    else
        echo -e "${RED}✗ Not running${NC}"
    fi
}

echo "[1/4] Checking Docker status..."
check_docker

echo ""
echo "[2/4] Checking container status..."
docker compose ps

echo ""
echo "[3/4] Checking service endpoints..."

# Wait a moment for services to respond
sleep 2

check_service "Wazuh Dashboard" "https://localhost" "200"
check_service "MISP" "http://localhost:8081" "200"
check_service "TheHive" "http://localhost:9000" "200"
check_service "Cortex" "http://localhost:9001" "200"
check_service "Shuffle" "http://localhost:3001" "200"
check_service "OpenCTI" "http://localhost:8080" "200"

echo ""
echo "[4/4] Checking resource usage..."
echo "Docker stats (top 10):"
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.Status}}" | head -11

echo ""
echo "=========================================="
echo "Health check completed"
echo "=========================================="
echo ""
echo "Troubleshooting tips:"
echo "  - If services show DOWN, wait 2-3 minutes for full startup"
echo "  - Check logs: sudo docker compose logs -f [service-name]"
echo "  - Restart service: sudo docker compose restart [service-name]"
echo ""
