# Selvo website progress

Live URL: not deployed yet (Cloudflare Pages not connected).

## Needs Emily
1. **Connect the site to Cloudflare Pages** (10 minutes, steps in `docs/DEPLOY.md`). For now connect `emily-bradley/personalized_communication_companion` with production branch `website-staging` and root directory `website`. This is the only thing between you and a live link.
2. **Create the empty private repo `emily-bradley/selvo-website`** and give the Claude GitHub app access. Until then the site lives in `website/` on the `website-staging` branch. (Optional: the site can stay where it is through Friday.)
3. Later, before a public launch: custom domain (`selvo.com` if you can get it), `PUBLIC_WAITLIST_URL` for the early-access form, photos of Lucas, the three family FAQ answers, the article date. Full list in `docs/LAUNCH-CHECKLIST.md`.

## 2026-10-19, 11:57am to 12:30pm Central (run 1)

**Readings taken (Emily was not asked):**
- `emily-bradley/selvo-website` was not reachable from this session (no add_repo tool), so I used the fallback: `website/` on branch `website-staging` of `personalized_communication_companion`. `main` of that repo was not touched.
- Inner pages follow the warm direction, so their references' dark styling was translated to warm tokens. App pictures (phone, tiles, Show card) stay midnight because they show the app.
- Inner page h1s use one shared size (36 to 48px) instead of the references' 40 to 56px, so the pages feel like one site.
- Cards on the Articles page with no article yet keep their copy but are not links, so nothing leads to a missing page.
- Privacy, Accessibility, and 404 also carry the early-access form, so the header's "Get early access" works on every page.

**Shipped:** every day's build items except the ones that need the live link.
- Foundation: Astro 7, TypeScript strict, Tailwind v4 with generated tokens (Nightlight hero set, warm set, footer set), Biome, Vitest, Playwright, axe, self-hosted Lexend.
- Components: Header, Footer, EarlyAccess (validates on submit, posts to `PUBLIC_WAITLIST_URL` when set), Wordmark, Orb, PhoneFigure, PageIntro.
- Pages: home, How it works, Our story, For family (native `details` FAQ), Articles, the three-replies article from a Markdown content collection, Privacy and Accessibility stubs, 404.
- Plumbing: per-page titles and descriptions, canonical URLs and sitemap and robots from `SITE_URL`, Open Graph image (1200x630, midnight hero), favicon and apple-touch-icon, `_headers` with security and cache headers.
- CI: lint, typecheck, unit tests (contrast of every token pair, brand rule scans for dashes, hex literals, banned words), build, Playwright screenshots of every page at 1440, 768, 375 (artifact `screenshots`), axe zero serious or critical, no horizontal scroll, meta and internal link checks, keyboard focus ring test, Lighthouse CI (accessibility 100, performance 90 asserted; artifact `lighthouse`).
- Docs: `CLAUDE.md`, `PLAN.md`, `docs/DEPLOY.md`, `docs/DEMO.md` (walk-through drafted), `docs/DECISIONS.md`, `docs/LAUNCH-CHECKLIST.md`.

**Verified and how:**
- All CI runs on `website-staging` green; latest before this entry: https://github.com/emily-bradley/personalized_communication_companion/actions/runs/39293921971
- Lighthouse locally: performance, accessibility, best practices, and SEO all 100 on all six main pages.
- Screenshots of every page at 1440, 768, 375 compared side by side with the rendered references (`scripts/render-reference.py`, `scripts/compare.py`). Pages were built by three parallel subagents, then two separate reviewer subagents who had not seen the code critiqued the screenshots. Fixed from review: header now stays on one row at 768 and is padded when it wraps; footer sits at the bottom of short pages; Family spacing tightened; hero padding and lede color made consistent; Story photo frame made visible.

**Next (Tue to Fri):**
- As soon as a pages.dev link exists: verify every route on the live site with WebFetch, record the URL here and in `docs/DEMO.md`, check the link preview, and repeat the screenshot review on the live site.
- If `selvo-website` exists by then: copy `website/` into it and move the workflow (steps in `CLAUDE.md`).
- Polish only: no new features are planned. Family step circles were made white for contrast on the band. Remaining candidate polish: none flagged as must-fix.
