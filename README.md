# p6v2-public-stats

Public data files for Phase 6 v2 trading stats (Final Worth LLC).

Used to power dynamic content on https://finalworth.com/p6v2-total-transactions and similar pages.

## Data files

- `data/p6v2_total_transactions.json` - Current total transactions (updated during market hours)
- `data/p6v2_total_transactions.txt` - Plain number version for easy fetch

## Raw URLs (for embedding in website)

- JSON: https://raw.githubusercontent.com/jvhoang/p6v2-public-stats/main/data/p6v2_total_transactions.json
- TXT: https://raw.githubusercontent.com/jvhoang/p6v2-public-stats/main/data/p6v2_total_transactions.txt

## Usage

These files are fetched via raw GitHub URLs from the website using JavaScript embeds in GoDaddy Website Builder.

**Do not commit sensitive data here.**

Last updated via automated process from trading scripts.

## How to commit / update files (for the data owner)

### Recommended: Local git clone (run on your Mac)

A clone has already been set up for you at `/Users/johnhoang/p6v2-public-stats` (outside OneDrive to keep git clean).

```bash
# If you need to re-clone:
# git clone https://github.com/jvhoang/p6v2-public-stats.git ~/p6v2-public-stats

cd ~/p6v2-public-stats

# Make the helper executable (if needed)
chmod +x update-data.sh

# IMPORTANT: Set up authentication for push (one time)
# Option 1: Personal Access Token (PAT)
#   - GitHub Settings > Developer settings > Personal access tokens > Tokens (classic) > Generate new with 'repo' scope
#   - Then: git remote set-url origin https://jvhoang:YOUR_TOKEN@github.com/jvhoang/p6v2-public-stats.git
#   - Or use git credential helper: git config --global credential.helper osxkeychain (then it will prompt once)
#
# Option 2: SSH (recommended if you have keys)
#   - Add your public key to GitHub, then: git remote set-url origin git@github.com:jvhoang/p6v2-public-stats.git

# To update data: after your R script has written the latest values to the main Data/ folder, just run:
./update-data.sh
```

The helper copies the files, commits with timestamp, and pushes.

### From within this Grok environment (direct API, no local clone or auth needed here)

Just tell me the new value (or I can read the local Data/ file) and I'll use the integrated tools to commit directly to the repo (as done for the initial 4626 value).

## Automation ideas

Add to your P6v2_autotrade.R inside the if-block (after computing total_transactions and writing the local Data/ files):

```r
# optional auto update of public repo
if (file.exists("~/p6v2-public-stats/update-data.sh")) {
  system("cd ~/p6v2-public-stats && ./update-data.sh", ignore.stdout = FALSE, ignore.stderr = FALSE)
}
```

(Requires that you have authenticated git push working non-interactively, e.g. via ssh key + agent.)

See the update-data.sh for details.
