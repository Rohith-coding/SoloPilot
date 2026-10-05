# SoloPilot — Clickable Prototype

> Private, on-device AI back-office for freelancers in India.

## What's Inside

- `index.html` — Single self-contained file. No dependencies. Works offline.

## How to Test Locally

1. Open the `prototype` folder on your computer.
2. Double-click `index.html`. It opens in your default browser.
3. That's it — no server needed.

## How to Get a Public URL

You need a public URL for the hackathon submission. Here are two free options:

---

### Option A: Netlify Drop (Easiest — 2 minutes)

1. Open [app.netlify.com/drop](https://app.netlify.com/drop) in your browser.
2. **Drag the entire `prototype` folder** onto the page.
3. Wait for the upload to finish (a few seconds).
4. Netlify gives you a URL like `https://random-name-12345.netlify.app`.
5. Click the link to verify it works.
6. *(Optional)* Click **Site settings → Change site name** to get a nicer URL like `https://solopilot.netlify.app`.
7. **Copy the URL** — that's your submission link.

### Option B: GitHub Pages (5 minutes)

1. Go to [github.com](https://github.com) and sign in (or create an account).
2. Click the **+** in the top-right → **New repository**.
3. Name it `solopilot-prototype`. Keep it **Public**. Click **Create repository**.
4. On the next page, click **"uploading an existing file"**.
5. Drag the `index.html` file into the upload area. Click **Commit changes**.
6. Go to **Settings** → **Pages** (left sidebar).
7. Under **Source**, select **Deploy from a branch**.
8. Branch: **main**, folder: **/ (root)**. Click **Save**.
9. Wait 1–2 minutes. Refresh the page. A URL appears at the top:
   `https://YOUR-USERNAME.github.io/solopilot-prototype/`
10. **Copy the URL** — that's your submission link.

---

### Verify It's Public

Open the URL in an **incognito/private window** (Ctrl+Shift+N in Chrome). If the app loads, you're good. If not, wait a minute and try again — GitHub Pages can take up to 2 minutes to go live.

## Keyboard Shortcuts

| Key | Action |
|-----|--------|
| `R` | Reset demo to initial state |

## Notes

- This is a **clickable prototype**, not the final app. Scan, AI, and voice features are simulated.
- The final app will be built with Flutter + ML Kit + on-device AI.
- All data lives in memory and resets on page reload.
