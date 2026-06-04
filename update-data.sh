#!/bin/bash
# Helper to sync p6v2 total tx data from the main trading Data/ dir into this repo and commit/push.
# Run this after your autotrade has written the latest to Data/p6v2_total_transactions.*
# For automation from R script, make sure git push works non-interactively (ssh key or cached credential).

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="${SCRIPT_DIR}/data"

# Possible source dirs (match the wd2 logic in the R scripts)
POSSIBLE_SOURCES=(
  "/Users/johnhoang/Library/CloudStorage/OneDrive-Personal/FW/TDA/Schwab/Data"
  "/Users/johnhoang/OneDrive/FW/TDA/Schwab/Data"
  "//JKVH7/Users/jhoang/OneDrive/FW/TDA/Schwab/Data"
  "//JKVH1/Users/jhoang/OneDrive/FW/TDA/Schwab/Data"
)

SOURCE_DIR=""
for s in "${POSSIBLE_SOURCES[@]}"; do
  if [ -f "$s/p6v2_total_transactions.txt" ]; then
    SOURCE_DIR="$s"
    break
  fi
done

if [ -z "$SOURCE_DIR" ]; then
  echo "No source Data/ with p6v2_total_transactions.* found in known locations."
  exit 1
fi

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

echo "Commit created. Attempting push..."
set +e
git push origin main
PUSH_EXIT=$?
set -e

if [ $PUSH_EXIT -ne 0 ]; then
  echo "WARNING: git push failed (exit $PUSH_EXIT)."
  echo "You may need to set up non-interactive auth once:"
  echo "  git remote set-url origin https://jvhoang:YOUR_GITHUB_PAT@github.com/jvhoang/p6v2-public-stats.git"
  echo "  or use ssh key: git remote set-url origin git@github.com:jvhoang/p6v2-public-stats.git"
  echo "After setup, re-run this script or 'git push origin main'"
fi

echo "Done. Raw URLs:"
echo "  https://raw.githubusercontent.com/jvhoang/p6v2-public-stats/main/data/p6v2_total_transactions.txt"
echo "  https://raw.githubusercontent.com/jvhoang/p6v2-public-stats/main/data/p6v2_total_transactions.json"
