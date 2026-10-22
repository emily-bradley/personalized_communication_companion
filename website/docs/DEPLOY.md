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

## Custom domain: meetselvo.com

You bought `meetselvo.com` on Oct 20. (Selvo does not own `selvo.com`; the site never links to it.)

1. In the Pages project, open **Custom domains**, then **Set up a custom domain**.
2. Type `meetselvo.com` and follow the prompts. Repeat for `www.meetselvo.com` if you want both.
   - If the domain's DNS is already on Cloudflare, it connects in one step.
   - If it is registered elsewhere, Cloudflare shows the one record to add at your registrar, or offers to move the DNS to Cloudflare.
3. Once `https://meetselvo.com` opens the site, go to **Settings**, **Variables and Secrets**, add the variable `SITE_URL` with value `https://meetselvo.com` for Production, then **Deployments**, **Retry deployment** on the latest one. Canonical links, the sitemap, robots, and link previews then use the domain. No code change is needed.

Until step 3 is done, links and previews use `https://selvo-website.pages.dev`, which always works. Do step 3 only after the domain opens the site, or link previews will show no picture.

## If you used a different project name

The address will be `https://<your-project-name>.pages.dev`. Write it in PROGRESS.md so the agent can update `SITE_URL` and verify the live site after each push.
