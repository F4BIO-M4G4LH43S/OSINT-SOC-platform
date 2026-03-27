
# Create a comprehensive setup verification script
verify_script = '''#!/bin/bash

# OSINT SOC Platform - Setup Verification Script
# Run this after installation to verify everything is working

set -e

RED='\\033[0;31m'
GREEN='\\033[0;32m'
YELLOW='\\033[1;33m'
BLUE='\\033[0;34m'
NC='\\033[0m'

PASS=0
FAIL=0

test_pass() {
    echo -e "${GREEN}✓ PASS${NC}: $1"
    ((PASS++))
}

test_fail() {
    echo -e "${RED}✗ FAIL${NC}: $1"
    ((FAIL++))
}

test_info() {
    echo -e "${BLUE}ℹ INFO${NC}: $1"
}

echo "==================================="
echo "OSINT SOC Platform - Setup Verification"
echo "==================================="
echo ""

# Test 1: Check Docker
echo "[1/10] Checking Docker installation..."
if command -v docker &> /dev/null; then
    test_pass "Docker is installed ($(docker --version))"
else
    test_fail "Docker is not installed"
fi

# Test 2: Check Docker Compose
echo "[2/10] Checking Docker Compose..."
if docker compose version &> /dev/null; then
    test_pass "Docker Compose is installed"
else
    test_fail "Docker Compose is not installed"
fi

# Test 3: Check directory structure
echo "[3/10] Checking directory structure..."
if [ -d "/opt/osint-soc" ]; then
    test_pass "Base directory exists (/opt/osint-soc)"
else
    test_fail "Base directory missing"
fi

if [ -f "/opt/osint-soc/.env" ]; then
    test_pass "Environment file exists"
else
    test_fail "Environment file missing"
fi

# Test 4: Check Docker network
echo "[4/10] Checking Docker network..."
if docker network ls | grep -q "soc-network"; then
    test_pass "Docker network 'soc-network' exists"
else
    test_fail "Docker network 'soc-network' missing"
fi

# Test 5: Check running containers
echo "[5/10] Checking running containers..."
RUNNING=$(docker ps --filter "name=soc-" --format "{{.Names}}" | wc -l)
if [ "$RUNNING" -gt 0 ]; then
    test_pass "$RUNNING SOC containers are running"
    docker ps --filter "name=soc-" --format "  - {{.Names}} ({{.Status}})"
else
    test_fail "No SOC containers running"
fi

# Test 6: Check Elasticsearch
echo "[6/10] Checking Elasticsearch..."
if curl -s -u elastic:${ELASTIC_PASSWORD:-elastic123} http://localhost:9200/_cluster/health > /dev/null 2>&1; then
    test_pass "Elasticsearch is responding"
else
    test_fail "Elasticsearch not responding"
fi

# Test 7: Check Wazuh Dashboard
echo "[7/10] Checking Wazuh Dashboard..."
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:5601 2>/dev/null || echo "000")
if [ "$RESPONSE" == "200" ] || [ "$RESPONSE" == "302" ] || [ "$RESPONSE" == "401" ]; then
    test_pass "Wazuh Dashboard is accessible (HTTP $RESPONSE)"
else
    test_fail "Wazuh Dashboard not accessible (HTTP $RESPONSE)"
fi

# Test 8: Check TheHive
echo "[8/10] Checking TheHive..."
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:9000 2>/dev/null || echo "000")
if [ "$RESPONSE" == "200" ] || [ "$RESPONSE" == "302" ]; then
    test_pass "TheHive is accessible (HTTP $RESPONSE)"
else
    test_fail "TheHive not accessible (HTTP $RESPONSE)"
fi

# Test 9: Check MISP
echo "[9/10] Checking MISP..."
RESPONSE=$(curl -s -k -o /dev/null -w "%{http_code}" https://localhost:8443 2>/dev/null || echo "000")
if [ "$RESPONSE" == "200" ] || [ "$RESPONSE" == "302" ] || [ "$RESPONSE" == "403" ]; then
    test_pass "MISP is accessible (HTTP $RESPONSE)"
else
    test_fail "MISP not accessible (HTTP $RESPONSE)"
fi

# Test 10: Check OpenCTI
echo "[10/10] Checking OpenCTI..."
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 2>/dev/null || echo "000")
if [ "$RESPONSE" == "200" ] || [ "$RESPONSE" == "302" ]; then
    test_pass "OpenCTI is accessible (HTTP $RESPONSE)"
else
    test_fail "OpenCTI not accessible (HTTP $RESPONSE)"
fi

# Summary
echo ""
echo "==================================="
echo "Verification Summary"
echo "==================================="
echo -e "${GREEN}Passed: $PASS${NC}"
echo -e "${RED}Failed: $FAIL${NC}"
echo ""

if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed! Your OSINT SOC Platform is ready.${NC}"
    echo ""
    echo "Access your services:"
    echo "  Wazuh Dashboard: http://localhost:5601"
    echo "  TheHive:         http://localhost:9000"
    echo "  Cortex:          http://localhost:9001"
    echo "  MISP:            https://localhost:8443"
    echo "  OpenCTI:         http://localhost:8080"
    echo "  Shuffle:         http://localhost:3001"
    exit 0
else
    echo -e "${YELLOW}⚠ Some tests failed. Check the logs above.${NC}"
    echo ""
    echo "Troubleshooting tips:"
    echo "  1. Wait a few minutes for services to fully start"
    echo "  2. Check logs: docker logs <container_name>"
    echo "  3. Restart services: cd /opt/osint-soc && ./scripts/stop.sh && ./scripts/start.sh"
    exit 1
fi
'''

with open(f"{base_dir}/scripts/verify-setup.sh", "w") as f:
    f.write(verify_script)

os.chmod(f"{base_dir}/scripts/verify-setup.sh", 0o755)

print("✅ scripts/verify-setup.sh created")
