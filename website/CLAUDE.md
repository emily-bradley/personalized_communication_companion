# Selvo website: rules for agents

Read `PLAN.md` and `PROGRESS.md` before doing anything. Design references are in `docs/design/` (website artboards in `docs/design/website/*.dc.html`, approved color direction in `Site-Option-B-Warm.dc.html`, brand book in `docs/design/system/`).

## Where this lives right now
- Until `emily-bradley/selvo-website` exists, this site lives in `website/` on the `website-staging` branch of `emily-bradley/personalized_communication_companion`. Never touch `main` of that repo; it belongs to the app agent.
- When the real repo exists, copy `website/` into its root, move `.github/workflows/website.yml` to it (drop the `working-directory` and path filters, trigger on `main`), and note the move in PROGRESS.md.

## Stack (decided)
Astro, TypeScript strict, pnpm, Tailwind v4 with tokens as CSS custom properties, Biome, Vitest, Playwright plus `@axe-core/playwright`. Static output to `dist/`. Cloudflare Pages through its Git integration.

## Working rules
- Work the next unchecked items in `PLAN.md`, in order. Check an item off only when it is verified.
- Before pushing: `pnpm lint && pnpm typecheck && pnpm test && pnpm build && pnpm e2e`. Look at the screenshots in `screenshots/` next to the references (`python3 scripts/render-reference.py`, `node scripts/screenshot-references.mjs`, `python3 scripts/compare.py`).
- Small conventional commits (`feat:`, `fix:`, `test:`, `ci:`, `docs:`). Never force-push or rewrite history. `git fetch` and rebase before pushing.
- After every push, check the Actions run with `gh api` REST (GraphQL is blocked). Red CI is the top priority.
- Never delete files you did not create in the current run. No analytics or tracking scripts.

## Design and copy rules
- Colors, radii, shadows, and fonts come only from `src/design/tokens.json` (generated into `src/styles/tokens.css` by `pnpm tokens`). No hex literals in components; a test enforces it.
- Midnight (Nightlight) only in the home hero and the phone figure. Every other surface is the warm set. Footer is charcoal.
- Copy matches the artboards exactly. Keep every `[BRACKETED]` placeholder visible and list it in `docs/LAUNCH-CHECKLIST.md`. Never invent facts, prices, quotes, or photos.
- No em dashes or en dashes anywhere. No exclamation marks in site copy. Never "user", "voiceless", "give a voice", "patient". Product terms exactly: Speak, Incorrect, Another, Show.
- Wordmark: "Se" plus three sound bars plus "vo" in teal. One glowing object per page at most (the home orb).
- Touch targets 44px minimum, 3px focus rings, one `h1` per page, semantic landmarks, no horizontal scroll at 375px.
