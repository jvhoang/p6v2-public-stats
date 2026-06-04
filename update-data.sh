#!/bin/bash
# Helper to sync p6v2 total tx data from the main trading Data/ dir into this repo and commit/push.
# Run this after your autotrade has written the latest to Data/p6v2_total_transactions.*

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="${SCRIPT_DIR}/data"
SOURCE_DIR="/Users/johnhoang/Library/CloudStorage/OneDrive-Personal/FW/TDA/Schwab/Data"   # adjust if your path differs (use the JOS or JVH path)

echo "Copying latest tx files from ${SOURCE_DIR} to ${DATA_DIR}..."
cp -f "${SOURCE_DIR}/p6v2_total_transactions.txt" "${DATA_DIR}/" || { echo "txt not found"; exit 1; }
cp -f "${SOURCE_DIR}/p6v2_total_transactions.json" "${DATA_DIR}/" || { echo "json not found"; exit 1; }

cd "${SCRIPT_DIR}"
git add data/p6v2_total_transactions.*

if git diff --cached --quiet; then
  echo "No changes to commit."
  exit 0
fi

MSG="Update total transactions $(date '+%Y-%m-%d %H:%M')"
git commit -m "$MSG"

echo "Pushing to origin main..."
git push origin main

echo "Done. Raw URLs:"
echo "  https://raw.githubusercontent.com/jvhoang/p6v2-public-stats/main/data/p6v2_total_transactions.txt"
echo "  https://raw.githubusercontent.com/jvhoang/p6v2-public-stats/main/data/p6v2_total_transactions.json"
