import { defineCollection } from "astro:content";
import { glob } from "astro/loaders";
import { z } from "astro/zod";

// Articles are Markdown files in src/content/articles. The file name is the URL slug.
const articles = defineCollection({
  loader: glob({ pattern: "**/*.md", base: "./src/content/articles" }),
  schema: z.object({
    title: z.string(),
    description: z.string(),
    category: z.string(),
    author: z.string(),
    /** Shown as written. Keep "[DATE]" until Emily sets a publish date. */
    date: z.string(),
    readTime: z.string(),
    /** Text of the card photo placeholder on the articles index. */
    photo: z.string(),
    sources: z.array(z.object({ label: z.string(), url: z.url() })).default([]),
  }),
});

export const collections = { articles };
