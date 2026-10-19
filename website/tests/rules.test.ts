import { readdirSync, readFileSync, statSync } from "node:fs";
import { join } from "node:path";
import { describe, expect, it } from "vitest";

function files(dir: string, ext: RegExp): string[] {
  return readdirSync(dir).flatMap((name) => {
    const path = join(dir, name);
    return statSync(path).isDirectory() ? files(path, ext) : ext.test(name) ? [path] : [];
  });
}

const sources = files("src", /\.(astro|ts|md|css)$/).filter((f) => !f.endsWith("tokens.css"));
const views = sources.filter((f) => f.endsWith(".astro") || f.endsWith(".md"));

describe("brand rules", () => {
  it.each(sources)("%s has no em or en dashes", (file) => {
    expect(readFileSync(file, "utf8")).not.toMatch(/[\u2013\u2014]/);
  });

  it.each(views)("%s has no hex color literals", (file) => {
    expect(readFileSync(file, "utf8")).not.toMatch(/#[0-9a-fA-F]{3,8}\b/);
  });

  it.each(views)("%s avoids banned words and exclamation marks in copy", (file) => {
    const text = readFileSync(file, "utf8")
      .replace(/^---[\s\S]*?---/, (front) => front.replace(/[^"`]*/g, " "))
      .replace(/<script[\s\S]*?<\/script>/g, "")
      .replace(/<!--[\s\S]*?-->/g, "");
    const copy = text.replace(/<[^>]+>/g, " ");
    expect(copy).not.toMatch(/\b(user|users|voiceless|patient|patients)\b/i);
    expect(copy).not.toMatch(/give a voice/i);
    expect(copy).not.toMatch(/[A-Za-z.)]!(?!=)/);
  });
});
