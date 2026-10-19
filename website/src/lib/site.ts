// The one place the public address lives. Switch to the custom domain once Emily adds one.
export const SITE_URL = "https://selvo-website.pages.dev";

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
