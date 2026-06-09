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

## Embed Code for GoDaddy (P6v2 Status table)

Replace your current custom HTML embed with this full block. It uses a table in a similar professional theme (green accents, clean), with background image, and JS for the color-coded Last updated cell based on freshness (green <80s, yellow 80-180s, red >180s from now).

The JS polls every 60s with cache buster.

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
  
  <p style="text-align: center; font-size: 11px; color: #555; margin: 10px 0 0 0; opacity: 0.8;">Auto-refreshes • Data from P6v2 algo</p>
</div>

<script>
(async function updateStatus() {
  try {
    const url = 'https://raw.githubusercontent.com/jvhoang/p6v2-public-stats/main/data/p6v2_total_transactions.json?t=' + Date.now();
    const res = await fetch(url, { cache: 'no-store' });
    if (!res.ok) throw new Error('Fetch failed');
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
      // Parse CDT as GMT-5 for diff calc
      const updatedTime = new Date(updatedStr.replace(' CDT', ' GMT-0500'));
      const diffSec = (new Date() - updatedTime) / 1000;
      if (diffSec < 80) {
        lastCell.style.backgroundColor = '#90EE90'; // light green
        lastCell.style.color = '#006400';
      } else if (diffSec < 180) {
        lastCell.style.backgroundColor = '#FFFACD'; // light yellow
        lastCell.style.color = '#333';
      } else {
        lastCell.style.backgroundColor = '#FFB6C1'; // light red
        lastCell.style.color = '#8B0000';
      }
    }
  } catch (e) {
    console.error('P6v2 status fetch error:', e);
    const cells = ['last-updated', 'total-transactions', 'open-transactions', 'dtbp-usage', 'vix'];
    cells.forEach(id => {
      const el = document.getElementById(id);
      if (el) el.textContent = 'N/A';
    });
  }
  // Poll every 60s
  setTimeout(updateStatus, 60000);
})();
</script>
```

## How to use on GoDaddy

1. In your GoDaddy Website Builder, edit the /p6v2-status page (or rename from old /p6v2-total-transactions).
2. Add or replace the section with an "Embed" or "HTML" element.
3. Paste the full code above.
4. Upload the generated background image (from the Grok Imagine output) to your site files/media and update the `YOUR_BG_IMAGE_URL_HERE` in the code.
5. Publish.

The table will auto-refresh every 60s and color the Last updated cell based on how fresh the data is.

## How to commit / update files (for the data owner)

See previous instructions in this README for the clone and helper. Your R script writes the full status JSON now.

The public repo is kept clean of personal paths (R handles writing to the clone's data/ dir privately).
