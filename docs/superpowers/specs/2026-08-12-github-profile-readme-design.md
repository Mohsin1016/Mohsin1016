# GitHub Profile README Redesign — Design Spec

**Date:** 2026-08-12
**Repo:** `Mohsin1016/Mohsin1016` (GitHub profile README)
**Goal:** Replace the current flat plain-text README with an editorial, dark-premium profile that reads as designed rather than templated, weighted to freelance clients while still satisfying hiring managers and engineers.

---

## 1. Context and constraints

### What exists today
The current README is 59 lines of flat markdown: an H1, three bullet points, five skill lines, four project blocks, a single-line link row, and one unstyled `github-readme-stats` card. It has no banner, no visual hierarchy, and no accent colour.

### What was already tried and rejected
Git history shows a full badge-wall phase (commits `1f2513a` through `313aca9`) using dozens of `shields.io` icons and nested HTML tables, which was then deliberately stripped back to the current minimal version in `5c67502`. **The redesign must not reintroduce a badge wall.** Badges are permitted only as sparse, palette-consistent accents.

### Audience
All three of clients, hiring managers, and engineers — weighted to clients. Outcome-led content above the fold, technical depth below.

---

## 2. Authorship audit (basis for all project claims)

223 repos were surveyed read-only across 7 owners (`Mohsin1016`, `techanzy`, `Born-to-Run-Partners`, `bemomentiq`, `PzP-Organization`, `E-Gnite-Link-AI-Systems`, `KCC-CN`). Commits exist in 109. Per-repo contributor counts were pulled via `GET /repos/{owner}/{repo}/contributors` because org membership does not imply authorship.

`contributionsCollection` (GraphQL) is unusable here — it reports only 105 commits for the last year, all in personal repos, because private org contributions are not exposed for this account. The contributors API is the authoritative source.

### Verified commit shares

| Project | Repos | Mohsin's share | Last commit by Mohsin |
|---|---|---|---|
| GoProperli | `techanzy/goproperli_backend` | **308/334 (92%)** | 2026-06-30 |
| | `techanzy/goproperli_frontend` | 37/143 (26%) | |
| | `techanzy/goproperli-automation` | 17/110 | |
| | `techanzy/pro-goproperli-foreclosure-script` | 10/10 (100%) | |
| B2R Thunder Road | `techanzy/b2r-backend` | **242/381 (64%)** | 2026-03-18 |
| | `techanzy/b2r-frontend` | **207/318 (65%)** | |
| | `techanzy/b2r-extension` | 30/44 (68%) | |
| CryptoWater | `Mohsin1016/pro-crypto-water-front` | **242/259 (93%)** | 2026-06-22 |
| PetzyPets | `PzP-Organization/petzypets` | **128/134 (96%)** | 2026-04-16 |
| | `PzP-Organization/petzypets-backend` | 20/90 (22%) | |
| Django Template | `techanzy/Django-Template` | **117/121 (97%)** | 2026-06-04 |
| Ctrl Assist | `techanzy/proj-ctrlassist-frontend` | 74/252 (29%) | 2025-10-24 |
| | `techanzy/ctrlassist-backend` | 8/56 (14%) | |
| MomentIQ | `bemomentiq/momentiq-shopinsights-backend` | **19/9,796 (0.2%)** | 2026-07-22 |
| | `bemomentiq/momentiq-shopinsights-frontend` | 4/5,626 | |
| DreamGuest | *no repo found on any accessible org* | unverifiable | — |
| AI-Guard | *no repo found; closest `techanzy/vai-*` at 4/11* | unverifiable | — |

### Claim rules derived from the audit

1. **GoProperli leads.** It is the most-owned substantive system. Verified internals: `scraper/` (`broward_clerk_http.py`, `playwright/`, `browser_use/`, `foreclosure_analysis.py`, `folio_from_legal_matcher.py`, `pipeline.py`, `gemini/`) and `properties/` (`bq_service.py`, `warehouse_sync.py`), with real tests.
2. **MomentIQ is described as a contribution, never as ownership.** 0.2% share; top contributors are `Alexelsea` (4,875) and `claude` (3,470). The honest framing is stronger anyway: surgical senior changes inside a ~10k-commit production platform. Evidenced commits: TikTok Shop OAuth (`/authorization/202309/shops` cipher-returning endpoint), `disable server-side cursors + prepared statements under PgBouncer transaction pooling`, per-shop canary allowlists for bulk order/product/collaboration upserts, `live_sessions.gmv_amount` NOT NULL drift repair.
3. **Ctrl Assist keeps its card but loses the lead position.** 29%/14% share and ~10 months stale does not support first billing.
4. **DreamGuest and AI-Guard are retained** at user request, described by capability with their live links, with no authorship percentage attached.
5. **No invented metrics.** Any number on the page must be verifiable from the GitHub audit or supplied by the user.

### Methodology caveat: inherited template history

Repos generated from `techanzy/Django-Template` inherit the template's commit history, so a contributor count in a descendant repo can include template commits rather than product work. This inflates apparent ownership in `goelectric-backend` (112/120), `servellm-backend-v2`, `codecell-ai-backend`, `mdt-v2-backend`, `tz-miner-backend`, `tz-miner-v1-backend`, and `tz-accounts-backend`.

Consequently **no featured claim rests on a template descendant.** The template itself is claimed (that authorship is direct), and its descendants are cited only as a count of downstream services — not as projects Mohsin built.

The lineup is unaffected: GoProperli is cookiecutter-django-based rather than template-derived, and its app code (`scraper/`, `properties/`, `cases/`, `prompts/`) is plainly product-specific. B2R, CryptoWater, and PetzyPets are not template descendants either.

### Live-link verification
All returned HTTP 200 on 2026-08-12: `app.ctrlassist.com/login`, `thunderroad.b2rpartners.com/dashboard`, `app.dreamguest.com`, `portfolio1-olive-seven.vercel.app`, `pro-crypto-water-front.vercel.app`, `goproperli-frontend.vercel.app`.

---

## 3. Visual design

### Palette
| Token | Value | Use |
|---|---|---|
| `ground` | `#0B0F14` | banner background (near-black, not pure) |
| `accent` | `#22D3EE` | rules, numerals, section markers, link pills |
| `accent-dim` | `#0E7490` | secondary strokes, motif lines |
| `text` | `#E6EDF3` | primary banner text |
| `muted` | `#8B98A5` | supporting banner text |

Cold cyan-teal on near-black reads technical and premium rather than startup-bright, and stays legible against both GitHub themes.

### Typography
Banner type is rendered locally, so any font may be used in the source and is baked into the output raster. Body copy uses GitHub's own markdown type — no attempt to override it.

### Banner asset pipeline

Fonts cannot be fetched inside a GitHub-proxied SVG (camo serves it under `default-src 'none'`), so an SVG banner would fall back to whatever font the viewer happens to have. To guarantee identical typography for every visitor, the banner is authored in HTML and rasterised locally.

- **Source (committed, editable):** `assets/banner.html`
- **Renderer:** local Playwright Chromium (verified present at `~/Library/Caches/ms-playwright/chromium-1234`)
- **Outputs:** `assets/banner-dark.png`, `assets/banner-light.png` at **2560×600**, displayed at `width="1280"` for 2× retina crispness
- **Embedding:** a `<picture>` block with `prefers-color-scheme` so the banner suits both GitHub themes

```html
<picture>
  <source media="(prefers-color-scheme: dark)"  srcset="assets/banner-dark.png">
  <source media="(prefers-color-scheme: light)" srcset="assets/banner-light.png">
  <img src="assets/banner-dark.png" width="1280" alt="Mohsin Khalid — Backend Engineer">
</picture>
```

Paths are repo-relative so they survive the repo being renamed or forked.

**Banner content:** name in large tight-tracked type, a one-line role statement, and a restrained motif — a thin waveform/grid figure in `accent-dim` at low opacity, nodding to real-time audio and data pipelines without becoming decoration.

---

## 4. Page structure

Top to bottom:

1. **Hero** — banner `<picture>`, centred.
2. **Link row** — four flat pills: Portfolio, LinkedIn, Email, GitHub. Palette-matched, `flat-square`, no logos-as-noise.
3. **Metrics strip** — four verifiable figures from §2: `109` repos contributed to · `7` production backends on my Django template · `92%` authored on GoProperli · `6` orgs shipping. Swapped for business metrics if the user supplies them.
4. **Now** — one "currently building" line plus a subtle availability signal and mailto CTA.
5. **Featured work** — 2×2 HTML table, greatest visual weight. Each card: numbered marker, name, one-sentence outcome, tech line, live link.
   - `01` GoProperli — county records → foreclosure/probate pipeline → Gemini analysis → BigQuery warehouse
   - `02` B2R Thunder Road — B2B outreach automation at scale
   - `03` Ctrl Assist — real-time call assistance, low-latency audio
   - `04` DreamGuest — multi-tenant guest-management SaaS
6. **Also shipped** — compact three-up row: CryptoWater (live), PetzyPets (Flutter), AI-Guard.
7. **Engineering signals** — the credibility block, two entries:
   - MomentIQ — TikTok Shop OAuth and sync, Postgres-under-PgBouncer performance work inside a ~10k-commit production platform
   - Django Template — authored the scaffolding 7 production backends run on
8. **Stack** — grouped compact rows by role (Backend / Real-time & AI / Data / Cloud / Frontend). Sparse and palette-consistent; explicitly not a wall.
9. **How I work** — short client-facing block: end-to-end ownership, how work is scoped, communication cadence.
10. **Stats** — `github-readme-stats` cards themed to the palette (`bg_color`, `title_color=22D3EE`, `hide_border=true`), paired with top-languages. Streak and trophy cards are excluded as clutter.

Horizontal hairline rules separate sections. Section headings use a small-caps-feel label plus an accent marker rather than large markdown headers, to keep the editorial tone.

---

## 5. Decisions taken without user input

These were unanswered at spec time; defaults chosen so the page ships complete. Each is a one-line edit to change.

- **Currently building** → Evolve7, the Flutter "intelligent life operating system" in `E-Gnite-Link-AI-Systems/Evolve7`. Chosen because it is 100% authored (52/52 app, 22/22 backend) and carries the most recent commit found (2026-08-06, `fix(tasks): close edge cases found in a post-implementation audit`).
- **Availability** → "open to freelance and contract work", contact `muhammadmohsin1016@gmail.com`.
- **Location / timezone** → **omitted.** Not known and not inferable; the "How I work" block covers ownership, scoping, and cadence without it. A timezone-overlap line can be added later.
- **Metrics strip** → GitHub-verifiable figures rather than business figures, since none were supplied.

---

## 6. Out of scope

- No changes to any repo other than `Mohsin1016/Mohsin1016`. The audit was strictly read-only.
- GoElectric (93% authored) and Nestly are omitted from the lineup by user choice, despite strong ownership. Evolve7 appears only in the "currently building" line, not as a card.
- No animated typing headers, streak cards, trophy cards, or visitor counters.

---

## 7. Success criteria

1. The page does not resemble a `shields.io` template profile.
2. Every factual claim traces to §2 or to user-supplied input.
3. MomentIQ is described so that no reader could conclude Mohsin owns it.
4. The banner renders correctly in GitHub light and dark themes, and on mobile.
5. All outbound links resolve (200) at publish time.
6. GoProperli occupies the lead position.
