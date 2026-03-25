#!/bin/bash
# Generate secure secrets for OSINT SOC Platform

set -e

echo "=========================================="
echo "Generating Secure Secrets"
echo "=========================================="

ENV_FILE=".env"
ENV_EXAMPLE=".env.example"

# Check if .env already exists
if [ -f "$ENV_FILE" ]; then
    read -p ".env file already exists. Overwrite? (y/N): " confirm
    if [[ $confirm != [yY] ]]; then
        echo "Keeping existing .env file"
        exit 0
    fi
fi

# Copy example file
cp "$ENV_EXAMPLE" "$ENV_FILE"

echo "[1/4] Generating UUIDs for OpenCTI..."

# Generate UUIDs
OPENCTI_ADMIN_TOKEN=$(cat /proc/sys/kernel/random/uuid)
OPENCTI_HEALTHCHECK_KEY=$(cat /proc/sys/kernel/random/uuid)
CONNECTOR_OPENCTI=$(cat /proc/sys/kernel/random/uuid)
CONNECTOR_MITRE=$(cat /proc/sys/kernel/random/uuid)
CONNECTOR_EXPORT_STIX=$(cat /proc/sys/kernel/random/uuid)
CONNECTOR_EXPORT_CSV=$(cat /proc/sys/kernel/random/uuid)
CONNECTOR_EXPORT_TXT=$(cat /proc/sys/kernel/random/uuid)
CONNECTOR_IMPORT_STIX=$(cat /proc/sys/kernel/random/uuid)
CONNECTOR_IMPORT_DOC=$(cat /proc/sys/kernel/random/uuid)

# Generate encryption key
ENCRYPTION_KEY=$(openssl rand -base64 32)

echo "[2/4] Updating .env file..."

# Replace tokens in .env file
sed -i "s/OPENCTI_ADMIN_TOKEN=GENERATE_UUID_V4/OPENCTI_ADMIN_TOKEN=$OPENCTI_ADMIN_TOKEN/g" "$ENV_FILE"
sed -i "s/OPENCTI_HEALTHCHECK_ACCESS_KEY=GENERATE_UUID_V4/OPENCTI_HEALTHCHECK_ACCESS_KEY=$OPENCTI_HEALTHCHECK_KEY/g" "$ENV_FILE"
sed -i "s/OPENCTI_ENCRYPTION_KEY=GENERATE_BASE64_32/OPENCTI_ENCRYPTION_KEY=$ENCRYPTION_KEY/g" "$ENV_FILE"

# Update connector IDs
sed -i "s/CONNECTOR_OPENCTI_ID=.*/CONNECTOR_OPENCTI_ID=$CONNECTOR_OPENCTI/g" "$ENV_FILE"
sed -i "s/CONNECTOR_MITRE_ID=.*/CONNECTOR_MITRE_ID=$CONNECTOR_MITRE/g" "$ENV_FILE"
sed -i "s/CONNECTOR_EXPORT_FILE_STIX_ID=.*/CONNECTOR_EXPORT_FILE_STIX_ID=$CONNECTOR_EXPORT_STIX/g" "$ENV_FILE"
sed -i "s/CONNECTOR_EXPORT_FILE_CSV_ID=.*/CONNECTOR_EXPORT_FILE_CSV_ID=$CONNECTOR_EXPORT_CSV/g" "$ENV_FILE"
sed -i "s/CONNECTOR_EXPORT_FILE_TXT_ID=.*/CONNECTOR_EXPORT_FILE_TXT_ID=$CONNECTOR_EXPORT_TXT/g" "$ENV_FILE"
sed -i "s/CONNECTOR_IMPORT_FILE_STIX_ID=.*/CONNECTOR_IMPORT_FILE_STIX_ID=$CONNECTOR_IMPORT_STIX/g" "$ENV_FILE"
sed -i "s/CONNECTOR_IMPORT_DOCUMENT_ID=.*/CONNECTOR_IMPORT_DOCUMENT_ID=$CONNECTOR_IMPORT_DOC/g" "$ENV_FILE"

echo "[3/4] Setting permissions..."
chmod 600 "$ENV_FILE"

echo "[4/4] Secrets generated successfully!"
echo ""
echo "IMPORTANT: Edit $ENV_FILE and customize:"
echo "  - Passwords (change all 'ChangeMe' values)"
echo "  - Email addresses"
echo "  - Organization details"
echo "  - Base URLs"
echo ""
echo "Critical secrets generated:"
echo "  - OpenCTI Admin Token: $OPENCTI_ADMIN_TOKEN"
echo "  - Encryption Key: [HIDDEN]"
echo ""
