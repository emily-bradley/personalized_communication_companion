import { describe, expect, it } from "vitest";
import { isValidEmail } from "../src/lib/email";
import { isCurrent, resolveSiteUrl } from "../src/lib/site";

describe("isCurrent", () => {
  it("matches the page and its children", () => {
    expect(isCurrent("/articles", "/articles/")).toBe(true);
    expect(isCurrent("/articles", "/articles/three-replies")).toBe(true);
    expect(isCurrent("/story", "/")).toBe(false);
    expect(isCurrent("/family", "/familyx")).toBe(false);
  });
});

describe("isValidEmail", () => {
  it("accepts a normal address and rejects junk", () => {
    expect(isValidEmail("you@example.com")).toBe(true);
    expect(isValidEmail(" you@example.com ")).toBe(true);
    expect(isValidEmail("you@example")).toBe(false);
    expect(isValidEmail("")).toBe(false);
    expect(isValidEmail("a b@c.d")).toBe(false);
  });
});

describe("resolveSiteUrl", () => {
  it("uses the build variable when it is an https origin", () => {
    expect(resolveSiteUrl("https://meetselvo.com")).toBe("https://meetselvo.com");
    expect(resolveSiteUrl(" https://meetselvo.com/ ")).toBe("https://meetselvo.com");
  });

  it("falls back to the pages.dev address otherwise", () => {
    expect(resolveSiteUrl(undefined)).toBe("https://selvo-website.pages.dev");
    expect(resolveSiteUrl("")).toBe("https://selvo-website.pages.dev");
    expect(resolveSiteUrl("meetselvo.com")).toBe("https://selvo-website.pages.dev");
    expect(resolveSiteUrl("https://meetselvo.com/about")).toBe("https://selvo-website.pages.dev");
  });
});
