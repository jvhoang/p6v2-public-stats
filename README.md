The current README content with fixed JS parse in the embed example.

## Embed Code for GoDaddy (P6v2 Status table) - Strong Anti-Caching Version

... (keep the description)

```html
... same HTML ...

<script>
let refreshCount = 0;

function parseCDT(str) {
  if (!str) return null;
  // "2026-06-08 23:11:16 CDT" -> ISO with offset "2026-06-08T23:11:16-05:00"
  const parts = str.trim().split(/\s+/);
  if (parts.length < 2) return null;
  let iso = parts[0] + 'T' + parts[1];
  let offset = '-05:00'; // assume CDT
  if (str.toUpperCase().includes('CST')) offset = '-06:00';
  const dt = new Date(iso + offset);
  return isNaN(dt.getTime()) ? null : dt;
}

async function updateStatus() {
  const lastCheckedEl = document.getElementById('last-checked');
  try {
    refreshCount++;
    const bust = Date.now() + '_' + performance.now() + '_' + Math.random().toString(36).slice(2);
    const url = 'https://raw.githubusercontent.com/jvhoang/p6v2-public-stats/main/data/p6v2_total_transactions.json?bust=' + bust;
    
    const res = await fetch(url, {
      cache: 'reload',
      headers: {
        'Cache-Control': 'no-cache, no-store, must-revalidate, max-age=0',
        'Pragma': 'no-cache',
        'Expires': '0'
      }
    });
    
    if (!res.ok) throw new Error('Fetch failed: ' + res.status);
    
    const data = await res.json();
    
    document.getElementById('last-updated').textContent = data.last_updated || 'N/A';
    document.getElementById('total-transactions').textContent = data.total_transactions ?? 'N/A';
    document.getElementById('open-transactions').textContent = data.open_transactions ?? 'N/A';
    document.getElementById('dtbp-usage').textContent = data.dtbp_usage || 'N/A';
    document.getElementById('vix').textContent = data.vix || 'N/A';
    
    // Color the Last updated cell
    const lastCell = document.getElementById('last-updated');
    const updatedStr = data.last_updated;
    const updatedTime = parseCDT(updatedStr);
    if (updatedTime) {
      const diffSec = (new Date().getTime() - updatedTime.getTime()) / 1000;
      if (diffSec < 80) {
        lastCell.style.backgroundColor = '#90EE90';
        lastCell.style.color = '#006400';
      } else if (diffSec < 180) {
        lastCell.style.backgroundColor = '#FFFACD';
        lastCell.style.color = '#333';
      } else {
        lastCell.style.backgroundColor = '#FFB6C1';
        lastCell.style.color = '#8B0000';
      }
    } else {
      // parse failed - fall back to red
      lastCell.style.backgroundColor = '#FFB6C1';
      lastCell.style.color = '#8B0000';
    }
    
    if (lastCheckedEl) {
      lastCheckedEl.textContent = 'Last checked: ' + new Date().toLocaleTimeString();
    }
    
    console.log('P6v2 status updated (poll #' + refreshCount + '), diffSec=' + (updatedTime ? ((new Date().getTime() - updatedTime.getTime())/1000).toFixed(1) : 'NaN'));
  } catch (e) {
    console.error('P6v2 status fetch error:', e);
    const cells = ['last-updated', 'total-transactions', 'open-transactions', 'dtbp-usage', 'vix'];
    cells.forEach(id => {
      const el = document.getElementById(id);
      if (el) el.textContent = 'N/A';
    });
    if (lastCheckedEl) lastCheckedEl.textContent = 'Error fetching data';
  }
  setTimeout(updateStatus, 15000);
}

function forceRefresh() {
  console.log('Force refresh triggered');
  updateStatus();
}

updateStatus();
</script>
```

## Why the cell was red even when fresh

The previous parse `new Date(updatedStr.replace(' CDT', ' GMT-0500'))` often produced an **Invalid Date** (NaN) because JavaScript's Date constructor is very picky about string formats. Non-ISO strings with spaces and timezone abbreviations like "GMT-0500" fail in many browsers, leading to NaN diffSec, which always fell through to the `else` (light red) branch.

The fix uses a proper ISO-8601 string with explicit offset (`2026-...T...-05:00`), which parses reliably to the correct absolute time. Then diffSec is computed against Date.now().

Also added a fallback to red only on parse failure, and console.log to help debug the actual diffSec.

Copy the new block above into your GoDaddy embed, publish, hard refresh. It should now correctly show green when the timestamp is recent.

If still red, open browser dev tools console while on the page and look for the logged diffSec value.
