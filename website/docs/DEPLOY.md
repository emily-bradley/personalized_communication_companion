# Deploying the Selvo website

The site is static (Astro). Cloudflare Pages builds it from GitHub on every push. You connect it once; after that, nothing else is needed.

## One-time setup (about 10 minutes)

1. Sign in at https://dash.cloudflare.com (a free account is fine).
2. In the left sidebar, open **Workers and Pages**.
3. Click **Create**, then choose the **Pages** tab, then **Connect to Git**.
4. Connect your GitHub account if asked, and allow Cloudflare to see the repository.
5. Pick the repository:
   - If `emily-bradley/selvo-website` exists, pick it.
   - Until then, pick `emily-bradley/personalized_communication_companion`.
6. Project name: `selvo-website` (this gives you `https://selvo-website.pages.dev`).
7. Production branch:
   - `main` for `selvo-website`.
   - `website-staging` for `personalized_communication_companion`.
8. Build settings:
   - Framework preset: **Astro**
   - Build command: `pnpm build`
   - Build output directory: `dist`
   - Root directory (advanced): leave empty for `selvo-website`; set to `website` for `personalized_communication_companion`.
9. Environment variables (optional): none are required. Later, add `PUBLIC_WAITLIST_URL` to send early access sign-ups to your form backend. Cloudflare reads the Node version from `.node-version`. If the first build fails at the install step, add the variable `PNPM_VERSION` with value `10.28.0` and retry the deploy.
10. Click **Save and Deploy**. The first build takes two or three minutes. Your link is `https://selvo-website.pages.dev`.

Every push to the production branch now deploys automatically, and every other branch gets its own preview link.

## Custom domain

You would like `selvo.com` if you can get it.

1. In the Pages project, open **Custom domains**, then **Set up a custom domain**.
2. Type the domain and follow the prompts.
   - If the domain's DNS is already on Cloudflare, it connects in one step.
   - If it is registered elsewhere, Cloudflare shows the one CNAME record to add at your registrar.
3. Tell the build agent the new domain (a line in PROGRESS.md under Needs Emily is enough). It changes `SITE_URL` in `src/lib/site.ts`, which updates canonical links, the sitemap, robots, and link previews.

## If you used a different project name

The address will be `https://<your-project-name>.pages.dev`. Write it in PROGRESS.md so the agent can update `SITE_URL` and verify the live site after each push.
