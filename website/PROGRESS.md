# Selvo website progress

Live URL: not deployed yet (Cloudflare Pages not connected).

## Needs Emily
1. **Connect the site to Cloudflare Pages** (10 minutes, steps in `docs/DEPLOY.md`). Connect `emily-bradley/personalized_communication_companion` with production branch `website-staging` and root directory `website`. As of Thursday 8am there is still no Cloudflare build on any commit; the demo is Friday 6pm.
2. **Then connect `meetselvo.com`** in the Pages project (Custom domains), and once it opens the site, add the build variable `SITE_URL` = `https://meetselvo.com` and redeploy (steps in `docs/DEPLOY.md`). Skip this if time is short: the pages.dev link works on its own.
3. **Backup if Cloudflare is not ready by Friday:** your private claude.ai artifact "Selvo Website Demo" (https://claude.ai/artifact/5xPHjGeAD9yGeEDrarPUKj, published Thursday outside these runs) holds all pages; it can be shared from its Share menu. It is a snapshot, not the deployed site.
4. Create the empty private repo `emily-bradley/selvo-website` and give the Claude GitHub app access (optional; the site can stay where it is through Friday).
5. Before a public launch: `PUBLIC_WAITLIST_URL` for the early-access form, photos of Lucas, the three family FAQ answers, the article date. Full list in `docs/LAUNCH-CHECKLIST.md`.

## 2026-10-22, 7:58am to 8:30am Central (Thursday run 1)

Live URL: not deployed yet (no Cloudflare check or status on 26d4ff3; the pages.dev address cannot be fetched from this session).

**Readings taken:** `selvo-website` still not reachable (no add_repo tool), so work stayed on `website-staging`. Every Thursday build item was already done on Oct 19. The project handoff doc now says the production domain is `meetselvo.com` (bought Oct 20) and that `selvo.com` must never be linked, so this run made the site ready for that domain without risking link previews before it is connected.

**Shipped:**
- `SITE_URL` reads the `SITE_URL` build variable (an https origin) and falls back to `https://selvo-website.pages.dev`. Setting it in Cloudflare switches canonical links, sitemap, robots, and Open Graph URLs to `meetselvo.com` with no code change.
- `docs/DEPLOY.md` custom domain steps rewritten for `meetselvo.com`; launch checklist updated; decision recorded in `docs/DECISIONS.md`. All `selvo.com` mentions removed, and a unit test keeps it out of the site source.

**Verified and how:**
- CI green on 26d4ff3 before changes: https://github.com/emily-bradley/personalized_communication_companion/actions/runs/39338647687
- Local: lint, typecheck, 132 unit tests (new `resolveSiteUrl` tests), build, 67 e2e tests (axe, screenshots, links, keyboard) all pass.
- Built twice: default build gives `https://selvo-website.pages.dev/` canonical and og:image; `SITE_URL=https://meetselvo.com` gives `https://meetselvo.com/` canonical and robots sitemap line.
- Found the existing "Selvo Website Demo" artifact (10 pages) and listed it as a backup in Needs Emily rather than publishing a duplicate.

**Next:** Friday items still wait on a live link: WebFetch every route, record the URL here and in `docs/DEMO.md`, link preview check, screenshot review on the live site, final summary.

## 2026-10-19, 5:57pm to 6:10pm Central (run 4)

Live URL: not deployed yet (no Cloudflare statuses or deployments on aa42dda; only the GitHub Actions check).

**Readings taken:** `selvo-website` still not reachable (403; attaching it was not permitted in this session), so work stayed on `website-staging`. Every build item is done and the open Friday items need the live link, so this run only re-verified and did the parts of the link preview check that can be done before deploy. No code changes, to avoid churn.

**Verified and how:**
- CI green on aa42dda: https://github.com/emily-bradley/personalized_communication_companion/actions/runs/39324575322
- Local: lint, typecheck, 102 unit tests, build (9 pages) all pass.
- Link preview, pre-deploy part: all 9 built pages have a title, `og:description`, `og:image` as an absolute URL, and `twitter:card` `summary_large_image`; `og.png` is 1200x630. The URLs assume the Cloudflare project is named `selvo-website` (step 6 of `docs/DEPLOY.md`); any other name means `SITE_URL` in `src/lib/site.ts` must change or link previews will point at the wrong host.

**Next:** unchanged. Once a pages.dev link exists: WebFetch every route, record the URL here and in `docs/DEMO.md`, check the link preview on the live link, repeat the screenshot review on the live site.

## 2026-10-19, 3:57pm to 4:15pm Central (run 3)

Live URL: not deployed yet (no Cloudflare statuses on any commit; only the GitHub Actions check).

**Readings taken:** `selvo-website` still not reachable (403, no add_repo tool), so work stayed on `website-staging`. Every build item is done and the open Friday items all need the live link, so this run fixed the three nice-to-have items left by run 2's review.

**Shipped:**
- Article "Three choices" and "Forty choices" pictures now share one height, so their titles and notes line up.
- Our story photo placeholder sits on the warm ground instead of white.
- Phone figure replies wrap without a lone last word ("ask twice?" now wraps together at 375).

**Verified and how:**
- Local: lint, typecheck, 102 unit tests, build, 67 e2e tests (axe, screenshots, links, keyboard) all pass.
- Close-up screenshots of the three changed areas at 1440 and 375 reviewed by eye; full-page screenshots regenerated.
- CI green for 72aa046: https://github.com/emily-bradley/personalized_communication_companion/actions/runs/39323984461

**Next:** unchanged. As soon as a pages.dev link exists, verify every route with WebFetch, record the URL here and in `docs/DEMO.md`, check the link preview, repeat the screenshot review on the live site. If Cloudflare is not connected by Thursday, runs keep to polish only.

## 2026-10-19, 1:57pm to 2:20pm Central (run 2)

Live URL: not deployed yet (no Cloudflare statuses on any commit).

**Readings taken:** `selvo-website` is still not reachable (no add_repo tool here either), so work stayed on `website-staging`. All build items were already done in run 1, so this run was a fresh review and polish pass, pulling Tuesday's home fidelity check forward.

**Shipped:**
- Headings use balanced wrapping and paragraphs avoid one-word last lines (site-wide CSS).
- Home hero paragraph sets in three lines at 1440 like the reference; hero top padding trimmed at 375.
- Article meta items ("By ...", date, "4 min read") never break mid-item.
- Removed the home hero fade-in (not in the reference). It doubled Speed Index on home (2.3s to 1.2s) and caused one red CI run where Lighthouse scored home performance 0.86.
- `docs/DEPLOY.md`: Cloudflare's v3 build image defaults to pnpm 10.11 and does not read `packageManager`; added a `PNPM_VERSION=10.28.0` fallback if the install step fails.

**Verified and how:**
- Local: lint, typecheck, 102 unit tests, build, 67 e2e tests (axe, screenshots, links, keyboard), Lighthouse 100 in all four categories on all six pages.
- CI: run for 50fa90c was red (home performance 0.86, read through the GitHub job log); fixed by 93e1a71, green: https://github.com/emily-bradley/personalized_communication_companion/actions/runs/39309253737
- Screenshots: all pages at 1440, 768, 375 rendered next to the references. Two fresh reviewer subagents (one for home, one for inner pages) who had not seen the code reviewed the strips. Inner pages: no must-fix items. Home: three line-break issues, all fixed and re-checked.

**Not done (nice-to-have from review, left for Friday polish if time):** article comparison captions sit at slightly different heights; Story photo placeholder is white rather than beige; phone figure line "Is it lunch yet, or do I have to ask twice?" wraps one word.

**Next:** as soon as a pages.dev link exists, verify every route with WebFetch, record the URL here and in `docs/DEMO.md`, check the link preview, and repeat the screenshot review on the live site.

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
