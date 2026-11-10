#!/usr/bin/env python3
"""
Evermeet D&D 5e Character Card HTML Compiler (scripts/compile_card_html.py)

Compiles any Typst character card (.typ) into a self-contained, zero-frame
standalone HTML file (cards/xxx.html).

In `cards/xxx.html`, ONLY the character card itself is displayed:
- No surrounding website frame, header, footer, or navigation bar
- No mockup / device frames, tab switchers, or outer card wrappers
- Zero margin/padding framing for seamless iframe embedding & clean reading
- High-fidelity vector SVG rendering embedded directly as self-contained data URIs
- Print-ready CSS (@media print) with automatic page-break preservation
"""

import sys
import os
import re
import glob
import base64
import tempfile
import subprocess
from pathlib import Path

ROOT_DIR = Path(__file__).resolve().parent.parent
CARDS_DIR = ROOT_DIR / "cards"
DIST_CARDS_DIR = ROOT_DIR / "dist" / "cards"


def extract_character_name(typ_path: Path) -> str:
    """Extract character name from .typ source if available, else derive from filename."""
    try:
        content = typ_path.read_text(encoding="utf-8")
        match = re.search(r'name:\s*"([^"]+)"', content)
        if match:
            return match.group(1)
    except Exception:
        pass
    return typ_path.stem.replace("_", " ").title()


def compile_typst_to_svgs(typ_path: Path, temp_dir: Path) -> list[Path]:
    """Compile a .typ file to SVG page files in temp_dir."""
    output_pattern = str(temp_dir / "page_{p}.svg")
    cmd = [
        "typst",
        "compile",
        "--root",
        str(ROOT_DIR),
        str(typ_path),
        output_pattern,
    ]
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        sys.stderr.write(f"Typst compilation failed for {typ_path}:\n{result.stderr}\n")
        raise RuntimeError(f"Typst error: {result.stderr}")

    svg_files = sorted(
        temp_dir.glob("page_*.svg"),
        key=lambda p: int(p.stem.split("_")[1]) if p.stem.split("_")[1].isdigit() else 0,
    )
    if not svg_files:
        all_svgs = sorted(temp_dir.glob("*.svg"))
        return all_svgs
    return svg_files


def generate_frameless_card_html(char_name: str, svg_paths: list[Path]) -> str:
    """Generate self-contained HTML showing only the card without any outer frame."""
    pages_html = []
    for idx, svg_path in enumerate(svg_paths, start=1):
        svg_bytes = svg_path.read_bytes()
        b64_svg = base64.b64encode(svg_bytes).decode("utf-8")
        pages_html.append(
            f'    <div class="card-page-wrapper">\n'
            f'      <img class="card-page" src="data:image/svg+xml;base64,{b64_svg}" alt="{char_name} — Page {idx}" />\n'
            f'    </div>'
        )

    pages_body = "\n".join(pages_html)

    return f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>{char_name} — D&amp;D 5e Character Card</title>
  <style>
    /* Clean Frameless Character Card Presentation */
    *, *::before, *::after {{
      box-sizing: border-box;
      margin: 0;
      padding: 0;
    }}
    html, body {{
      margin: 0;
      padding: 0;
      background: #ffffff;
      color: #121212;
      width: 100%;
      min-height: 100%;
      -webkit-font-smoothing: antialiased;
    }}
    .card-root {{
      display: flex;
      flex-direction: column;
      align-items: center;
      width: 100%;
      margin: 0;
      padding: 0;
      gap: 0;
    }}
    .card-page-wrapper {{
      display: block;
      width: 100%;
      max-width: 210mm; /* Standard A4 sheet aspect ratio */
      margin: 0 auto;
      padding: 0;
      line-height: 0;
    }}
    .card-page {{
      display: block;
      width: 100%;
      height: auto;
      margin: 0;
      padding: 0;
      border: none;
      outline: none;
      box-shadow: none;
    }}
    /* Print rules for high-fidelity physical printing */
    @media print {{
      @page {{
        size: A4;
        margin: 0;
      }}
      html, body, .card-root {{
        background: transparent;
        margin: 0;
        padding: 0;
      }}
      .card-page-wrapper {{
        max-width: none;
        width: 100vw;
        height: 100vh;
        page-break-after: always;
        break-after: page;
      }}
      .card-page-wrapper:last-child {{
        page-break-after: avoid;
        break-after: avoid;
      }}
    }}
  </style>
</head>
<body>
  <main class="card-root">
{pages_body}
  </main>
</body>
</html>
"""


def compile_card(typ_file: Path, output_file: Path | None = None) -> Path:
    """Compile a single .typ card to a frameless HTML file."""
    typ_path = typ_file.resolve()
    if not typ_path.is_file():
        raise FileNotFoundError(f"Source file not found: {typ_path}")

    char_name = extract_character_name(typ_path)

    if output_file is None:
        CARDS_DIR.mkdir(parents=True, exist_ok=True)
        target_name = typ_path.stem
        output_path = CARDS_DIR / f"{target_name}.html"
    else:
        output_path = output_file.resolve()
        output_path.parent.mkdir(parents=True, exist_ok=True)

    with tempfile.TemporaryDirectory() as temp_dir_str:
        temp_dir = Path(temp_dir_str)
        svg_files = compile_typst_to_svgs(typ_path, temp_dir)
        html_content = generate_frameless_card_html(char_name, svg_files)
        output_path.write_text(html_content, encoding="utf-8")

    print(f"✓ Compiled {typ_path.relative_to(ROOT_DIR)} -> {output_path.relative_to(ROOT_DIR)} ({len(svg_files)} pages)")
    return output_path


def compile_all_known_characters():
    """Compile all showcase and example characters to cards/*.html and dist/cards/*.html."""
    CARDS_DIR.mkdir(parents=True, exist_ok=True)
    DIST_CARDS_DIR.mkdir(parents=True, exist_ok=True)

    candidates = [
        ROOT_DIR / "character.typ",
        ROOT_DIR / "examples" / "kaelen_rogue.typ",
        ROOT_DIR / "examples" / "thokk_barbarian.typ",
    ]

    # Also discover any custom .typ files in cards/*.typ or examples/*.typ
    for custom_typ in sorted(ROOT_DIR.glob("cards/*.typ")) + sorted(ROOT_DIR.glob("examples/*.typ")):
        if custom_typ not in candidates:
            candidates.append(custom_typ)

    for cand in candidates:
        if cand.is_file():
            out_cards = CARDS_DIR / f"{cand.stem}.html"
            compile_card(cand, out_cards)

            out_dist = DIST_CARDS_DIR / f"{cand.stem}.html"
            out_dist.write_text(out_cards.read_text(encoding="utf-8"), encoding="utf-8")

    # If character.typ was compiled, provide seraphina aliases
    char_html = CARDS_DIR / "character.html"
    if char_html.is_file():
        for alias in ("seraphina.html", "seraphina_paladin_warlock.html"):
            (CARDS_DIR / alias).write_text(char_html.read_text(encoding="utf-8"), encoding="utf-8")
            (DIST_CARDS_DIR / alias).write_text(char_html.read_text(encoding="utf-8"), encoding="utf-8")
        print("✓ Created Seraphina aliases in cards/ and dist/cards/")


def main():
    if len(sys.argv) == 1:
        print("Compiling all character cards to HTML (frameless)...")
        compile_all_known_characters()
    elif len(sys.argv) == 2:
        in_path = Path(sys.argv[1])
        compile_card(in_path)
    elif len(sys.argv) == 3:
        in_path = Path(sys.argv[1])
        out_path = Path(sys.argv[2])
        compile_card(in_path, out_path)
    else:
        print("Usage: compile_card_html.py [character.typ] [cards/output.html]")
        sys.exit(1)


if __name__ == "__main__":
    main()
