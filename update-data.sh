#!/bin/bash
# Helper to sync p6v2 total tx data from the main trading Data/ dir into this repo and commit/push.
# For non-interactive auth from scripts: put your GitHub PAT (with repo scope) in ~/.p6v2_github_pat (chmod 600)
# The PAT will be used only for the push, then remote restored to safe https.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="${SCRIPT_DIR}/data"

# Optional first argument: SOURCE_DIR to copy from (e.g. your private Data/ dir)
# If not provided, assumes the files are already in data/ (e.g. written directly by your R script)
if [ $# -ge 1 ]; then
  SOURCE_DIR="$1"
  if [ -z "$SOURCE_DIR" ] || [ ! -f "$SOURCE_DIR/p6v2_total_transactions.txt" ]; then
    echo "Invalid or missing SOURCE_DIR with p6v2_total_transactions.*"
    exit 1
  fi
  echo "Copying from ${SOURCE_DIR} ..."
  cp -f "${SOURCE_DIR}/p6v2_total_transactions.txt" "${DATA_DIR}/" || { echo "txt not found"; exit 1; }
  cp -f "${SOURCE_DIR}/p6v2_total_transactions.json" "${DATA_DIR}/" || { echo "json not found"; exit 1; }
fi

cd "${SCRIPT_DIR}"
git add data/p6v2_total_transactions.*

if git diff --cached --quiet; then
  echo "No changes."
  exit 0
fi

MSG="Update total transactions $(date '+%Y-%m-%d %H:%M:%S')"
git commit -m "$MSG"

echo "Commit created. Preparing push..."

# Save original remote
ORIG_REMOTE=$(git config --get remote.origin.url)

# If PAT file exists, temporarily rewrite remote with token for push (no prompt)
PAT_FILE="$HOME/.p6v2_github_pat"
if [ -f "$PAT_FILE" ]; then
  TOKEN=$(cat "$PAT_FILE" | tr -d '\n\r')
  SAFE_REMOTE="https://jvhoang:${TOKEN}@github.com/jvhoang/p6v2-public-stats.git"
  git remote set-url origin "$SAFE_REMOTE"
  echo "Using PAT from $PAT_FILE for push (token not logged)."
else
  echo "No $PAT_FILE found. Will use cached credential or prompt (may fail in non-tty)."
fi

set +e
git push origin main
PUSH_EXIT=$?
set -e

# Always restore the safe remote (without token)
git remote set-url origin "$ORIG_REMOTE"

if [ $PUSH_EXIT -ne 0 ]; then
  echo "WARNING: git push failed (exit $PUSH_EXIT)."
  echo "To fix permanently:"
  echo "  1. Generate PAT at https://github.com/settings/tokens (classic, 'repo' scope)"
  echo "  2. echo 'YOUR_PAT_HERE' > ~/.p6v2_github_pat"
  echo "  3. chmod 600 ~/.p6v2_github_pat"
  echo "  4. Re-run this script."
else
  echo "Push successful."
fi

echo "Done. Check https://raw.githubusercontent.com/jvhoang/p6v2-public-stats/main/data/p6v2_total_transactions.txt"
