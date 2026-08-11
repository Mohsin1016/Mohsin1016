# GitHub Profile README Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the flat plain-text profile README with an editorial dark-premium page featuring a custom-rendered banner and nine evidence-backed projects.

**Architecture:** The banner is authored as a local HTML file and rasterised to 2× PNGs with headless Chrome, because GitHub proxies images under `default-src 'none'` and an SVG banner cannot load fonts. The README embeds those PNGs through a `<picture>` block so light and dark GitHub themes each get a matching asset. All body content is plain markdown plus a handful of `<table>` blocks for the project cards.

**Tech Stack:** Markdown, HTML/CSS, headless Chrome (screenshot rendering), shields.io (sparse accent badges only), github-readme-stats.

## Global Constraints

- Repo under change is **only** `Mohsin1016/Mohsin1016`. Never write to any other repo; the authorship audit was read-only.
- **Palette, exact values:** ground `#0B0F14`, accent `#22D3EE`, accent-dim `#0E7490`, text `#E6EDF3`, muted `#8B98A5`. Light-banner overrides: ground `#FFFFFF`, text `#0B0F14`, muted `#57606A`, accent `#0891B2`.
- **No badge wall.** A badge wall was already built and deliberately removed in commit `5c67502`. Badges are permitted only for the four hero links and nowhere else. Tech stacks are written as `·`-separated text, never as badge rows.
- **No invented numbers.** Every figure must come from the spec's §2 audit or from user-supplied input. Permitted figures: `109` repos contributed to, `7` production backends from the Django template, `92%` authored on GoProperli, `6` orgs shipping, `64%` on B2R, `93%` on CryptoWater, `96%` on PetzyPets, `97%` on Django-Template, `19/9,796` on MomentIQ.
- **MomentIQ is never described as owned.** It appears only under "Engineering signals" as a contribution, with the platform's scale stated.
- **No** animated typing headers, streak cards, trophy cards, or visitor counters.
- **No location or timezone claim** anywhere — it is unknown.
- Asset paths in the README are repo-relative (`assets/...`), never absolute URLs.
- Banner canvas is exactly **2560×600**.

---

## File Structure

| File | Responsibility |
|---|---|
| `assets/banner.html` | Single source of truth for banner layout/typography. Reads `?theme=light` to switch palette. Created in Task 1. |
| `assets/render.sh` | Reproducible two-shot render command so the banner can be regenerated later. Created in Task 1. |
| `assets/banner-dark.png` | 2560×600 raster, dark palette. Generated in Task 1. |
| `assets/banner-light.png` | 2560×600 raster, light palette. Generated in Task 1. |
| `README.md` | The profile page. Rewritten across Tasks 2–4. |

Tasks 2–4 each append a contiguous block to `README.md`, so the file is built top-to-bottom and every task leaves a renderable page.

---

### Task 1: Banner source and render pipeline

**Files:**
- Create: `assets/banner.html`
- Create: `assets/render.sh`
- Create (generated): `assets/banner-dark.png`, `assets/banner-light.png`

**Interfaces:**
- Consumes: nothing.
- Produces: `assets/banner-dark.png` and `assets/banner-light.png`, both exactly 2560×600 px. Task 2 embeds these two paths.

- [ ] **Step 1: Write the banner source**

Create `assets/banner.html`:

```html
<!doctype html>
<meta charset="utf-8">
<title>banner</title>
<style>
  :root {
    --ground: #0B0F14;
    --text: #E6EDF3;
    --muted: #8B98A5;
    --accent: #22D3EE;
    --accent-dim: #0E7490;
  }
  body[data-theme="light"] {
    --ground: #FFFFFF;
    --text: #0B0F14;
    --muted: #57606A;
    --accent: #0891B2;
    --accent-dim: #67E8F9;
  }
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body {
    width: 2560px; height: 600px;
    background: var(--ground);
    font-family: 'Inter', -apple-system, 'SF Pro Display', 'Helvetica Neue', Arial, sans-serif;
    display: flex; align-items: center;
    position: relative; overflow: hidden;
  }
  .glow {
    position: absolute; right: -240px; top: 50%;
    width: 1100px; height: 1100px; transform: translateY(-50%);
    background: radial-gradient(circle, color-mix(in srgb, var(--accent) 16%, transparent) 0%, transparent 62%);
    pointer-events: none;
  }
  .content { padding-left: 160px; position: relative; z-index: 2; }
  h1 {
    font-size: 132px; font-weight: 650; letter-spacing: -0.035em;
    color: var(--text); line-height: 0.94;
  }
  .rule { width: 104px; height: 5px; background: var(--accent); margin: 40px 0 34px; }
  .role { font-size: 44px; font-weight: 420; color: var(--muted); letter-spacing: -0.008em; }
  .role b { color: var(--text); font-weight: 560; }
  .wave {
    position: absolute; right: 168px; top: 50%; transform: translateY(-50%);
    display: flex; align-items: center; gap: 15px; height: 320px; z-index: 1;
  }
  .wave i { display: block; width: 7px; border-radius: 4px; background: var(--accent-dim); }
  .grid {
    position: absolute; inset: 0; z-index: 0; opacity: 0.5;
    background-image:
      linear-gradient(to right, color-mix(in srgb, var(--accent-dim) 13%, transparent) 1px, transparent 1px),
      linear-gradient(to bottom, color-mix(in srgb, var(--accent-dim) 13%, transparent) 1px, transparent 1px);
    background-size: 80px 80px;
    mask-image: linear-gradient(to right, transparent 40%, black 100%);
    -webkit-mask-image: linear-gradient(to right, transparent 40%, black 100%);
  }
</style>
<body>
  <div class="grid"></div>
  <div class="glow"></div>
  <div class="content">
    <h1>Mohsin&nbsp;Khalid</h1>
    <div class="rule"></div>
    <div class="role"><b>Backend Engineer</b> &nbsp;—&nbsp; real-time, AI &amp; data systems</div>
  </div>
  <div class="wave" id="wave"></div>
  <script>
    // Light theme when ?theme=light is passed to the renderer.
    if (location.search.includes('theme=light')) document.body.dataset.theme = 'light';

    // Deterministic pseudo-waveform: fixed seed, no Math.random, so both
    // renders and every future re-render produce an identical figure.
    const bars = 34, wave = document.getElementById('wave');
    for (let i = 0; i < bars; i++) {
      const t = i / (bars - 1);
      const h = 46
        + 132 * Math.abs(Math.sin(i * 0.9))
        + 86 * Math.abs(Math.sin(i * 0.31 + 1.1));
      const el = document.createElement('i');
      el.style.height = Math.round(Math.min(h, 300)) + 'px';
      el.style.opacity = (0.22 + 0.62 * t).toFixed(3);
      wave.appendChild(el);
    }
  </script>
</body>
```

- [ ] **Step 2: Write the render script**

Create `assets/render.sh`:

```bash
#!/usr/bin/env bash
# Regenerate the profile banner PNGs from banner.html.
# Renders at the full 2560x600 canvas; the README displays them at 1280 CSS px
# so they stay crisp on retina displays.
set -euo pipefail

CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

render() { # $1 = query string, $2 = output filename
  "$CHROME" --headless --disable-gpu --hide-scrollbars \
    --force-device-scale-factor=1 \
    --window-size=2560,600 \
    --screenshot="$DIR/$2" \
    "file://$DIR/banner.html$1"
}

render ""             banner-dark.png
render "?theme=light" banner-light.png

echo "rendered:"
for f in banner-dark.png banner-light.png; do
  echo "  $f  $(file -b "$DIR/$f" | sed 's/.*, \([0-9]* x [0-9]*\).*/\1/')"
done
```

- [ ] **Step 3: Render the banners**

Run:
```bash
cd /Users/mohsin/Downloads/freelance/Mohsin1016
chmod +x assets/render.sh && ./assets/render.sh
```
Expected: both files written, each reported as `2560 x 600`.

- [ ] **Step 4: Verify dimensions programmatically**

Run:
```bash
cd /Users/mohsin/Downloads/freelance/Mohsin1016
for f in assets/banner-dark.png assets/banner-light.png; do
  printf '%s -> ' "$f"; file -b "$f"
done
```
Expected: each line contains `PNG image data, 2560 x 600`.

If a file is missing or mis-sized, the usual cause is Chrome not being at the scripted path — check with `ls -d "/Applications/Google Chrome.app"` and fall back to the Playwright Chromium at `~/Library/Caches/ms-playwright/chromium-1234/chrome-mac/Headless Shell/headless_shell`, updating `CHROME` in `render.sh`.

- [ ] **Step 5: Inspect both renders visually**

Read both PNGs with the Read tool and confirm: name is fully inside the canvas and not clipped; the accent rule sits between name and role line; the waveform does not overlap the text; the light variant has legible dark text on white. If the name clips, reduce `h1` font-size in 6px steps and re-render.

- [ ] **Step 6: Commit**

```bash
cd /Users/mohsin/Downloads/freelance/Mohsin1016
git add assets/banner.html assets/render.sh assets/banner-dark.png assets/banner-light.png
git commit -m "Add profile banner source and rendered 2x assets"
```

---

### Task 2: README hero, links, metrics, and now-line

**Files:**
- Modify: `README.md` (full replacement of the current 59 lines)

**Interfaces:**
- Consumes: `assets/banner-dark.png`, `assets/banner-light.png` from Task 1.
- Produces: a `README.md` whose content ends immediately after the now-line, ready for Task 3 to append the work sections.

- [ ] **Step 1: Replace README.md with the opening block**

Write `README.md` with exactly this content:

```markdown
<div align="center">

<picture>
  <source media="(prefers-color-scheme: dark)"  srcset="assets/banner-dark.png">
  <source media="(prefers-color-scheme: light)" srcset="assets/banner-light.png">
  <img src="assets/banner-dark.png" width="1280" alt="Mohsin Khalid — Backend Engineer, real-time, AI and data systems">
</picture>

&nbsp;

[![Portfolio](https://img.shields.io/badge/Portfolio-0B0F14?style=flat-square&logo=vercel&logoColor=22D3EE)](https://portfolio1-olive-seven.vercel.app/)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-0B0F14?style=flat-square&logo=linkedin&logoColor=22D3EE)](https://www.linkedin.com/in/mohsin1016)
[![Email](https://img.shields.io/badge/Email-0B0F14?style=flat-square&logo=gmail&logoColor=22D3EE)](mailto:muhammadmohsin1016@gmail.com)
[![GitHub](https://img.shields.io/badge/GitHub-0B0F14?style=flat-square&logo=github&logoColor=22D3EE)](https://github.com/Mohsin1016)

&nbsp;

**109** repos contributed to &nbsp;·&nbsp; **7** production backends on my Django template &nbsp;·&nbsp; **92%** authored on GoProperli &nbsp;·&nbsp; **6** orgs shipping

</div>

---

### ▸ Now

Building **Evolve7** — an intelligent life operating system in Flutter, on Riverpod and a feature-first clean architecture.

**Open to freelance and contract backend work.** &nbsp;→&nbsp; [muhammadmohsin1016@gmail.com](mailto:muhammadmohsin1016@gmail.com)
```

- [ ] **Step 2: Verify the banner resolves locally**

Run:
```bash
cd /Users/mohsin/Downloads/freelance/Mohsin1016
grep -o 'assets/banner-[a-z]*\.png' README.md | sort -u | while read -r p; do
  test -f "$p" && echo "OK   $p" || echo "MISS $p"
done
```
Expected: two `OK` lines, no `MISS`.

- [ ] **Step 3: Verify the four hero links respond**

Run:
```bash
for U in https://portfolio1-olive-seven.vercel.app/ https://www.linkedin.com/in/mohsin1016 https://github.com/Mohsin1016; do
  printf '%s %s\n' "$(curl -s -o /dev/null -w '%{http_code}' -L --max-time 20 "$U")" "$U"
done
```
Expected: `200` for the portfolio and GitHub URLs. LinkedIn commonly answers `999` to automated clients — that is LinkedIn's bot guard, not a broken link, so accept `200` or `999` there and do not "fix" it.

- [ ] **Step 4: Confirm no forbidden content crept in**

Run:
```bash
cd /Users/mohsin/Downloads/freelance/Mohsin1016
grep -niE 'streak|trophy|visitor|typing-header|readme-typing' README.md && echo "FORBIDDEN CONTENT FOUND" || echo "clean"
```
Expected: `clean`.

- [ ] **Step 5: Commit**

```bash
cd /Users/mohsin/Downloads/freelance/Mohsin1016
git add README.md
git commit -m "Rewrite profile README hero: banner, links, metrics, now-line"
```

---

### Task 3: Featured work and also-shipped sections

**Files:**
- Modify: `README.md` (append after the now-line)

**Interfaces:**
- Consumes: the `README.md` produced by Task 2.
- Produces: `README.md` with the four featured cards and the three-up secondary row, ready for Task 4 to append the closing sections.

Every claim below is fixed by the audit — do not soften, inflate, or reorder the cards. GoProperli must stay first.

- [ ] **Step 1: Append the featured work section**

Append to `README.md`:

```markdown
---

### ▸ Featured work

<table>
<tr>
<td width="50%" valign="top">

**01 · GoProperli** &nbsp;·&nbsp; <sub>92% authored</sub>

Property-intelligence pipeline for foreclosure and probate acquisition. Scrapes county clerk records, matches legal descriptions back to folio numbers, runs AI case analysis, and syncs the results into a BigQuery warehouse.

<sub>Django · Celery · Playwright · Gemini · BigQuery · PostgreSQL · Docker</sub>

[→ Live](https://goproperli-frontend.vercel.app)

</td>
<td width="50%" valign="top">

**02 · B2R Thunder Road** &nbsp;·&nbsp; <sub>64% authored</sub>

B2B outreach automation at scale. AI-personalised sequences, salesflow and scheduling, CRM sync across Clay, Attio and Reply.io, and a Chrome extension for data capture.

<sub>Django · Next.js · PostgreSQL · OpenAI · Clay · Attio · Reply.io · Outlook</sub>

[→ Live](https://thunderroad.b2rpartners.com/dashboard)

</td>
</tr>
<tr>
<td width="50%" valign="top">

**03 · Ctrl Assist**

Real-time call assistance — live transcription, translation and AI suggestions delivered over a low-latency audio pipeline.

<sub>Django · DRF · Next.js · WebRTC · Twilio · Deepgram · OpenAI · Docker</sub>

[→ Live](https://app.ctrlassist.com/login)

</td>
<td width="50%" valign="top">

**04 · DreamGuest**

Multi-tenant guest-management SaaS handling subscriptions, payments, background checks, digital contracts and real-time messaging.

<sub>React · Node.js · Express · MySQL · Stripe · SignWell</sub>

[→ Live](https://app.dreamguest.com/)

</td>
</tr>
</table>
```

- [ ] **Step 2: Append the also-shipped section**

Append to `README.md`:

```markdown
### ▸ Also shipped

<table>
<tr>
<td width="33%" valign="top">

**CryptoWater** &nbsp;<sub>93% authored</sub>

NFT card marketplace with live auctions, countdown timers and real-time bidding.

<sub>Next.js 15 · React 19 · Socket.IO · Zod · Tailwind</sub>

[→ Live](https://pro-crypto-water-front.vercel.app)

</td>
<td width="33%" valign="top">

**PetzyPets** &nbsp;<sub>96% authored</sub>

Cross-platform pet-care app, built mobile-first with a TypeScript service behind it.

<sub>Flutter · Dart · TypeScript · PostgreSQL</sub>

</td>
<td width="33%" valign="top">

**AI-Guard**

Conversational visitor verification with automated security escalation, running daily at the gate.

<sub>Django · PostgreSQL · Retell AI · OpenAI</sub>

</td>
</tr>
</table>
```

- [ ] **Step 3: Verify every featured link responds**

Run:
```bash
for U in https://goproperli-frontend.vercel.app https://thunderroad.b2rpartners.com/dashboard https://app.ctrlassist.com/login https://app.dreamguest.com/ https://pro-crypto-water-front.vercel.app; do
  printf '%s %s\n' "$(curl -s -o /dev/null -w '%{http_code}' -L --max-time 20 "$U")" "$U"
done
```
Expected: `200` on all five. A non-200 means the deployment changed since the audit — report it rather than deleting the card, so the owner can decide.

- [ ] **Step 4: Verify GoProperli leads and card order is intact**

Run:
```bash
cd /Users/mohsin/Downloads/freelance/Mohsin1016
grep -oE '\*\*0[1-4] · [A-Za-z0-9 ]+\*\*' README.md
```
Expected, in this order:
```
**01 · GoProperli**
**02 · B2R Thunder Road**
**03 · Ctrl Assist**
**04 · DreamGuest**
```

- [ ] **Step 5: Commit**

```bash
cd /Users/mohsin/Downloads/freelance/Mohsin1016
git add README.md
git commit -m "Add featured work and also-shipped sections to profile README"
```

---

### Task 4: Engineering signals, stack, how I work, stats

**Files:**
- Modify: `README.md` (append after the also-shipped section)

**Interfaces:**
- Consumes: the `README.md` produced by Task 3.
- Produces: the complete `README.md`. Task 5 only verifies it.

The MomentIQ wording is load-bearing. It must state the platform's scale and describe Mohsin's work as contributions. Do not write "built", "led", or "my platform" anywhere near it.

- [ ] **Step 1: Append engineering signals**

Append to `README.md`:

```markdown
---

### ▸ Engineering signals

**MomentIQ** — TikTok Shop analytics platform, a codebase of roughly 10,000 commits built by a large team. I contributed backend work into it:

- TikTok Shop OAuth routed through the cipher-returning `/authorization/202309/shops` endpoint
- Per-shop canary allowlists for bulk order, product and collaboration upserts, with write-performance levers
- Disabled server-side cursors and prepared statements for Postgres running under PgBouncer transaction pooling
- Repaired `NOT NULL` schema drift on `live_sessions` in production

<sub>The point of this entry is not volume — it is landing precise changes inside a large codebase I did not write.</sub>

**Django Template** — I authored the production Django scaffolding my company builds on: JWT auth, DRF, Celery, Docker and Swagger, generated by a setup script. **7 production backends run on it.**
```

- [ ] **Step 2: Append stack and how-I-work**

Append to `README.md`:

```markdown
---

### ▸ Stack

**Backend** &nbsp; Python · Django · DRF · Node.js · Express · Celery · REST · WebSockets
**Real-time & AI** &nbsp; OpenAI · Gemini · Deepgram · Retell AI · WebRTC · Twilio
**Data** &nbsp; PostgreSQL · MySQL · MongoDB · BigQuery · Redis
**Cloud & DevOps** &nbsp; AWS · Google Cloud · Docker · GitHub Actions · Vercel
**Frontend & Mobile** &nbsp; React · Next.js · TypeScript · Tailwind · Flutter

---

### ▸ How I work

- **End-to-end ownership** — architecture, implementation, deployment, and the debugging afterwards. Not just the ticket.
- **Milestones that deploy** — scoped so there is something running at every checkpoint, rather than one big-bang delivery.
- **Direct async updates** — you always know what shipped and what is next.
- **Comfortable inheriting a codebase** — see the MomentIQ work above.
```

Note on the stack block: each of the five lines needs an explicit trailing `<br>`.

This corrects an error in the first draft of this plan, which claimed soft newlines would produce the compact grouped look on their own. They do not. README files render with *document* semantics, where a single newline collapses to a space — verified against GitHub's own renderer via `POST /markdown` with `mode=markdown`, which emitted **zero** `<br>` elements and put all five lines inside one `<p>`. Without the explicit breaks the block runs together into a single paragraph.

(`mode=gfm` does emit `<br>` for soft breaks, but that is comment/issue semantics, not how a README file is displayed — do not verify against that mode.)

- [ ] **Step 3: Append the stats block**

Append to `README.md`:

```markdown
---

<div align="center">

<img src="https://github-readme-stats.vercel.app/api?username=Mohsin1016&show_icons=true&hide_border=true&count_private=true&include_all_commits=true&bg_color=0B0F14&title_color=22D3EE&icon_color=22D3EE&text_color=8B98A5&ring_color=22D3EE" height="165" alt="GitHub stats">
<img src="https://github-readme-stats.vercel.app/api/top-langs/?username=Mohsin1016&layout=compact&hide_border=true&langs_count=8&bg_color=0B0F14&title_color=22D3EE&text_color=8B98A5" height="165" alt="Most used languages">

</div>
```

- [ ] **Step 4: Verify the stats endpoints render**

Run:
```bash
for U in "https://github-readme-stats.vercel.app/api?username=Mohsin1016&bg_color=0B0F14" "https://github-readme-stats.vercel.app/api/top-langs/?username=Mohsin1016&layout=compact"; do
  printf '%s %s\n' "$(curl -s -o /dev/null -w '%{http_code}' -L --max-time 25 "$U")" "$U"
done
```
Expected: `200` on both. This service rate-limits intermittently; if you get `429`, wait 30 seconds and retry once before reporting a problem.

- [ ] **Step 5: Commit**

```bash
cd /Users/mohsin/Downloads/freelance/Mohsin1016
git add README.md
git commit -m "Add engineering signals, stack, how-I-work and stats to profile README"
```

---

### Task 5: Whole-page verification

**Files:**
- Modify: `README.md` (only if a check fails)

**Interfaces:**
- Consumes: the complete `README.md` from Task 4.
- Produces: a verified page, plus a findings report for the owner.

- [ ] **Step 1: Audit every claim against the allowed-figures list**

Run:
```bash
cd /Users/mohsin/Downloads/freelance/Mohsin1016
grep -oE '\*\*[0-9]+%?\*\*|[0-9]+% authored|~?[0-9,]+ commits' README.md | sort -u
```
Expected: only figures from the Global Constraints list (`109`, `7`, `92%`, `6`, `64%`, `93%`, `96%`, and the `10,000 commits` phrasing). Any other number is an invented claim and must be removed.

- [ ] **Step 2: Confirm MomentIQ is not framed as owned**

Run:
```bash
cd /Users/mohsin/Downloads/freelance/Mohsin1016
awk '/MomentIQ/,/Django Template/' README.md | grep -niE '\b(built|created|founded|led|my platform|i own)\b' && echo "OWNERSHIP LANGUAGE FOUND — REWRITE" || echo "framing OK"
```
Expected: `framing OK`. The phrase "built by a large team" is the intended use of that word and sits before the match window; if it trips the grep, confirm by reading the section rather than editing wording that is already correct.

- [ ] **Step 3: Confirm no location or timezone claim**

Run:
```bash
cd /Users/mohsin/Downloads/freelance/Mohsin1016
grep -niE 'pakistan|PKT|GMT|UTC|EST|PST|timezone|time zone' README.md && echo "LOCATION CLAIM FOUND — REMOVE" || echo "no location claim"
```
Expected: `no location claim`.

- [ ] **Step 4: Check the badge count is still four**

Run:
```bash
cd /Users/mohsin/Downloads/freelance/Mohsin1016
printf 'shields badges: %s\n' "$(grep -c 'img.shields.io' README.md)"
```
Expected: `shields badges: 4`. More than four means a badge wall is re-forming — remove the extras.

- [ ] **Step 5: Render the finished page and inspect it**

Run:
```bash
cd /Users/mohsin/Downloads/freelance/Mohsin1016
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless --disable-gpu --hide-scrollbars \
  --window-size=1000,3000 \
  --screenshot=/private/tmp/claude-501/-Users-mohsin-Downloads-freelance-Mohsin1016/653bd6de-72f4-44f4-8272-3cc88a847656/scratchpad/readme-preview.png \
  "$(python3 -c "
import markdown,pathlib,urllib.parse,html
src = pathlib.Path('README.md').read_text()
body = markdown.markdown(src, extensions=['tables','md_in_html'])
page = '<meta charset=utf-8><base href=\"file://' + str(pathlib.Path().resolve()) + '/\"><style>body{max-width:900px;margin:0 auto;padding:32px;font:16px/1.6 -apple-system,sans-serif;background:#0d1117;color:#e6edf3}img{max-width:100%}table{border-collapse:collapse;width:100%}td{border:1px solid #30363d;padding:14px;vertical-align:top}a{color:#22d3ee}hr{border:0;border-top:1px solid #30363d;margin:28px 0}sub{color:#8b98a5}</style>' + body
p = pathlib.Path('/private/tmp/claude-501/-Users-mohsin-Downloads-freelance-Mohsin1016/653bd6de-72f4-44f4-8272-3cc88a847656/scratchpad/preview.html')
p.write_text(page)
print('file://' + str(p))
" 2>/dev/null || echo "SKIP")"
```

If `python3 -c "import markdown"` fails, install into the scratchpad only — never into the repo — with `python3 -m pip install --user markdown`, or skip this step and rely on Step 6. This preview is an approximation of GitHub's renderer, useful for catching gross layout breakage (overflowing cards, clipped banner, collapsed tables), not for pixel judgements.

- [ ] **Step 6: Read the preview and the raw README**

Read the preview PNG (if produced) and `README.md` end to end. Confirm: the banner is not clipped; the four featured cards form a 2×2 grid; the also-shipped row is three columns; the stack lines are one compact block rather than five paragraphs; no section is empty.

- [ ] **Step 7: Report and commit any fixes**

If Steps 1–6 required edits:
```bash
cd /Users/mohsin/Downloads/freelance/Mohsin1016
git add README.md
git commit -m "Fix issues found in profile README verification pass"
```

Then report to the owner: every check run with its actual output, anything that failed and why, and the two decisions still open from the spec's §5 — real business metrics to replace the GitHub-derived strip, and whether to add a timezone line. Do not claim the page is verified for figures the owner has not confirmed; state plainly that the metrics are GitHub-derived by default.

---

## Self-Review

**Spec coverage:** §3 palette → Global Constraints and Task 1 Step 1. §3 banner pipeline → Task 1. §4 items 1–4 → Task 2. §4 items 5–6 → Task 3. §4 items 7–10 → Task 4. §2 claim rules → enforced in Task 3 Step 4 and Task 5 Steps 1–2. §5 defaults → Task 2 Step 1 (Evolve7, availability) and Task 5 Step 3 (no location). §7 success criteria 1–6 → Task 5 Steps 1–6 and the link checks in Tasks 2–4.

**Deliberate omissions:** the spec's §2 table and §6 out-of-scope list are context, not build steps, so they map to no task. GoElectric, Nestly, and the Evolve7 project card are excluded per §6 — Evolve7 appears only in the now-line, which Task 2 Step 1 gets right.

**Placeholder scan:** no TBDs, no "add error handling", no "similar to Task N". Every code step carries literal content.

**Consistency:** asset filenames `banner-dark.png` / `banner-light.png` match across Task 1 (produce), Task 2 (embed), and Task 2 Step 2 (verify). The palette hex values in Task 1's CSS match the Global Constraints and the shields/stats URLs in Tasks 2 and 4. The `▸` section-marker prefix is used identically in Tasks 2, 3, and 4.
