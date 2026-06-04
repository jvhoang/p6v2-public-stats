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

# BEST for R script automation: use PAT file (no prompts, token not in gitconfig)
# 1. Generate PAT: https://github.com/settings/tokens (classic, scope=repo)
# 2. echo 'ghp_yourtoken' > ~/.p6v2_github_pat
# 3. chmod 600 ~/.p6v2_github_pat
# The helper will use it only for push then restore the plain remote URL.

# To update data from terminal or script: after R has written to Data/ folder, just run:
./update-data.sh
```

The helper now supports the PAT file for fully non-interactive use from your R autotrade script.

### From within this Grok environment

Just tell me the new value and I'll push directly.

## Automation in P6v2_autotrade.R

The integration code (write files + call helper) is already inside the if-block in your P6v2_autotrade.R .

It triggers on the same schedule as the doublecheck.

See the .PAT_SETUP_INSTRUCTIONS.txt in the clone for details, and ~/p6v2_update.log for output from runs.

(After setting up the PAT file, the R system() call will update GitHub without any prompts.)
