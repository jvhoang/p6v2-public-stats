#!/bin/bash
# Helper to sync p6v2 total tx data from the main trading Data/ dir into this repo and commit.
# Run this after your autotrade has written the latest to Data/p6v2_total_transactions.*
# After running, do the push manually once you have git auth set up.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="${SCRIPT_DIR}/data"
# Adjust SOURCE_DIR for your setup (the cloud one or the //JKVH one)
SOURCE_DIR="/Users/johnhoang/Library/CloudStorage/OneDrive-Personal/FW/TDA/Schwab/Data"

echo "Copying latest tx files from ${SOURCE_DIR} to ${DATA_DIR}..."
cp -f "${SOURCE_DIR}/p6v2_total_transactions.txt" "${DATA_DIR}/" || { echo "txt not found in source"; exit 1; }
cp -f "${SOURCE_DIR}/p6v2_total_transactions.json" "${DATA_DIR}/" || { echo "json not found in source"; exit 1; }

cd "${SCRIPT_DIR}"
git add data/p6v2_total_transactions.*

if git diff --cached --quiet; then
  echo "No changes to commit (already up to date)."
  exit 0
fi

MSG="Update total transactions $(date '+%Y-%m-%d %H:%M:%S')"
git commit -m "$MSG"

echo ""
echo "Local commit created successfully."
echo "To publish, run: git push origin main"
echo "(You may need to set up credentials first time -- see README.md in this repo for PAT or SSH instructions.)"
echo ""
echo "After push, the live data will be at:"
echo "  https://raw.githubusercontent.com/jvhoang/p6v2-public-stats/main/data/p6v2_total_transactions.txt"
echo "  https://raw.githubusercontent.com/jvhoang/p6v2-public-stats/main/data/p6v2_total_transactions.json"
