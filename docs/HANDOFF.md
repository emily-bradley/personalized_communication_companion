# Selvo website and iPhone app: build handoff

For a coding agent. Build from these sources, in this order of authority:

1. Design system (tokens, brand book, voice rules): https://claude.ai/artifact/DSkCFnCBtYSmmUZDFnjCcZ (read `project/README.md` and `project/tokens.json`)
2. Design canvas (mockups, copy, clickable flows): https://claude.ai/artifact/6ifzVakZ3zXrTKgkN8Lshv
   - Website: artboards `Orb-Site-*.dc.html`, row titled "Selvo website, Nightlight"
   - iPhone: artboards `App-*.dc.html`, row titled "Selvo iPhone app, Nightlight"
   - Each artboard is self-contained HTML with inline styles; the exact values in it are the spec. Copy in the artboards is final unless marked `[LIKE THIS]`.
3. This document, for anything the artboards cannot show (behavior, breakpoints, data, open items).

Brand copy rules apply to every string in both builds: plain words, second person, no em dashes or en dashes, no exclamation marks, no "user", "voiceless", "give a voice". Product terms match the interface exactly: Speak, Incorrect, Another, Show.

## Tokens

Use the design system's `tokens.json` as the single source. Generate CSS custom properties (web) and a Swift color/type catalog (iOS) from it; do not hand-copy hex values into components. Summary:

| Token | Nightlight | Daylight | Use |
|---|---|---|---|
| surface | #0f1530 | #f5f6fa | page and screen ground |
| surface-raised | #1a2147 | #ffffff | cards, tiles, message strip |
| surface-sunken | #0a0e24 | #e7eaf2 | wells, disabled fills, alternate section bands |
| surface-brand-tint | #163b47 | #ddf3ee | selected tile or suggestion, always with a 3px focus ring or a check |
| indigo | #29285d | #e3e3f4 | decorative wash, upper-left corner of marketing pages only |
| ink | #f4f5f8 | #0f1530 | text |
| ink-muted | #b4b9cf | #4a5072 | captions, helper text |
| teal | #7fd6c6 | #0e5e51 | links, quiet actions, "vo", focus ring, Spoken |
| primary / on-primary | #3bb8a2 / #0f1530 | #0e5e51 / #ffffff | Speak and the one primary action |
| orb / orb-glow | #3bb8a2 / #a2edde | same | the mark only, never UI state |
| danger | #ff8f7e | #b3361f | Help, Delete, the attention screen, nowhere else |
| hairline | #2a3158 | #d5d9e5 | card edges, dividers |
| border-strong | #8089b0 | #6e7491 | secondary buttons, inputs, Another and Incorrect |

Type: Lexend only (Google Fonts, weights 400 and 600). Styles: display 48/54 600 -0.01em; lead 22/34 400; message 30/40 400; heading 22/28 600; label 17/22 600; body 17/26 400; caption 14/20 400. Nothing below 14px. Semibold is the heaviest weight; no bold, light, or thin.

Spacing: 4, 8, 12, 16, 24, 32, 48. Touch targets: 44px minimum, tiles 96px, Speak 64px tall. Radii: 8 chips, 16 tiles and cards and inputs, 24 sheets and the message strip and large photo frames, 999 buttons and chips.

Shadows: `shadow-sheet` (0 12px 32px rgba(5,8,20,0.6)) only under Speak and modal sheets. `glow-orb` (0 0 80px 24px rgba(59,184,162,0.35)) only on the orb. One glow per screen.

## The mark

Use the logo files from the design system's `assets/Brand` group in production. The mockups draw the wordmark live (Lexend 600, -0.02em, "Se" + three sound bars + "vo" in teal) so the copy stays editable in the canvas; do not ship that drawn version. Clear space equals the height of the "e". Below 96px wide use the orb alone. Favicon and app icon: the three sound bars on the orb.

Sound bars geometry (for loading states and the Speak glyph): viewBox 0 0 54 104, three pills, rx 5, width 10: x4 y30 h44; x22 y6 h92; x40 y38 h28.

## Website

Static site, six routes. Suggested stack: Astro (matches the Tech with Emily site) on Cloudflare Pages, or any static generator; no client framework needed. One shared layout: header, footer, early-access form.

Routes and artboards:

| Route | Artboard | Notes |
|---|---|---|
| `/` | Orb-Site-Home | hero, positioning strip, How Selvo works (3 cards), Words that sound like you (phone figure), Built for adults (6 pillars), It started with Lucas, family strip, early access, footer |
| `/how-it-works` | Orb-Site-HowItWorks | 3 numbered steps with product visuals, Five places to start, Show it instead, Made to keep up |
| `/story` | Orb-Site-Story | photo, four paragraphs (final copy, from the brand book), mission band, What Selvo is / is not |
| `/family` | Orb-Site-Family | 3 setup cards, 5-step afternoon list, FAQ accordion (native `<details>`) |
| `/articles` | Orb-Site-Articles | featured guide card + 3 article cards |
| `/articles/three-replies` | Orb-Site-Article | dark header, Daylight-tokened reading column 720px, sources |

Header: wordmark (links home), four nav links, "Get early access" white pill (44px). Active page: ink text with a 2px teal underline. On the artboards every "Get early access" links to `#access`, the form section at the bottom of the same page; keep that behavior.

Footer: small wordmark, six links (Privacy and Accessibility pages are not designed; stub them), the line "Selvo is a communication companion, not a medical device."

Early-access form: `label` Email address, `input type=email` (56px pill, border-strong, surface ground), submit "Join the list" (56px white pill), helper "One email when it is your turn. Nothing else." Success state replaces the form in place: teal check, "Saved." in teal 600, then "You are on the list." Wire the POST to [YOUR FORM BACKEND: Buttondown, ConvertKit, or a Cloudflare Worker]. Validate on submit only; error text in `danger` with a word, never color alone.

Layout and breakpoints: content column max 1248px, 24px side padding. Every section on the artboards is flex-wrap or `repeat(auto-fit, minmax(280px, 1fr))`, so there is one breakpoint behavior: columns stack under about 640px, the hero stacks with the orb below the copy, the nav wraps to two rows (an overflow menu is acceptable under 480px). Headline sizes use `clamp()` as written in the artboards. No horizontal scroll at 375px.

Indigo wash: one absolutely positioned 820x640 ellipse, `indigo`, opacity 0.9, blur 140px, at left -220 top -260, `pointer-events: none`, on marketing pages only. Not on the article reading column.

Motion: fades only, nothing loops. Respect `prefers-reduced-motion`.

Accessibility: semantic landmarks (`header`, `nav` with labels, `main`, `footer`), one `h1` per page, real `a`/`button`/`input`/`label`, focus ring 3px teal 2px offset on every interactive element, `aria-current="page"` on the active nav link, decorative SVG `aria-hidden`. All text pairs in the tokens table pass WCAG AA; most pass AAA. Lighthouse accessibility 100 is the bar.

Placeholders to replace before launch: `[PHOTO: ...]` frames (Home story, Story page, article cards) with real photographs of Lucas and family in `radius-lg` frames on `surface-raised`, never full-bleed behind text; `[DATE]` and read time on the article; `[CONFIRM: ...]` and `[YOUR PRICE]` answers in the family FAQ; Privacy and Accessibility pages.

## iPhone app

Native SwiftUI, iOS 17+. The mockups are 390x844 (iPhone 15/16 class); design for Dynamic Type and larger screens, never for a fixed frame.

Screens and artboards (all in the "Selvo iPhone app" row; Play on the canvas walks the flow):

| # | Artboard | Screen | Behavior |
|---|---|---|---|
| 1 | App-Welcome | Welcome | orb, wordmark, tagline, "Set up together" (primary), "I already have a profile" (quiet) |
| 2 | App-Setup | Supporter setup, step 2 of 5 | 5-step progress bar; this step adds people with a photo and a note; "Add a person" dashed row; Continue is the pinned 64px bar. Other steps (places, phrases, text size and theme side by side, voice) follow the same template. |
| 3 | App-Home | Home | wordmark, Settings gear, Help pill (danger outline), empty message strip "Tap a picture to start.", greeting caption, five destinations: Photos, Places, People, Phrases as 2x2 tiles, Listen full width; Speak pinned, disabled until the strip has a message |
| 4 | App-Photos | Tile grid | Back, title, Help; message strip shows the chosen label; 3-column grid of 96px+ tiles (photo + label), page dots; selected tile = tint + 3px teal ring. Places, People and Phrases reuse this screen with their own data. |
| 5 | App-Suggest | Choose your words | Back, title, Clear (top right, far from Speak); message strip bound to the selected suggestion; Show and Undo under the strip; stack of exactly three suggestion cards with a caption "Suggested for Lucas · style"; Another and Incorrect (44px outline pills); Speak 64px |
| 6 | App-Show | Show | message in 44px on `surface-sunken`, rotated 180 degrees toward the listener; Done at the bottom for the holder |
| 7 | App-Listen | Listen | the orb (one glow), "Listening", heard text in a raised card with the speaker's name, "Show replies" quiet, "Stop listening" primary |
| 8 | App-Help | Help | confirm screen first (Cancel quiet, "Yes, show it" in danger); then the attention screen: full `danger` ground, `on-primary` text, the person's chosen phrase in 44/30 type, Done outlined. Two taps, always. |
| 9 | App-Settings | Settings | Text size A/A/A segmented with a live preview; Theme as two side-by-side swatches (Nightlight, Daylight); speech rate slider; reading font Lexend or Atkinson Hyperlegible; Voice row |
| 10 | App-Home-Day | Home, Daylight | same screen on Daylight tokens; every screen must render in both themes from the same code |

Interaction rules (from the brand book; the mockups follow them):

- Two taps from anywhere to a spoken message: tile, suggestion, Speak.
- Tile positions never move. Grow by paging or unhiding, never reflowing. Persist order per profile.
- Same controls, same place: Speak bottom center full width; Back top left; Clear top right, at least 48px from Speak and never beside it; Help top right.
- Suggestions arrive as a stack of three. Another replaces the whole stack; Incorrect removes one and logs negative feedback for the model. Selection: tint + 3px teal ring + check in `primary`.
- Speak: single haptic tap, speak the strip text with the chosen voice, then show a check and "Spoken" in teal for about one second (the Another/Incorrect row swaps to that status). The sound bars may rise and settle once during speech; nothing else animates.
- Back and Undo always visible on composing screens; nothing auto-dismisses; no toasts that time out. Destructive actions confirm twice.
- Offline: saved phrases and tiles work without a network; suggestions fall back to saved phrases with a caption, never a blank screen or a spinner that blocks Speak.
- Settings live inside Selvo, set by the supporter at onboarding and changeable by the person: text size, contrast, theme, speech rate, voice, reading font.
- Disabled Speak is `surface-sunken` fill with `ink-muted` label; never grey out a photo.

Data model (minimum): Profile (name, theme, text size, speech rate, voice, reading font, style tags), Person / Place / Phrase / Photo tiles (image, label, position, hidden flag), Suggestion (text, style tag, source, feedback), Help phrase.

Suggestion generation: a pluggable `SuggestionProvider` protocol with two implementations, an on-device or remote model call and a saved-phrase fallback. The UI never waits on the provider: it renders the strip and controls immediately and fills the stack when results arrive.

Accessibility: VoiceOver labels on every control (icon-only buttons included), Dynamic Type through the `label`/`body`/`message` styles, `reduceMotion` honored by replacing transitions with fades, minimum 44pt targets, both themes meet AA on every text pair.

Not designed yet, build from the same components: Places, People and Phrases grids (reuse App-Photos), setup steps 1, 3, 4, 5, tile editing (add, hide, reorder by the supporter), voice picker, attention-phrase editor, profile switch.

## Components shared by both builds

- Wordmark and orb (from the design system assets)
- Primary pill button (64px in the app, 56px on the web hero, 44px in the web header)
- Quiet pill button (border-strong outline, 44 or 56px)
- Message strip (raised, radius 24, message type)
- Suggestion card (raised or tint, radius 16, body type, optional caption)
- Tile (raised, hairline, photo + label, radius 16, 96px minimum)
- Early-access form (web) and inputs (56px pill, border-strong)

## Definition of done

Website: six routes render from the artboards at 1440, 1024, 768 and 375 wide with no horizontal scroll; forms post and show the in-place success state; Lighthouse accessibility 100 and performance 90+; fonts self-hosted or preconnected; every `[placeholder]` either replaced or listed in a launch checklist.

App: the ten screens match the artboards in both themes; the Welcome to Speak flow works end to end with the saved-phrase provider and no network; VoiceOver can complete the same flow; snapshot tests per screen per theme at default and accessibility XL text sizes.
