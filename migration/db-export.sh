#!/usr/bin/env bash
# Run this on the LEGACY server that hosts the old MySQL database.
# Produces a consistent dump and uploads it straight to S3, which is
# the handoff point for the rest of the migration (S3 -> EC2 -> RDS).

set -euo pipefail

DB_NAME="${DB_NAME:-wordpress}"
DB_USER="${DB_USER:-root}"
DUMP_FILE="wordpress_dump.sql"
S3_BUCKET="${MIGRATION_BUCKET:?Set MIGRATION_BUCKET env var}"

echo "==> Exporting ${DB_NAME} with mysqldump..."
mysqldump \
  --single-transaction \
  --quick \
  --routines \
  --triggers \
  -u "${DB_USER}" -p \
  "${DB_NAME}" > "${DUMP_FILE}"

echo "==> Uploading dump to s3://${S3_BUCKET}/${DUMP_FILE}"
aws s3 cp "${DUMP_FILE}" "s3://${S3_BUCKET}/${DUMP_FILE}"

echo "==> Done. Dump is now sitting in S3, ready for the EC2 -> RDS import step."
