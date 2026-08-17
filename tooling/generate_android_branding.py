#!/usr/bin/env python3
"""Generate Android launcher / splash brand resources from the 512 master."""

from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageChops, ImageFilter, ImageOps

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "branding" / "brain_clean_mark_512.png"
RES = ROOT / "android" / "app" / "src" / "main" / "res"
BG = (13, 17, 23, 255)  # #0D1117


def ensure_rgba(img: Image.Image) -> Image.Image:
    return img.convert("RGBA") if img.mode != "RGBA" else img.copy()


def fill_corners_with_bg(img: Image.Image) -> Image.Image:
    """Remove baked squircle transparency/edge by using full square BG color."""
    base = Image.new("RGBA", img.size, BG)
    base.alpha_composite(img)
    # Paint near-black rounded exterior as solid bg (already mostly solid).
    return base


def make_foreground(master: Image.Image, size: int, pad_ratio: float = 0.18) -> Image.Image:
    """Transparent canvas with mark scaled into adaptive safe zone."""
    flat = fill_corners_with_bg(master)
    # Extract non-bg content roughly via difference from BG.
    bg_img = Image.new("RGBA", flat.size, BG)
    diff = ImageChops.difference(flat, bg_img).convert("L")
    mask = diff.point(lambda p: 255 if p > 12 else 0)
    # Soften mask slightly.
    mask = mask.filter(ImageFilter.MaxFilter(3))
    rgba = Image.new("RGBA", flat.size, (0, 0, 0, 0))
    rgba.paste(flat, mask=mask)

    # Crop to content bbox with small margin.
    bbox = mask.getbbox()
    if bbox:
        rgba = rgba.crop(bbox)

    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    inner = int(size * (1.0 - 2 * pad_ratio))
    mark = ImageOps.contain(rgba, (inner, inner), Image.Resampling.LANCZOS)
    x = (size - mark.width) // 2
    y = (size - mark.height) // 2
    canvas.alpha_composite(mark, (x, y))
    return canvas


def make_legacy(master: Image.Image, size: int) -> Image.Image:
    flat = fill_corners_with_bg(master).convert("RGB")
    return flat.resize((size, size), Image.Resampling.LANCZOS)


def make_monochrome(master: Image.Image, size: int = 432) -> Image.Image:
    fg = make_foreground(master, size, pad_ratio=0.16)
    # Any visible teal/light pixel -> white for themed icons.
    px = fg.load()
    out = Image.new("RGBA", fg.size, (0, 0, 0, 0))
    opx = out.load()
    for y in range(fg.height):
        for x in range(fg.width):
            r, g, b, a = px[x, y]
            if a < 20:
                continue
            # Prefer brand teal / lighter glow pixels as silhouette.
            luma = 0.2126 * r + 0.7152 * g + 0.0722 * b
            if luma > 28 or g > 40:
                opx[x, y] = (255, 255, 255, a)
    return out


def make_splash_mark(master: Image.Image, size: int = 288) -> Image.Image:
    return make_foreground(master, size, pad_ratio=0.12)


def write_png(path: Path, img: Image.Image) -> None:
    path = path if path.is_absolute() else ROOT / path
    path.parent.mkdir(parents=True, exist_ok=True)
    img.save(path, format="PNG", optimize=True)
    print(f"wrote {path.relative_to(ROOT)} ({path.stat().st_size} bytes)")


def main() -> None:
    if not SRC.exists():
        raise SystemExit(f"missing source: {SRC}")
    master = ensure_rgba(Image.open(SRC))
    if master.size != (512, 512):
        master = master.resize((512, 512), Image.Resampling.LANCZOS)

    # Play / canonical copies.
    write_png(ROOT / "store" / "play_store_icon_512.png", fill_corners_with_bg(master).convert("RGB"))
    write_png(ROOT / "assets" / "branding" / "brain_clean_mark_512.png", fill_corners_with_bg(master).convert("RGB"))

    densities = {
        "mdpi": 48,
        "hdpi": 72,
        "xhdpi": 96,
        "xxhdpi": 144,
        "xxxhdpi": 192,
    }
    fg_densities = {
        "mdpi": 108,
        "hdpi": 162,
        "xhdpi": 216,
        "xxhdpi": 324,
        "xxxhdpi": 432,
    }

    for name, size in densities.items():
        write_png(RES / f"mipmap-{name}" / "ic_launcher.png", make_legacy(master, size))

    for name, size in fg_densities.items():
        write_png(
            RES / f"drawable-{name}" / "ic_launcher_foreground.png",
            make_foreground(master, size),
        )

    # Default drawable fallback used by adaptive XML.
    write_png(RES / "drawable" / "ic_launcher_foreground.png", make_foreground(master, 432))
    write_png(RES / "drawable" / "ic_launcher_monochrome.png", make_monochrome(master, 432))
    write_png(RES / "drawable" / "splash_logo.png", make_splash_mark(master, 288))

    print("done")


if __name__ == "__main__":
    main()
