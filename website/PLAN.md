# Selvo website plan

Deadline: Friday, October 23, 2026, 6pm Central. Demo-ready at a public link.

## Mon Oct 19: foundation and deploy-ready
- [x] Repo set up (Astro, TypeScript strict, pnpm, Tailwind v4, Biome, Vitest, Playwright, axe)
- [x] Tokens: Nightlight hero set plus warm set, generated CSS custom properties, contrast test
- [x] Base layout, Header, Footer, EarlyAccess components
- [x] CI: install, lint, typecheck, test, build, screenshots at 1440/768/375 as `screenshots` artifact, axe zero serious or critical
- [x] Deploy config: `.node-version`, `public/_headers`, `SITE_URL` constant, `docs/DEPLOY.md`
- [x] `docs/DEMO.md` stub
- [x] Something presentable on `/`

## Tue Oct 20: home
- [x] Home page faithful to the reference at 1440, 768, 375 (hero orb square at every width, positioning strip, steps, phone figure, pillars, story teaser, family strip, early access)
- [x] Reviewer subagent critique of home screenshots, fixes applied

## Wed Oct 21: inner pages
- [x] How it works
- [x] Our story
- [x] For family (FAQ with native `details`)

## Thu Oct 22: articles and site plumbing
- [x] Articles index
- [x] Article page `/articles/three-replies` from Markdown content collection
- [x] Privacy and accessibility stubs
- [x] Friendly 404
- [x] SEO title and description per page (final copy)
- [x] Open Graph image 1200x630, midnight hero style
- [x] Favicon and apple-touch-icon from the sound-bar mark
- [x] Sitemap and robots
- [x] Canonical URLs from `SITE_URL`

## Fri Oct 23: polish and demo
- [ ] Full screenshot review of every page at all three widths against the references (done locally Oct 19 by a reviewer subagent; repeat on the live URL)
- [x] axe clean
- [x] Lighthouse accessibility 100, performance 90 or better (Lighthouse CI in Actions)
- [x] Keyboard walk-through (automated in e2e; repeat by hand on the live URL Friday)
- [ ] Link preview check (Open Graph title, description, image)
- [ ] `docs/DEMO.md` with the live link and a 5-minute walk-through (walk-through drafted; live link pending)
- [ ] `docs/LAUNCH-CHECKLIST.md` complete
- [ ] Final summary in PROGRESS.md
