import { describe, expect, it } from "vitest";
import tokens from "../src/design/tokens.json";
import { contrastRatio } from "../src/lib/contrast";

const color = tokens.color as Record<string, string>;

describe("token contrast", () => {
  it.each(tokens.contrastPairs)("text %s on %s meets WCAG AA (4.5:1)", (fg, bg) => {
    expect(color[fg], fg).toBeDefined();
    expect(color[bg], bg).toBeDefined();
    expect(contrastRatio(color[fg] as string, color[bg] as string)).toBeGreaterThanOrEqual(4.5);
  });

  it.each(tokens.nonTextPairs)("control edge %s on %s meets 3:1", (fg, bg) => {
    expect(contrastRatio(color[fg] as string, color[bg] as string)).toBeGreaterThanOrEqual(3);
  });
});

describe("contrastRatio", () => {
  it("is 21 for black on white", () => {
    expect(contrastRatio("#000000", "#ffffff")).toBeCloseTo(21, 5);
  });
});
