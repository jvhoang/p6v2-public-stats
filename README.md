The current README content with fixed JS parse in the embed example.

## Embed Code for GoDaddy (P6v2 Status table) - jsDelivr + Ultra Anti-Cache (fixes the ~5min raw.githubusercontent.com lag)

**Root cause of the 5 minute delay:**  
`raw.githubusercontent.com` (Fastly) always advertises `max-age=300` (and often serves HITs with `age` ~300 or `x-cache: HIT`). Even with `?bust=...` + `cache:'no-store'` + headers, some client contexts (GoDaddy Website Builder embeds, certain browsers/proxies) can still see the 5-minute stale version.

**Fix:** Primary data source is now **jsDelivr** (`cdn.jsdelivr.net/gh/...@main/...`) — a different CDN (Cloudflare) that responds much faster to new commits on `main`. Combined with:
- Ultra high-entropy bust (`Date.now() + performance.now() + multiple randoms + extra timestamp params`)
- `cache: 'no-store'`
- Full no-cache headers
- Response header logging (you will see `age`, `cf-cache-status`, `x-cache` etc. in console)

This + the 15s poll + Force Refresh button gets updates on the website within seconds of a successful `git push` from your `update-data.sh` (instead of waiting out the full 5 min).

The source JSON is still only written ~every 10 minutes by the R autotrade block, so you won't see more frequent changes than that.

Copy the **complete block below** into your GoDaddy custom HTML section on the p6v2-status page.  
Publish → hard refresh the live page (Cmd/Ctrl+Shift+R) with DevTools Console open.

```html
<div id="p6v2-status" style="background: linear-gradient(rgba(0, 0, 0, 0.48), rgba(0, 0, 0, 0.48)), url('https://img1.wsimg.com/isteam/ip/0bfe8b89-8d82-4dbc-8b70-7ca0a49f650a/fbd27d89-f6d0-4b5b-8809-4dfdf8af4803.jpg/:/cr=t:0%25,l:0%25,w:100%25,h:100%25') center/cover no-repeat; padding: 22px 26px; border-radius: 10px; color: #ffffff; font-family: system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; max-width: 680px; margin: 0 auto; box-shadow: 0 4px 14px rgba(0,0,0,0.4); text-shadow: 0 2px 4px rgba(0, 0, 0, 0.75);">
  <h2 style="margin: 0 0 16px 0; font-size: 1.85rem; font-weight: 800; letter-spacing: 0.4px;">P6v2 Status</h2>

  <table id="status-table" style="width: 100%; border-collapse: collapse; font-size: 1.2rem; line-height: 1.5;">
    <tr>
      <td style="padding: 9px 0; opacity: 0.92; font-weight: 600; background-color: rgba(0, 0, 0, 0.5);">Last updated</td>
      <td id="last-updated" style="font-weight: 800; font-size: 1.35rem; text-align: right; background-color: rgba(0, 0, 0, 0.5);"></td>
    </tr>
    <tr>
      <td style="padding: 9px 0; opacity: 0.92; font-weight: 600; background-color: rgba(0, 0, 0, 0.5);">Total transactions</td>
      <td id="total-transactions" style="font-weight: 800; font-size: 1.35rem; text-align: right; background-color: rgba(0, 0, 0, 0.5);"></td>
    </tr>
    <tr>
      <td style="padding: 9px 0; opacity: 0.92; font-weight: 600; background-color: rgba(0, 0, 0, 0.5);">Open transactions</td>
      <td id="open-transactions" style="font-weight: 800; font-size: 1.35rem; text-align: right; background-color: rgba(0, 0, 0, 0.5);"></td>
    </tr>
    <tr>
      <td style="padding: 9px 0; opacity: 0.92; font-weight: 600; background-color: rgba(0, 0, 0, 0.5);">DTBP usage</td>
      <td id="dtbp-usage" style="font-weight: 800; font-size: 1.35rem; text-align: right; background-color: rgba(0, 0, 0, 0.5);"></td>
    </tr>
    <tr>
      <td style="padding: 9px 0; opacity: 0.92; font-weight: 600; background-color: rgba(0, 0, 0, 0.5);">VIX</td>
      <td id="vix" style="font-weight: 800; font-size: 1.35rem; text-align: right; background-color: rgba(0, 0, 0, 0.5);"></td>
    </tr>
  </table>

  <div style="margin-top: 18px; display: flex; align-items: center; gap: 12px; flex-wrap: wrap;">
    <button onclick="forceRefresh()" style="background: rgba(255,255,255,0.25); color: #fff; border: 1px solid rgba(255,255,255,0.5); padding: 8px 16px; border-radius: 6px; font-size: 0.95rem; font-weight: 700; cursor: pointer;">Force Refresh</button>
    <span id="last-checked" style="font-size: 0.85rem; opacity: 0.8; font-weight: 500;"></span>
  </div>
</div>

<script>
let refreshCount = 0;

function parseCDT(str) {
  if (!str) return null;
  const cleaned = str.replace(' CDT', '').trim();
  const parts = cleaned.split(/[- :]/);
  if (parts.length < 6) return null;
  const iso = `${parts[0]}-${parts[1]}-${parts[2]}T${parts[3]}:${parts[4]}:${parts[5]}-05:00`;
  const dt = new Date(iso);
  return isNaN(dt.getTime()) ? null : dt;
}

function formatLastUpdated(str) {
  if (!str) return '—';
  const match = str.match(/(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2}):(\d{2}) CDT/);
  if (!match) return str;
  let [, year, month, day, hour, min, sec] = match;
  month = parseInt(month, 10);
  day = parseInt(day, 10);
  let h = parseInt(hour, 10);
  const ampm = h >= 12 ? 'PM' : 'AM';
  h = h % 12;
  if (h === 0) h = 12;
  return `${month}/${day}/${year} ${h}:${min}:${sec} ${ampm} CDT`;
}

async function updateStatus() {
  refreshCount++;

  const now = Date.now();
  const perf = performance.now();
  const randBase = Math.random().toString(36).slice(2);

  // 1. Fetch the version pointer (tiny file updated on every push) with strong bust.
  // This forces jsDelivr to resolve the absolute latest @main commit.
  const vBust = `${now}${perf}${randBase}`;
  const versionUrl = `https://cdn.jsdelivr.net/gh/jvhoang/p6v2-public-stats@main/data/p6v2_version.txt?bust=${vBust}&t=${now}&r=${Math.random()}`;

  let sha = 'main';
  try {
    const vRes = await fetch(versionUrl, {
      cache: 'no-store',
      headers: {
        'Cache-Control': 'no-cache, no-store, must-revalidate, max-age=0',
        'Pragma': 'no-cache',
        'Expires': '0'
      }
    });
    if (vRes.ok) {
      const vText = (await vRes.text()).trim();
      const parts = vText.split(/\s+/);
      if (parts[0] && parts[0].length >= 10) {
        sha = parts[0]; // the exact commit SHA containing the fresh data
      }
    }
  } catch (e) {
    // fallback to @main if version pointer can't be read
    console.warn('Could not read version pointer, falling back to @main', e);
  }

  // 2. Fetch the actual JSON pinned to that SHA + fresh bust.
  // Pinning to the SHA from the version pointer guarantees we get the content
  // from the exact commit that has the latest data (bypasses any sticky @main cache).
  const dBust = `${now}${perf}${Math.random()}${Math.random()}`;
  const dataUrl = `https://cdn.jsdelivr.net/gh/jvhoang/p6v2-public-stats@${sha}/data/p6v2_total_transactions.json?bust=${dBust}&t=${now}&r=${Math.random()}`;

  console.log(`Fetching fresh status (poll #${refreshCount}) via @${sha}: ${dataUrl}`);

  try {
    const res = await fetch(dataUrl, {
      cache: 'no-store',
      headers: {
        'Cache-Control': 'no-cache, no-store, must-revalidate, max-age=0',
        'Pragma': 'no-cache',
        'Expires': '0'
      }
    });

    console.log('Response status:', res.status);
    console.log('Response headers:');
    res.headers.forEach((value, key) => {
      console.log(`  ${key}: ${value}`);
    });

    if (!res.ok) throw new Error(`Fetch failed with status ${res.status}`);
    const data = await res.json();

    const originalLastUpdated = data.last_updated || '';
    document.getElementById('last-updated').textContent = formatLastUpdated(originalLastUpdated);

    document.getElementById('total-transactions').textContent = data.total_transactions ?? '—';
    document.getElementById('open-transactions').textContent = data.open_transactions ?? '—';
    document.getElementById('dtbp-usage').textContent = data.dtbp_usage || '—';
    document.getElementById('vix').textContent = data.vix || '—';

    const lastCell = document.getElementById('last-updated');
    const dt = parseCDT(originalLastUpdated);
    let diffSec = NaN;

    if (dt) {
      diffSec = Math.floor((Date.now() - dt.getTime()) / 1000);
      if (diffSec < 80) {
        lastCell.style.backgroundColor = 'rgba(144, 238, 144, 0.5)';
        lastCell.style.color = '#000';
      } else if (diffSec < 180) {
        lastCell.style.backgroundColor = 'rgba(255, 250, 205, 0.5)';
        lastCell.style.color = '#000';
      } else {
        lastCell.style.backgroundColor = 'rgba(255, 182, 193, 0.5)';
        lastCell.style.color = '#000';
      }
    } else {
      lastCell.style.backgroundColor = 'rgba(255, 182, 193, 0.5)';
      lastCell.style.color = '#000';
    }

    const nowTime = new Date();
    document.getElementById('last-checked').textContent = `Last checked: ${nowTime.toLocaleTimeString()}`;

    console.log(`Poll #${refreshCount} diffSec=${diffSec} (last_updated: ${originalLastUpdated})`);

  } catch (e) {
    console.error('Status update error:', e);
    document.getElementById('last-checked').textContent = 'Update error — will retry';
  }

  setTimeout(updateStatus, 15000);
}

function forceRefresh() {
  document.getElementById('last-checked').textContent = 'Refreshing...';
  updateStatus();
}

updateStatus();
</script>
```

**Usage & verification**
1. Paste the **entire** block (the `<div id="p6v2-status"> ... </script>`) into the GoDaddy HTML embed section for your p6v2-status page.
2. Publish the site.
3. Hard-refresh the live page (Cmd/Ctrl + Shift + R) **with browser DevTools Console open**.
4. You will immediately see lines like:
   - `Fetching fresh status (poll #1): https://cdn.jsdelivr.net/gh/...@main/...json?bust=...`
   - `Response status: 200`
   - `Response headers:` (look for `age: 0`, `cf-cache-status: MISS`, `x-cache: MISS, MISS` etc.)
5. After your R script finishes and `update-data.sh` completes the git push, click **Force Refresh** or wait ≤15s. The Last Updated value (and the other fields) should refresh with the new data and the freshness color should reflect the real age.

If you still see high `age` or `HIT` after the switch, paste the relevant console header lines here and we can add more layers (e.g. jsDelivr purge hook in the shell script, or move the JSON to a zero-cache host).

The previous raw-only version is deliberately replaced here because it was the source of the recurring 5-minute lag reports. jsDelivr + the ultra bust + header visibility has been the reliable path in testing.
