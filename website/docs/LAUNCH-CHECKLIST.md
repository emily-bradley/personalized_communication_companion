# Launch checklist

Everything here needs Emily before a public launch. The demo can go out with these visible as placeholders.

## Placeholders on the site
- Home, "It started with Lucas": `[PHOTO: Lucas, mid-conversation, holding a phone the way anyone does]`
- Our story, hero: `[PHOTO: Lucas and Emily at the kitchen table. He is mid-laugh. A phone face-up between the plates. Daylight from a window. Nobody looks at the camera.]`
- For family, FAQ "Does it need an internet connection?": `[CONFIRM: which features need a connection.]`
- For family, FAQ "Who can see what they say?": `[CONFIRM: privacy summary, one or two sentences, with a link to the privacy page.]`
- For family, FAQ "What does it cost?": `[YOUR PRICE, or: free during early access.]`
- Articles index, card photos: `[PHOTO: a hand holding a phone, three replies on screen]`, `[PHOTO: two adults talking at a cafe table]`, `[PHOTO: a phone face-down on a kitchen counter]`
- Articles index: the featured guide ("Setting up Selvo with someone you support") and the cards "What AAC is, and where Selvo fits" and "Your words stay yours" have no article yet, so they show without links. Write them, then link them.
- Article "Why Selvo offers three replies, not forty": `[DATE]` in the byline, and the read time "4 min read" (from the artboard; confirm it). Both are in `src/content/articles/three-replies.md`.
- How it works, step 1 tiles: `[PHOTO]` in the Coffee, Mom, and Work tiles

## Settings
- `PUBLIC_WAITLIST_URL`: the form backend that receives early-access emails (Buttondown, ConvertKit, or a Cloudflare Worker). Until it is set, sign-ups show "Saved" but are not stored.
- Custom domain (`selvo.com` if available), then update `SITE_URL` in `src/lib/site.ts`.
- Privacy and Accessibility pages: real statements.
- Link preview: once live, paste the link into a message to yourself and check the title, description, and image (`public/og.png`).

## Technical, before a public launch
- Add a Content Security Policy to `public/_headers` once the form backend is chosen.
- Update the Selvo design system tokens with the warm set (see `docs/DECISIONS.md`).
