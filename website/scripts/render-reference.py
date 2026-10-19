"""Convert a .dc.html design reference to plain HTML so Playwright can screenshot it.

Usage: python3 scripts/render-reference.py docs/design/website/Orb-Site-Home.dc.html out.html
Unwraps <x-dc>, moves <helmet> into <head>, keeps the first branch of each <sc-if>,
expands <sc-for> once, and removes the canvas runtime scripts.
"""

import re
import sys

src, out = sys.argv[1], sys.argv[2]
html = open(src, encoding="utf-8").read()

helmet = re.search(r"<helmet>(.*?)</helmet>", html, re.S)
head_extra = helmet.group(1) if helmet else ""
html = re.sub(r"<helmet>.*?</helmet>", "", html, flags=re.S)
html = re.sub(r'<script[^>]*support\.js[^>]*></script>', "", html)
html = re.sub(r"<script[^>]*data-dc-script[^>]*>.*?</script>", "", html, flags=re.S)
html = html.replace("<x-dc>", "").replace("</x-dc>", "")


def first_branch(text: str) -> str:
    # Keep the first <sc-if> of each adjacent run and drop the rest.
    pattern = re.compile(r"(<sc-if\b[^>]*>(.*?)</sc-if>)((\s*<sc-if\b[^>]*>.*?</sc-if>)*)", re.S)
    return pattern.sub(lambda m: m.group(2), text)


html = first_branch(html)
html = re.sub(r"<sc-for\b[^>]*>(.*?)</sc-for>", r"\1", html, flags=re.S)
html = re.sub(r"\{\{[^}]*\}\}", "", html)
html = html.replace("</head>", head_extra + "</head>", 1)
open(out, "w", encoding="utf-8").write(html)
