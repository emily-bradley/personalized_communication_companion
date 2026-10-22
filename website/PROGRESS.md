# Selvo website progress

Live URL: **https://selvo-website.pages.dev** (Cloudflare Pages connected Oct 22 between 8:30 and 10am; production branch `website-staging`). Every push since 6e523cc shows a "Cloudflare Pages: Deployed successfully" check. This session cannot open pages.dev (WebFetch needs approval nobody is there to give), so the live site has not been opened from here yet.

## Needs Emily
1. **Open https://selvo-website.pages.dev once** on your phone and paste it into a message to yourself to check the preview card. Runs cannot open it from here.
2. **Optional: connect `meetselvo.com`** in the Pages project (Custom domains), and once it opens the site, add the build variable `SITE_URL` = `https://meetselvo.com` and redeploy (steps in `docs/DEPLOY.md`). The pages.dev link works on its own for Friday.
3. Create the empty private repo `emily-bradley/selvo-website` and give the Claude GitHub app access (optional; the site can stay where it is through Friday).
4. Update the website artboards to the four reworded lines (people who cannot read), listed in `docs/DECISIONS.md`.
5. Before a public launch: `PUBLIC_WAITLIST_URL` for the early-access form, photos of Lucas, the three family FAQ answers, the article date. Full list in `docs/LAUNCH-CHECKLIST.md`.

## 2026-10-22, 3:58pm to about 4:15pm Central (Thursday run 5)

Live URL: https://selvo-website.pages.dev (Cloudflare check on 21afa86: "Deploy successful", preview https://a09f7ad6.selvo-website.pages.dev).

**Readings taken:** A run at 3:11pm added Emily's rule that the people Selvo is for cannot read, write, or speak. This run audited the copy of every page against it and reworded the four lines that assumed the person reads words, taking the new rule over "copy matches the artboards" (recorded in `docs/DECISIONS.md`). No new claims about the app. WebFetch of the live site was again not approved, so the live site is still unopened from here.

**Shipped:** How it works step 3 and three lines of the three replies article reworded (details in DECISIONS.md).

**Verified and how:**
- CI green on 21afa86 before changes: https://github.com/emily-bradley/personalized_communication_companion/actions/runs/39846700019
- Local: lint, typecheck, unit tests, build (9 pages), 67 e2e tests (axe, screenshots, links, keyboard, meta) all pass.
- Read the visible text of all six content pages from the build; looked at the article figure at 375 after the change (wraps cleanly).

**Next (Friday):** open the live URL if a run is allowed to, final summary in PROGRESS.md. No new features.

## 2026-10-22, 1:58pm to about 2:15pm Central (Thursday run 4)

Live URL: https://selvo-website.pages.dev (last confirmed deploy: bd993cf, "Deploy successful", preview https://bd7226e1.selvo-website.pages.dev).

**Readings taken:** Every Thursday item is done and the open Friday items need the live site opened, which this session still cannot do (WebFetch approval withdrawn again; no other fetching allowed). So this run only re-verified, with no code changes, to avoid churn the day before the demo. The Cloudflare check on c30beda (docs only) was still "Building" 1 hour 45 minutes after it started; the site content is identical to bd993cf, which deployed, so the live site is unaffected. This push starts a fresh Cloudflare build; the result is noted below.

**Verified and how:**
- CI green on c30beda: https://github.com/emily-bradley/personalized_communication_companion/actions/runs/39821468050
- Local: lint, typecheck, 132 unit tests, build (9 pages), 67 e2e tests (axe, screenshots, links, keyboard, meta) all pass.

**Next (Friday):** open the live URL if a run is allowed to, final summary in PROGRESS.md. No new features.

## 2026-10-22, 11:58am to about 12:25pm Central (Thursday run 3)

Live URL: https://selvo-website.pages.dev (Cloudflare check on f0df422: "Deploy successful", preview https://04f0d985.selvo-website.pages.dev).

**Readings taken:** WebFetch of the pages.dev address and of the preview URL was again not approved in this unattended run, so the live site is still unopened from here; the local build of the same commit stands in. With Thursday done, this run pulled Friday work: a review at 768 (earlier reviews only spot-checked tablet) and the launch checklist.

**Shipped:**
- Home "Helping someone get started?" line no longer leaves "using it." as a lone word at 768.
- PLAN: `docs/LAUNCH-CHECKLIST.md` checked off after cross-checking every `[PHOTO]`, `[CONFIRM]`, `[YOUR PRICE]`, and `[DATE]` placeholder in `src` against it; nothing missing.

**Verified and how:**
- CI green on f0df422 before changes; Cloudflare deployed it.
- Local: lint, typecheck, 132 unit tests, build, 67 e2e tests (axe, screenshots, links, keyboard, meta) all pass.
- Fresh reviewer subagent (had not seen the code) compared all seven pages at 768 with the rendered references: no must-fix. Checked its notes: footer and Sources links already have 44px targets (`min-h-11`), so no change; the email placeholder stays muted ink for AA contrast; "Read the guide" stays muted on purpose while the guide does not exist; the "Built for adults" values, early-wrapping balanced headings, and lone last-row cards match the reference or earlier decisions and were left.
- Close-up of the changed line at 768 reviewed by eye.
- CI green on bd993cf: https://github.com/emily-bradley/personalized_communication_companion/actions/runs/39820852623 ; Cloudflare deployed it.

**Next (Friday):** open the live URL if a run is allowed to, final summary in PROGRESS.md. No new features.

## 2026-10-22, 9:58am to about 10:40am Central (Thursday run 2)

Live URL: https://selvo-website.pages.dev (Cloudflare check on 6e523cc and 177d463: "Deployed successfully"; first deploy preview https://dbe4b4b6.selvo-website.pages.dev).

**Readings taken:** The Cloudflare check names project `selvo-website` and shows no separate branch preview URL, so `website-staging` is the production branch and the production address is `selvo-website.pages.dev`. WebFetch of pages.dev was not approved in this unattended run, and the rules forbid fetching another way, so live checks are left to Emily or a later run. Since Cloudflare builds the same commit, the local build stands in for the live one for tags and screenshots.

**Shipped (177d463):**
- Article pages use `og:type` article; the 404 is `noindex` with no canonical link (it pointed at `/404/`). e2e test covers both.
- Article byline at 375 now reads "By Emily Kenney, co-founder" then "[DATE] · 4 min read" instead of leaving a dangling dot; one line at 768 and up.
- Removed an extra 112px spacer before the early-access card on the article page.
- Articles featured card: "Read the guide" is muted, not teal, so it no longer looks like a link while the guide does not exist.
- `docs/DEMO.md` now has the live link; PLAN and launch checklist updated.

**Verified and how:**
- Local: lint, typecheck, 132 unit tests, build, 67 e2e tests (axe, screenshots, links, keyboard, meta) all pass.
- Link preview tags read from every built page: title, description, absolute `og:image` on pages.dev, 1200x630 image.
- Fresh reviewer subagent (had not seen the code) compared every page at 1440 and 375 (768 spot-checked) to the rendered references: no must-fix. Fixed its byline, spacing, and fake-link notes; left as is: a few balanced headings wrap early at 375, phone figure line wraps at 1440, footer links take two rows at 375, Privacy and Accessibility are stubs (skip them in the demo).
- CI green: https://github.com/emily-bradley/personalized_communication_companion/actions/runs/39802638014 ; Cloudflare deployed 177d463.

**Next (Friday):** open the live URL (if allowed) and walk every route, keyboard walk-through on the live site, final summary in PROGRESS.md. No new features.

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
