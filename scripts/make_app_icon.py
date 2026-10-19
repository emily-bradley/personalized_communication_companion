#!/usr/bin/env python3
"""Draw the app icon: the orb with three white sound bars on the Nightlight ground.

1024x1024, opaque, written to the asset catalog. Colors come from tokens.json.
"""
import json
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parent.parent
tokens = {t["name"]: t["value"] for t in json.loads((ROOT / "docs/design/system/tokens.json").read_text())["color"]["tokens"]}


def rgb(name):
    v = tokens[name]
    h = (v["night"] if isinstance(v, dict) else v).lstrip("#")
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))


S = 1024
SS = 4  # supersample for smooth edges
size = S * SS
img = Image.new("RGB", (size, size), rgb("surface"))

# Soft halo behind the orb (glow-orb).
halo = Image.new("L", (size, size), 0)
d = ImageDraw.Draw(halo)
c = size // 2
r_halo = int(size * 0.40)
d.ellipse([c - r_halo, c - r_halo, c + r_halo, c + r_halo], fill=90)
halo = halo.filter(ImageFilter.GaussianBlur(size * 0.06))
img.paste(Image.new("RGB", (size, size), rgb("orb")), (0, 0), halo)

# The orb.
r = int(size * 0.33)
orb_mask = Image.new("L", (size, size), 0)
ImageDraw.Draw(orb_mask).ellipse([c - r, c - r, c + r, c + r], fill=255)
img.paste(Image.new("RGB", (size, size), rgb("orb")), (0, 0), orb_mask)

# Highlight at the upper left (orb-glow), clipped to the orb.
hl = Image.new("L", (size, size), 0)
hx, hy, hr = c - int(r * 0.35), c - int(r * 0.45), int(r * 0.75)
ImageDraw.Draw(hl).ellipse([hx - hr, hy - hr, hx + hr, hy + hr], fill=150)
hl = hl.filter(ImageFilter.GaussianBlur(r * 0.35))
hl = Image.composite(hl, Image.new("L", (size, size), 0), orb_mask)
img.paste(Image.new("RGB", (size, size), rgb("orb-glow")), (0, 0), hl)

# Three sound bars (viewBox 54x104), white, centered.
bar_h_total = r * 1.05
scale = bar_h_total / 104
w_total = 54 * scale
ox, oy = c - w_total / 2, c - bar_h_total / 2
d = ImageDraw.Draw(img)
for x, y, h in [(4, 30, 44), (22, 6, 92), (40, 38, 28)]:
    x0, y0 = ox + x * scale, oy + y * scale
    d.rounded_rectangle([x0, y0, x0 + 10 * scale, y0 + h * scale], radius=5 * scale, fill=(255, 255, 255))

img = img.resize((S, S), Image.LANCZOS)
out = ROOT / "Selvo/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon.png"
img.save(out)
print("Wrote", out.relative_to(ROOT))
