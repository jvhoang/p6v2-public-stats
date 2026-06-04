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

## Important: Expected lag on the website

There is typically a **several-minute delay** (up to ~5 minutes) before changes appear when you view the page at finalworth.com.

Reasons:
- GitHub's raw.githubusercontent.com (and its Fastly CDN) caches files with `max-age=300` (5 minutes). You will often see `x-cache: HIT` and increasing `source-age`.
- Your GoDaddy page has its own short cache (30s).
- The JS embed does a one-time fetch on page load. It does **not** auto-refresh the number while the tab is open.
- The R script only triggers the update every ~10 minutes.

To see updates faster:
- Hard refresh the browser (Cmd/Ctrl + Shift + R) after the script runs.
- The number will become visible once GitHub's cache expires for that file.

Recommended improved embed code (add polling + cache buster):

```html
<div style="font-size: 64px; font-weight: bold; text-align: center; color: #006400;" id="tx-count">
  Loading...
</div>
<div style="text-align: center; font-size: 14px; color: #666;">
  Updated: <span id="tx-updated"></span>
</div>

<script>
(async function updateTx() {
  const countEl = document.getElementById('tx-count');
  const updatedEl = document.getElementById('tx-updated');
  try {
    const url = 'https://raw.githubusercontent.com/jvhoang/p6v2-public-stats/main/data/p6v2_total_transactions.json?t=' + Date.now();
    const res = await fetch(url, { cache: 'no-store' });
    const data = await res.json();
    countEl.textContent = data.total_transactions ?? 'N/A';
    updatedEl.textContent = data.updated || '';
  } catch (e) {
    console.error(e);
    if (!countEl.textContent || countEl.textContent === 'Loading...') countEl.textContent = 'N/A';
  }
  // Poll every 60s so you see the update without a full page refresh once GitHub cache expires
  setTimeout(updateTx, 60000);
})();
</script>
```

## How to commit / update files (for the data owner)

### Recommended: Local git clone (run on your Mac)

Clone the repo to a convenient location on your machine (e.g. outside synced folders like OneDrive for clean git):

```bash
git clone https://github.com/jvhoang/p6v2-public-stats.git ~/p6v2-public-stats

cd ~/p6v2-public-stats

# Make the helper executable (if needed)
chmod +x update-data.sh

# For R script automation: use a PAT file (no prompts, token not in gitconfig)
# 1. Generate PAT at https://github.com/settings/tokens (classic, scope=repo)
# 2. echo 'ghp_yourtoken' > ~/.p6v2_github_pat
# 3. chmod 600 ~/.p6v2_github_pat
# The helper will use it only for push then restore the plain remote URL.

# To update data: after your R script (or other process) has written the stats files into the clone's data/ folder, just run:
./update-data.sh
```

The helper supports optional SOURCE_DIR as first argument for copy (keep your personal paths in your private calling script only). It also supports the PAT file for fully non-interactive use.

### From within this Grok environment

Just tell me the new value and I'll push directly.

## Automation in P6v2_autotrade.R

The integration code (write files to your local Data/ + to the public clone's data/ + call helper) can be added inside the relevant if-blocks in your P6v2_autotrade.R .

It triggers on the same schedule as the doublecheck.

See ~/p6v2_update.log for output from runs.

(After setting up the PAT file, the R system() call will update GitHub without any prompts.)
