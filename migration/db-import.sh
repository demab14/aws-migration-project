#!/usr/bin/env bash
# Run this ON THE EC2 WORDPRESS INSTANCE. Pulls the dump down from S3
# and imports it into RDS. The Ansible wordpress role does this
# automatically as part of the playbook, but it's useful to be able
# to run this by hand while debugging.

set -euo pipefail

DUMP_FILE="wordpress_dump.sql"
S3_BUCKET="${MIGRATION_BUCKET:?Set MIGRATION_BUCKET env var}"
RDS_ENDPOINT="${RDS_ENDPOINT:?Set RDS_ENDPOINT env var}"
DB_NAME="${DB_NAME:-wordpress}"
DB_USER="${DB_USERNAME:?Set DB_USERNAME env var}"
DB_PASS="${DB_PASSWORD:?Set DB_PASSWORD env var}"

echo "==> Pulling dump from s3://${S3_BUCKET}/${DUMP_FILE}"
aws s3 cp "s3://${S3_BUCKET}/${DUMP_FILE}" "/tmp/${DUMP_FILE}"

echo "==> Importing into RDS at ${RDS_ENDPOINT}"
mysql -h "${RDS_ENDPOINT}" -u "${DB_USER}" -p"${DB_PASS}" "${DB_NAME}" < "/tmp/${DUMP_FILE}"

echo "==> Cleaning up local dump file"
rm -f "/tmp/${DUMP_FILE}"

echo "==> Import complete. Verify with: mysql -h ${RDS_ENDPOINT} -u ${DB_USER} -p -e 'SHOW TABLES;' ${DB_NAME}"
