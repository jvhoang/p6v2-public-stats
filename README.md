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

```bash
# One-time setup (do this once)
git clone https://github.com/jvhoang/p6v2-public-stats.git ~/p6v2-public-stats
cd ~/p6v2-public-stats

# Set your git identity if not already global
# git config --global user.name "Your Name"
# git config --global user.email "you@example.com"

# For HTTPS auth (easiest for beginners):
# 1. Go to GitHub > Settings > Developer settings > Personal access tokens > Tokens (classic)
# 2. Generate a token with 'repo' scope
# 3. When pushing, use your token as the password (or cache it with git credential helper)

# Then, to update after your trading script writes the local Data/ file:
cp /path/to/your/Data/p6v2_total_transactions.* data/
git add data/
git commit -m "Update total transactions: $(date +%Y-%m-%d)"
git push origin main
```

### Alternative (if you have gh CLI installed):
```bash
gh repo clone jvhoang/p6v2-public-stats ~/p6v2-public-stats
# ... edit ...
gh repo sync   # or normal git push
```

### From within this Grok environment (direct API, no local clone needed)

Ask me (the AI) to update a specific file using the integrated GitHub tools, e.g. provide the new content for data/p6v2_total_transactions.json and I'll commit it directly.

## Automation ideas

In your P6v2_autotrade.R (inside the counter if-block after computing total_transactions):

```r
# after computing total_transactions
writeLines(as.character(total_transactions), paste0(wd2, "Data/p6v2_total_transactions.txt"))
# similarly for json

# Then optionally auto-copy + commit if the clone exists
if (dir.exists("~/p6v2-public-stats")) {
  file.copy(..., "~/p6v2-public-stats/data/", overwrite=TRUE)
  system("cd ~/p6v2-public-stats && git add data/ && git commit -m 'auto update tx' && git push")
}
```

(You would still need to handle auth for the push, e.g. ssh key or token in env.)
