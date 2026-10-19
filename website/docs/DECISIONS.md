# Decisions

## Oct 19, 2026: warm color direction (Emily)
Emily said white is boring, but midnight is too dark to use everywhere; she likes midnight on the home page.

- Midnight (Nightlight navy, indigo wash, glowing orb, white "Sel" and mint "vo", white "Get early access" pill) only in the home page hero. The phone figure stays Nightlight because it shows the app.
- Everything else uses the warm set from `docs/design/website/Site-Option-B-Warm.dc.html`: ground `warm-ground`, alternate bands `warm-band`, cards `warm-card`, ink `warm-ink`, muted `warm-muted`, links and primary buttons `warm-teal` with white text, a soft `warm-tint` band at most once per page, hairlines `warm-hairline`, control borders `warm-border`.
- Inner pages open on the warm alternate band with the wordmark in ink and teal.
- Footer is charcoal (`footer-ground`) with light text and mint "vo".
- Tokens live in `src/design/tokens.json` with the `warm-` prefix. Every text pair is checked for WCAG AA in `tests/contrast.test.ts`.
- Follow-up: the Selvo design system (`docs/design/system/tokens.json`) should be updated to add the warm set.

## Oct 19, 2026: where the site lives until its repo exists
The run could not reach `emily-bradley/selvo-website`, so the site is built in `website/` on the `website-staging` branch of `personalized_communication_companion`, as the run instructions say. The app agent's `main` is untouched.

## Oct 19, 2026: smaller calls made without Emily
- Lexend is self-hosted (`@fontsource/lexend`, weights 400 and 600) instead of loaded from Google Fonts: faster, and no third-party requests.
- The early-access form validates on submit only. Error text is in the danger color and starts with the word "Error". With no `PUBLIC_WAITLIST_URL`, it shows the success state and sends nothing.
- Inner pages that are not built yet show a short "on its way" page so no link in the header breaks before Wednesday.
- No Content Security Policy header yet, because Astro inlines small scripts. Revisit on Friday.
