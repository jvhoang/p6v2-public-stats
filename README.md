# p6v2-public-stats

Public data files for Phase 6 v2 trading stats (Final Worth LLC).

Used to power dynamic content on https://finalworth.com/p6v2-status (previously /p6v2-total-transactions).

## Data files

- `data/p6v2_total_transactions.json` - Status object with last_updated, total_transactions, open_transactions, dtbp_usage, vix
- `data/p6v2_total_transactions.txt` and .csv - Total transactions only (for internal use)

## Raw URLs (for embedding in website)

- JSON: https://raw.githubusercontent.com/jvhoang/p6v2-public-stats/main/data/p6v2_total_transactions.json

## Background Image

A fitting professional finance background image was generated using Grok Imagine and saved locally at:
/Users/johnhoang/.grok/sessions/%2FUsers%2Fjohnhoang%2FLibrary%2FCloudStorage%2FOneDrive-Personal%2FFW%2FTDA%2FSchwab/019e860e-18dd-7e03-8e8a-e41fc2d3cda6/images/1.jpg

Upload this image to your GoDaddy site files (e.g. as p6v2-bg.jpg) and use its URL in the embed code below.

## Embed Code for GoDaddy (P6v2 Status table) - Strong Anti-Caching Version

This version is designed for near real-time, no-cache updates:

- Unique high-entropy bust parameter on every fetch (Date.now() + performance.now() + random) to defeat CDN/browser caches.
- `cache: 'reload'` + full no-cache headers (`Cache-Control`, `Pragma`, `Expires`).
- Aggressive polling every 15 seconds.
- Manual "Force Refresh" button.
- Last checked time display.
- Same table + color logic for Last updated cell (based on the timestamp in the data vs client now).

Note: GitHub's raw CDN (Fastly) has a base ~5 minute max-age in some cases, but the unique URL + reload + headers + frequent poll minimizes visible lag to seconds after your R script pushes. Combine with hard-refresh on the page and re-publish in GoDaddy for best results. The previous simple total-transactions version used similar techniques successfully.

Replace your current custom HTML embed with this full block:

```html
<div id="p6v2-status" style="background-image: url('YOUR_BG_IMAGE_URL_HERE'); background-size: cover; background-position: center; background-repeat: no-repeat; padding: 20px; border-radius: 8px; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; max-width: 700px; margin: 0 auto; box-shadow: 0 4px 12px rgba(0,0,0,0.15);">
  <h2 style="text-align: center; color: #006400; margin: 0 0 15px 0; font-size: 24px; font-weight: 600;">P6v2 Status</h2>
  
  <table id="status-table" style="width: 100%; border-collapse: collapse; background: rgba(255,255,255,0.92); border-radius: 6px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.1); font-size: 15px;">
    <tr style="background: #006400; color: white; font-weight: 600;">
      <th style="padding: 12px 15px; text-align: left; border-bottom: 2px solid #004d00;">Metric</th>
      <th style="padding: 12px 15px; text-align: left; border-bottom: 2px solid #004d00;">Value</th>
    </tr>
    <tr>
      <td style="padding: 10px 15px; border-bottom: 1px solid #e0e0e0; font-weight: 500; color: #333;">Last updated</td>
      <td id="last-updated" style="padding: 10px 15px; border-bottom: 1px solid #e0e0e0; color: #333;"></td>
    </tr>
    <tr>
      <td style="padding: 10px 15px; border-bottom: 1px solid #e0e0e0; font-weight: 500; color: #333;">Total transactions</td>
      <td id="total-transactions" style="padding: 10px 15px; border-bottom: 1px solid #e0e0e0; color: #333; font-weight: 600;"></td>
    </tr>
    <tr>
      <td style="padding: 10px 15px; border-bottom: 1px solid #e0e0e0; font-weight: 500; color: #333;">Open transactions</td>
      <td id="open-transactions" style="padding: 10px 15px; border-bottom: 1px solid #e0e0e0; color: #333;"></td>
    </tr>
    <tr>
      <td style="padding: 10px 15px; border-bottom: 1px solid #e0e0e0; font-weight: 500; color: #333;">DTBP usage</td>
      <td id="dtbp-usage" style="padding: 10px 15px; border-bottom: 1px solid #e0e0e0; color: #333;"></td>
    </tr>
    <tr>
      <td style="padding: 10px 15px; font-weight: 500; color: #333;">VIX</td>
      <td id="vix" style="padding: 10px 15px; color: #333;"></td>
    </tr>
  </table>
  
  <div style="text-align: center; margin-top: 10px;">
    <button onclick="forceRefresh()" style="padding: 6px 12px; background: #006400; color: white; border: none; border-radius: 4px; cursor: pointer; font-size: 12px;">Force Refresh</button>
    <span id="last-checked" style="font-size: 11px; color: #555; margin-left: 10px; opacity: 0.8;"></span>
  </div>
  
  <p style="text-align: center; font-size: 11px; color: #555; margin: 8px 0 0 0; opacity: 0.8;">Auto-refreshes every 15s • Data from P6v2 algo</p>
</div>

<script>
let refreshCount = 0;

async function updateStatus() {
  const lastCheckedEl = document.getElementById('last-checked');
  try {
    refreshCount++;
    // High-entropy bust to defeat any caching (GitHub CDN, browser, GoDaddy proxy)
    const bust = Date.now() + '_' + performance.now() + '_' + Math.random().toString(36).slice(2);
    const url = 'https://raw.githubusercontent.com/jvhoang/p6v2-public-stats/main/data/p6v2_total_transactions.json?bust=' + bust;
    
    const res = await fetch(url, {
      cache: 'reload',  // Strong bypass of HTTP cache
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
    
    // Color the Last updated cell based on freshness (CDT)
    const lastCell = document.getElementById('last-updated');
    const updatedStr = data.last_updated;
    if (updatedStr) {
      const updatedTime = new Date(updatedStr.replace(' CDT', ' GMT-0500'));
      const diffSec = (new Date() - updatedTime) / 1000;
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
    }
    
    if (lastCheckedEl) {
      lastCheckedEl.textContent = 'Last checked: ' + new Date().toLocaleTimeString();
    }
    
    console.log('P6v2 status updated (poll #' + refreshCount + ')');
  } catch (e) {
    console.error('P6v2 status fetch error:', e);
    const cells = ['last-updated', 'total-transactions', 'open-transactions', 'dtbp-usage', 'vix'];
    cells.forEach(id => {
      const el = document.getElementById(id);
      if (el) el.textContent = 'N/A';
    });
    if (lastCheckedEl) lastCheckedEl.textContent = 'Error fetching data';
  }
  // Poll every 15s for near real-time
  setTimeout(updateStatus, 15000);
}

function forceRefresh() {
  console.log('Force refresh triggered');
  updateStatus();
}

// Start immediately
updateStatus();
</script>
```

## How to use on GoDaddy

1. In your GoDaddy Website Builder, edit the /p6v2-status page.
2. Add or replace the section with an "Embed" or "HTML" element.
3. Paste the full code above.
4. Upload the generated background image to your site files/media and update the `YOUR_BG_IMAGE_URL_HERE`.
5. Publish the page (this often clears GoDaddy's page-level cache).
6. On your browser, hard refresh (Ctrl/Cmd + Shift + R) the first time.

This should give you the real-time no-cache behavior you had in the previous simple total-transactions version. The frequent unique-bust fetches + reload mode + headers + short poll interval minimize lag to the time it takes your R script to push + GitHub to accept the commit (usually seconds).

## How to commit / update files (for the data owner)

See previous instructions. Your R script (with the pub_dir writes) keeps the JSON fresh.
