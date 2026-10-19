Selvo is a modern communication app for non-verbal adults. Everything in this system follows from one sentence: Selvo does not speak for anyone; it helps people speak as themselves. The identity is Nightlight: a glowing teal voice on a calm night sky. Read this file first. Use the token names exactly; the Research section explains where each rule comes from.

## The mark

The logo is the supplied artwork in `assets/Brand`. Use the file; never retype or redraw it.

- **Wordmark.** "Sel" in `ink`, the "l" drawn as three rounded sound bars (short, tall, short), "vo" in `teal`. The two colors carry the name: self in ink, voice in teal.
- **Orb.** A disc in `orb` with the three sound bars in white, lit from the upper left with `orb-glow` and haloed by `glow-orb`. It is the app icon, the avatar, and the one glowing object on a page.
- **Sound bars.** The three pills alone are the smallest form of the mark: loading states, the Speak glyph, the favicon. Always three, always the middle one tallest, always pills.
- Clear space around the wordmark equals the height of the "e". Minimum wordmark width 96px on screen; below that use the orb.
- On Daylight, "Sel" turns navy and "vo" stays the orb teal as a logotype (exempt from text contrast). Never place the wordmark on a photo or on `indigo`.

## Brand story

When Lucas was 21, a brain aneurysm took his speech, his reading, and his writing. It did not take him. He is still the funniest person at the table, still particular about food, still loyal, still the brother who teases you until you laugh. What changed is the distance between what he means and what the world can hear.

Lucas built his own way across that distance. He points at photos. He opens a map and taps the place. He types a number into a calculator and turns the screen around. He uses his face, his hands, and the people who know him well enough to fill in the rest. It works, mostly, and it is exhausting, and it only works with people who already know him. Every tool asks him to meet it where it is. None of them meet him where he is.

Communication technology for people like Lucas has mostly been built to carry needs: hungry, tired, bathroom, help. Those matter. But a person is not a list of needs. Lucas wants to make the joke, disagree with the plan, tell you the restaurant was bad, and ask how your day went. The systems that exist can get him to "I want food." They cannot get him to the way he would say it.

Selvo exists to close that gap. It learns how a person expresses themselves and offers them words that sound like their own, fast enough to keep up with a conversation, through pictures, context, and choices they control.

## Brand statement

**Purpose.** A person can lose language without losing who they are. Selvo exists so that losing speech does not mean losing your voice.

**Mission.** Help non-speaking adults communicate more easily, independently, and as themselves, with technology that learns how they express who they are.

**Vision.** A world where everyone has dignified access to connect with the people around them.

**Positioning.** For adults who cannot rely on speech or written language, Selvo is a personalized communication companion that turns pictures, context, and a few taps into words that sound like them. Where traditional AAC helps someone say what they need, Selvo helps them say what they mean, the way they would say it.

**Promise and tagline.** Your voice. Your way.

**Name.** Selvo, from self and voice. Capital S in running copy, never SELVO, never "the Selvo app" when "Selvo" will do.

**What Selvo is.** A companion. A translator between intention and expression. A tool the person holds and controls.

**What Selvo is not.** A medical device. A voice given to the voiceless. A caregiver's remote control. A chatbot that guesses.

## Brand pillars

- **Identity.** Personality comes through. Humor, opinion, warmth, and edge are features, not noise.
- **Autonomy.** The person chooses every message that leaves the device. Suggestions are offered, never spoken on their behalf.
- **Dignity.** Built for adults. Nothing should feel borrowed from a classroom or a clinic.
- **Expression.** Needs, yes, and also jokes, stories, disagreements, and affection.
- **Connection.** Success is a better conversation, not a correct classification.
- **Accessibility.** Works across combinations of speech, literacy, cognitive, and motor ability, and keeps working when the network or the model does not.

## Personality

Welcoming, quietly futuristic, calm, confident. The glow is the one exciting thing on a page, and it is a voice: everything around it stays still so it can shine. If the brand were a person, they would be the friend who finishes your sentence only when you ask, gets the joke, and never talks about you in the third person while you are in the room.

Test every decision against the two failure modes this category falls into: **pediatric** (cartoon pictograms, primary colors, bouncy type, mascots, "parent" settings) and **clinical** (white plus hospital blue, pain-scale faces, therapy jargon, device chrome). Nightlight avoids both by borrowing from consumer tech instead: a night sky, one lit object, generous space. It also avoids the opposite trap, neon: one glow per screen, no gradients across controls, no pulsing.

## Voice and tone

Sincere and restrained. Plain words, short sentences, numerals not number words; pictures and real numbers do the work instead of adjectives.

- Address the communicator in the second person. They are the subject of the sentence: "Say it your way," not "Help your loved one communicate."
- Say "communicate," "say," "speak," "your words." Say "person," "communicator," or their name. Say "companion" for the product and "supporter" or "family" for people who help.
- Do not say "voiceless," "give a voice," "trapped," "suffers from," "patient," or "user" in customer-facing copy. "Non-verbal" is an adjective ("non-verbal adults"), never a noun.
- Do not describe AI as speaking for someone. Selvo "suggests," "offers," "learns how you like to say things." The person "chooses," "says," "sends."
- Product terms match the interface exactly: **Speak**, **Incorrect**, **Another**, **Show**.
- No hype register and no emotional headlines. Never "revolutionary," "unlock," "empower" as a verb, or exclamation marks. No em dashes or en dashes; use commas, colons, or a new sentence.
- Humor belongs to the person, not the brand. The brand is warm; the suggestions can be funny because Lucas is.

Real copy to reuse:

> Your voice. Your way.

> A modern communication app for non-verbal adults. Selvo learns how you like to say things, so conversations with the world around you flow more easily.

> Get early access

> Where traditional AAC helps someone say what they need, Selvo helps them say what they mean.

## Color

Nightlight is a navy ground, one teal voice, and a single reserved alarm. Every value is sampled from the hero or derived from it, and every text pair clears WCAG AA in both themes; most clear AAA, which is the right bar for an audience where about one in seven stroke survivors has reduced contrast perception and one in five an acquired red-green deficit. Teal on navy also sits off the red-green axis, so the core pairing survives every common color deficiency.

- Ground is `surface`. On marketing pages, wash the upper left corner with `indigo` as a soft radial glow, as in the hero; inside the app the ground is flat.
- Tiles, cards and the message strip are `surface-raised`. Wells are `surface-sunken`. Quiet edges are `hairline`; control edges are `border-strong`.
- Text is `ink`; secondary text is `ink-muted`. `teal` is for the voice: links, quiet actions, style tags, selected icons, and "vo".
- `primary` is the only fill for the main action. Speak is `primary` with `on-primary`: navy on the orb teal at night, white on deep teal by day. On the website, the hero's white pill with navy text is the call to action.
- `orb` and `orb-glow` belong to the mark. Do not use them for UI states.
- `success` is the brand teal and always carries a check and a word. `danger` is the only warm color in the system; it appears on Help, Delete and the attention screen and nowhere else, so that coral always means this.
- Selection is `surface-brand-tint` plus a 3px `focus` ring or a check. Tint alone is not a state.

### Nightlight and Daylight

Nightlight is the brand's home: the website, the app icon, marketing, and the app's first screen. Inside the app, ship both themes and let the person choose at setup with both shown side by side. Research favors dark text on a light ground for most long reading, and dark grounds for people with light sensitivity, so neither is forced. Daylight keeps the same structure: cool near-white ground, navy ink, a deeper teal for text and Speak, the orb unchanged.

## Typography

One family, Lexend, as set in the hero. It was designed around reading proficiency, with open letterforms and generous spacing, and its geometry matches the rounded sound bars.

- Headlines in `display` (semibold, tight tracking), the paragraph beneath in `lead`, as in the hero.
- Inside the app: the spoken message in `message` (30/40, regular), headings in `heading`, buttons and tile labels in `label`, running copy in `body` (17/26), attribution in `caption` (14/20). Nothing ships below 14px.
- Running text is regular weight. Semibold is reserved for `display`, `heading` and `label`. Nothing is bold, light or thin inside the app.
- Offer Atkinson Hyperlegible as a reading-font choice in settings for people with low vision. Lexend's readability evidence comes mostly from its creators; Atkinson was tested with low-vision readers.
- The wordmark is artwork. Never set "Selvo" in Lexend as a logo.

## Spacing, radius, elevation

- Tiles are `touch-tile` (96px) squares with `space-3` (12px) gutters; a supporter can loosen the grid, never tighten it below `touch-min`.
- Speak is `touch-primary` (64px) tall, full width, pinned to the bottom. Clear sits at least `space-12` (48px) from Speak and never beside it.
- Screen margins `space-4`; sections `space-6`.
- Buttons and chips are `radius-pill`, echoing the sound bars. Tiles and cards `radius-md`; sheets and the message strip `radius-lg`.
- Depth comes from surface steps and `hairline`. `shadow-sheet` appears only under the Speak bar and modal sheets. `glow-orb` belongs to the orb alone.

## Layout principles for the communication screens

These rules apply to every screen the communicator holds.

1. **Two taps from anywhere to a spoken message.** Pick a tile, pick a suggestion, Speak.
2. **Positions never move.** Tiles keep their place forever. Grow by paging or by unhiding masked tiles, never by reflowing.
3. **Same controls, same place.** Speak bottom center, Back top left, Clear far from Speak, on every screen.
4. **Fewer than six top-level destinations.** Photos, Places, People, Phrases, Listen.
5. **One decision per screen.** Suggestions arrive as a stack of three. Another replaces the stack; Incorrect removes one.
6. **A photo and a short label on every tile.** The person's own photos first, realistic imagery second, cartoon pictograms never by default.
7. **Back and Undo always visible; nothing times out.** No auto-dismissing toasts. Confirm destructive actions twice.
8. **Show mode is one tap away.** Flip the message to the listener in large type.
9. **Text size, contrast, theme and speech rate live inside Selvo,** set by the supporter at onboarding and changeable by the person.
10. **Degrade gracefully.** Saved phrases and tiles work offline. The screen never goes blank because a model is slow.

## Imagery

Photographs of real adults in their own lives, mid-conversation, holding a phone the way anyone does. On Nightlight pages, photos sit in `radius-lg` frames on `surface-raised`, never full-bleed behind text. Lucas, when the family agrees, is the brand's first face. No clinic rooms, no white coats, no mascots, no cartoon figures. The orb is the only illustration; there is no secondary illustration style.

## Iconography

Interface glyphs are SF Symbols at Regular weight with rounded line caps, to match the sound bars, scaled with text. Communication symbols in the current prototype are ARASAAC pictograms; they are the fallback behind personal photos, not the default. Every symbol carries a text label. No emoji as decoration.

## Motion

Calm and non-directional. Fades and a gentle scale on selection. The sound bars may rise and settle once while Selvo speaks, the only animated element; never loop them while idle. The orb's glow is still. Honor Reduce Motion by replacing every transition with a fade. Speak gives a single haptic tap and a brief Spoken state.

## States

- Default tile: `surface-raised`, `hairline` edge, `ink` label.
- Selected: `surface-brand-tint`, 3px `focus` ring, check in `primary`.
- Pressed: `primary-pressed` for primary; `surface-sunken` for tiles.
- Spoken: a check and the word Spoken in `success` for one second.
- Disabled: `surface-sunken` with the label in `ink-muted`; never a greyed photo.
- Alarm: full-screen `danger` with `on-primary` text and the person's chosen phrase, reached only from Help.

## Components in this system

Tile, Suggestion, Button and SpeakBar carry these rules as live previews in both themes. Build a screen from them and the layout principles before inventing a new component.
