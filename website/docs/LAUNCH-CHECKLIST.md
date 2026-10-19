# Launch checklist

Everything here needs Emily before a public launch. The demo can go out with these visible as placeholders.

## Placeholders on the site
- Home, "It started with Lucas": `[PHOTO: Lucas, mid-conversation, holding a phone the way anyone does]`
- Our story, hero: `[PHOTO: Lucas and Emily at the kitchen table. He is mid-laugh. A phone face-up between the plates. Daylight from a window. Nobody looks at the camera.]`
- For family, FAQ "Does it need an internet connection?": `[CONFIRM: which features need a connection.]`
- For family, FAQ "Who can see what they say?": `[CONFIRM: privacy summary, one or two sentences, with a link to the privacy page.]`
- For family, FAQ "What does it cost?": `[YOUR PRICE, or: free during early access.]`

More are added as each page is built (Story photo, article card photos, article `[DATE]` and read time, family FAQ `[CONFIRM: ...]` and `[YOUR PRICE]`).

## Settings
- `PUBLIC_WAITLIST_URL`: the form backend that receives early-access emails (Buttondown, ConvertKit, or a Cloudflare Worker). Until it is set, sign-ups show "Saved" but are not stored.
- Custom domain (`selvo.com` if available), then update `SITE_URL` in `src/lib/site.ts`.
- Privacy and Accessibility pages: real statements.
