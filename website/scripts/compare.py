"""Side-by-side comparison strips: reference (left) and site (right), cut into chunks.

Usage: python3 scripts/compare.py ref.png site.png out_prefix [chunk_height]
"""

import sys

from PIL import Image

ref, site, prefix = Image.open(sys.argv[1]), Image.open(sys.argv[2]), sys.argv[3]
chunk = int(sys.argv[4]) if len(sys.argv) > 4 else 1200
h = max(ref.height, site.height)
gap = 16
for i, top in enumerate(range(0, h, chunk)):
    out = Image.new("RGB", (ref.width + site.width + gap, chunk), (255, 0, 255))
    out.paste(ref.crop((0, top, ref.width, min(top + chunk, ref.height))), (0, 0)) if top < ref.height else None
    out.paste(site.crop((0, top, site.width, min(top + chunk, site.height))), (ref.width + gap, 0)) if top < site.height else None
    scale = min(1.0, 1800 / out.width)
    out = out.resize((int(out.width * scale), int(out.height * scale)))
    out.save(f"{prefix}-{i}.png")
    print(f"{prefix}-{i}.png")
