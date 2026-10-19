export const ROUTES = [
  { path: "/", name: "home" },
  { path: "/how-it-works", name: "how-it-works" },
  { path: "/story", name: "story" },
  { path: "/family", name: "family" },
  { path: "/articles", name: "articles" },
  { path: "/privacy", name: "privacy" },
  { path: "/accessibility", name: "accessibility" },
  { path: "/does-not-exist", name: "404" },
] as const;

export const WIDTHS = [1440, 768, 375] as const;
