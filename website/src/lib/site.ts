const DEFAULT_SITE_URL = "https://selvo-website.pages.dev";

/**
 * The public address. Set the SITE_URL build variable in Cloudflare to https://meetselvo.com
 * once that domain is connected; until then links point at the pages.dev address.
 */
export function resolveSiteUrl(value: string | undefined): string {
  const url = value?.trim().replace(/\/+$/, "");
  return url && /^https:\/\/[^/\s]+$/.test(url) ? url : DEFAULT_SITE_URL;
}

export const SITE_URL = resolveSiteUrl(globalThis.process?.env.SITE_URL);

export const SITE_NAME = "Selvo";

export const NAV_LINKS = [
  { href: "/how-it-works", label: "How it works" },
  { href: "/story", label: "Our story" },
  { href: "/family", label: "For family" },
  { href: "/articles", label: "Articles" },
] as const;

export const FOOTER_LINKS = [
  ...NAV_LINKS,
  { href: "/privacy", label: "Privacy" },
  { href: "/accessibility", label: "Accessibility" },
] as const;

/** True when the nav link should be marked as the current page. */
export function isCurrent(href: string, pathname: string): boolean {
  const path = pathname.replace(/\/+$/, "") || "/";
  return path === href || path.startsWith(`${href}/`);
}
