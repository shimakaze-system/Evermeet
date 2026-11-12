#!/usr/bin/env bash
# ============================================================================
# Evermeet D&D 5e Preview Site Builder (`scripts/build_preview.sh`)
# ============================================================================
# Compiles the showcase character (`character.typ`) and all sample/custom
# character cards (`examples/*.typ`, `cards/*.typ`) into PDFs and high-DPI PNG
# page previews, then generates:
#   - `dist/index.html`              (interactive gallery & card directory)
#   - `dist/<card_name>.html`        (standalone page per character card)
#   - `dist/cards/<card_name>.html`  (standalone page under /cards/ route)
#   - `dist/cards/index.html`        (cards directory index)
#
# Usage:
#   ./scripts/build_preview.sh                # Build static site into dist/
#   ./scripts/build_preview.sh --serve [PORT] # Build and start local server
# ============================================================================

set -euo pipefail

export PATH="${HOME}/.local/bin:${PATH}"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_DIR="${ROOT_DIR}/dist"

mkdir -p "${DIST_DIR}/pdf" "${DIST_DIR}/img" "${DIST_DIR}/cards"

echo "==> Compiling Seraphina Vale (Paladin 6 / Warlock 2) [character.typ]..."
typst compile --root "${ROOT_DIR}" "${ROOT_DIR}/character.typ" "${DIST_DIR}/pdf/seraphina_paladin_warlock.pdf"
typst compile --root "${ROOT_DIR}" --ppi 180 "${ROOT_DIR}/character.typ" "${DIST_DIR}/img/seraphina_page_{p}.png"

echo "==> Compiling Kaelen Vane (Arcane Trickster Rogue 7) [examples/kaelen_rogue.typ]..."
typst compile --root "${ROOT_DIR}" "${ROOT_DIR}/examples/kaelen_rogue.typ" "${DIST_DIR}/pdf/kaelen_rogue.pdf"
typst compile --root "${ROOT_DIR}" --ppi 180 "${ROOT_DIR}/examples/kaelen_rogue.typ" "${DIST_DIR}/img/kaelen_page_{p}.png"

echo "==> Compiling Thokk Grimjaw (Totem Warrior Barbarian 5) [examples/thokk_barbarian.typ]..."
typst compile --root "${ROOT_DIR}" "${ROOT_DIR}/examples/thokk_barbarian.typ" "${DIST_DIR}/pdf/thokk_barbarian.pdf"
typst compile --root "${ROOT_DIR}" --ppi 180 "${ROOT_DIR}/examples/thokk_barbarian.typ" "${DIST_DIR}/img/thokk_page_{p}.png"

# Also keep root character.pdf up to date
cp "${DIST_DIR}/pdf/seraphina_paladin_warlock.pdf" "${ROOT_DIR}/character.pdf"

# Shared CSS stylesheet block used across index.html and standalone card pages
read -r -d '' SHARED_STYLES << 'EOF' || true
    :root {
      --bg: #0f1115;
      --surface: #181b22;
      --surface-alt: #222631;
      --border: #2e3444;
      --text: #f3f4f6;
      --muted: #9ca3af;
      --accent: #e5e7eb;
      --badge-bg: #272c3a;
      --link-accent: #93c5fd;
    }
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Inter, sans-serif;
      background: var(--bg);
      color: var(--text);
      line-height: 1.5;
      padding-bottom: 4rem;
    }
    header {
      border-bottom: 1px solid var(--border);
      background: var(--surface);
      padding: 1.5rem 2rem;
    }
    .container {
      max-width: 1360px;
      margin: 0 auto;
    }
    .header-top {
      display: flex;
      flex-wrap: wrap;
      justify-content: space-between;
      align-items: center;
      gap: 1rem;
    }
    h1 {
      font-size: 1.5rem;
      font-weight: 700;
      letter-spacing: -0.02em;
    }
    h1 a {
      color: inherit;
      text-decoration: none;
    }
    .subtitle {
      color: var(--muted);
      font-size: 0.92rem;
      margin-top: 0.25rem;
    }
    .controls {
      display: flex;
      flex-wrap: wrap;
      gap: 0.65rem;
      margin-top: 1.25rem;
      align-items: center;
      justify-content: space-between;
    }
    .tabs, .nav-links {
      display: flex;
      flex-wrap: wrap;
      gap: 0.5rem;
      align-items: center;
    }
    .nav-label {
      color: var(--muted);
      font-size: 0.78rem;
      font-weight: 600;
      text-transform: uppercase;
      letter-spacing: 0.05em;
      margin-right: 0.25rem;
    }
    .tab-btn, .nav-pill {
      background: var(--surface-alt);
      color: var(--muted);
      border: 1px solid var(--border);
      padding: 0.52rem 0.95rem;
      border-radius: 6px;
      font-size: 0.86rem;
      font-weight: 600;
      cursor: pointer;
      text-decoration: none;
      display: inline-flex;
      align-items: center;
      gap: 0.4rem;
      transition: all 0.15s ease;
    }
    .tab-btn:hover, .nav-pill:hover {
      color: var(--text);
      border-color: #4b5563;
    }
    .tab-btn.active, .nav-pill.active {
      background: var(--text);
      color: var(--bg);
      border-color: var(--text);
    }
    .action-group {
      display: flex;
      flex-wrap: wrap;
      gap: 0.55rem;
      align-items: center;
    }
    .btn-download, .btn-card-link {
      display: inline-flex;
      align-items: center;
      gap: 0.45rem;
      background: var(--surface-alt);
      color: var(--text);
      text-decoration: none;
      padding: 0.55rem 1rem;
      border-radius: 6px;
      border: 1px solid var(--border);
      font-size: 0.85rem;
      font-weight: 600;
      transition: background 0.15s ease, border-color 0.15s ease;
    }
    .btn-download:hover, .btn-card-link:hover {
      background: #2d3343;
      border-color: #4b5563;
    }
    main {
      padding: 2rem;
    }
    .char-panel {
      display: none;
    }
    .char-panel.active {
      display: block;
    }
    .char-meta {
      background: var(--surface);
      border: 1px solid var(--border);
      border-radius: 8px;
      padding: 1.1rem 1.35rem;
      margin-bottom: 1.5rem;
      display: flex;
      flex-wrap: wrap;
      justify-content: space-between;
      align-items: center;
      gap: 1rem;
    }
    .char-meta h2 {
      font-size: 1.15rem;
      margin-bottom: 0.2rem;
    }
    .char-meta p {
      color: var(--muted);
      font-size: 0.86rem;
      max-width: 900px;
    }
    .badges {
      display: flex;
      flex-wrap: wrap;
      gap: 0.45rem;
      margin-top: 0.55rem;
    }
    .badge {
      background: var(--badge-bg);
      border: 1px solid var(--border);
      color: var(--accent);
      font-family: ui-monospace, SFMono-Regular, Menlo, monospace;
      font-size: 0.75rem;
      padding: 0.2rem 0.55rem;
      border-radius: 4px;
      text-decoration: none;
    }
    a.badge:hover {
      border-color: var(--link-accent);
      color: var(--link-accent);
    }
    .pages-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(380px, 1fr));
      gap: 1.5rem;
      align-items: start;
    }
    .page-card {
      background: var(--surface);
      border: 1px solid var(--border);
      border-radius: 8px;
      overflow: hidden;
      box-shadow: 0 10px 25px rgba(0, 0, 0, 0.35);
    }
    .page-card-header {
      padding: 0.65rem 1rem;
      border-bottom: 1px solid var(--border);
      display: flex;
      justify-content: space-between;
      align-items: center;
      font-size: 0.8rem;
      font-weight: 600;
      color: var(--muted);
      font-family: ui-monospace, SFMono-Regular, Menlo, monospace;
    }
    .page-card img {
      display: block;
      width: 100%;
      height: auto;
      background: #ffffff;
      cursor: zoom-in;
    }
    .lightbox {
      position: fixed;
      inset: 0;
      background: rgba(0, 0, 0, 0.88);
      display: none;
      align-items: center;
      justify-content: center;
      padding: 1.5rem;
      z-index: 1000;
      cursor: zoom-out;
    }
    .lightbox.open {
      display: flex;
    }
    .lightbox img {
      max-width: 95vw;
      max-height: 94vh;
      border-radius: 4px;
      box-shadow: 0 20px 50px rgba(0, 0, 0, 0.7);
      background: #fff;
    }
EOF

# Helper: build the <div class="pages-grid">...</div> HTML for a given image prefix
render_pages_grid() {
  local asset_prefix="$1"
  local img_prefix="$2"
  local char_label="$3"

  local page_labels=(
    ""
    "PAGE 01 // CORE &amp; COMBAT"
    "PAGE 02 // FEATURES &amp; INVENTORY"
    "PAGE 03 // SPELLCASTING GRIMOIRE"
    "PAGE 04 // SUPPLEMENT"
  )

  echo '      <div class="pages-grid">'
  local page_idx=1
  while [[ -f "${DIST_DIR}/img/${img_prefix}${page_idx}.png" ]]; do
    local header_label="${page_labels[$page_idx]:-PAGE 0${page_idx}}"
    cat << PAGE_EOF
        <div class="page-card">
          <div class="page-card-header"><span>${header_label}</span><span>Click to Zoom</span></div>
          <img src="${asset_prefix}img/${img_prefix}${page_idx}.png" alt="${char_label} Page ${page_idx}" onclick="openLightbox(this.src)" />
        </div>
PAGE_EOF
    page_idx=$((page_idx + 1))
  done
  echo '      </div>'
}

# Helper: generate a standalone HTML page for a single character card
generate_card_page() {
  local out_file="$1"
  local asset_prefix="$2"
  local active_slug="$3"
  local heading="$4"
  local description="$5"
  local badges_html="$6"
  local pdf_file="$7"
  local img_prefix="$8"
  local page_count="$9"
  local short_name="${10}"

  local grid_html
  grid_html="$(render_pages_grid "${asset_prefix}" "${img_prefix}" "${short_name}")"

  local sel_seraphina=""
  local sel_kaelen=""
  local sel_thokk=""
  case "${active_slug}" in
    seraphina) sel_seraphina=" active" ;;
    kaelen_rogue) sel_kaelen=" active" ;;
    thokk_barbarian) sel_thokk=" active" ;;
  esac

  cat > "${out_file}" << CARD_EOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>${short_name} — Evermeet D&amp;D 5e Character Card</title>
  <style>
${SHARED_STYLES}
  </style>
</head>
<body>
  <header>
    <div class="container">
      <div class="header-top">
        <div>
          <h1><a href="${asset_prefix}index.html">Evermeet — Automated D&amp;D 5e Character Sheet Preview</a></h1>
          <p class="subtitle">Character Card Preview • Built with Typst Automated 5e Rules Engine</p>
        </div>
        <div class="action-group">
          <a class="btn-card-link" href="${asset_prefix}index.html">&larr; All Cards Gallery</a>
          <a class="btn-download" href="${asset_prefix}pdf/${pdf_file}" target="_blank" rel="noopener">Download PDF (${page_count} Pages)</a>
        </div>
      </div>
      <div class="controls">
        <nav class="nav-links" aria-label="Character Cards">
          <span class="nav-label">Cards:</span>
          <a class="nav-pill${sel_seraphina}" href="seraphina.html">01. Seraphina Vale (Paladin 6 / Warlock 2)</a>
          <a class="nav-pill${sel_kaelen}" href="kaelen_rogue.html">02. Kaelen Vane (Arcane Trickster Rogue 7)</a>
          <a class="nav-pill${sel_thokk}" href="thokk_barbarian.html">03. Thokk Grimjaw (Totem Barbarian 5)</a>
        </nav>
      </div>
    </div>
  </header>

  <main class="container">
    <section class="char-panel active">
      <div class="char-meta">
        <div>
          <h2>${heading}</h2>
          <p>${description}</p>
          <div class="badges">
${badges_html}
          </div>
        </div>
        <div class="action-group">
          <a class="btn-card-link" href="${asset_prefix}cards/${active_slug}.html">Open Card (Frameless)</a>
          <a class="btn-download" href="${asset_prefix}pdf/${pdf_file}" target="_blank" rel="noopener">Download PDF (${page_count} Pages)</a>
        </div>
      </div>
${grid_html}
    </section>
  </main>

  <div id="lightbox" class="lightbox" onclick="closeLightbox()">
    <img id="lightbox-img" src="" alt="Full size sheet preview" />
  </div>

  <script>
    function openLightbox(src) {
      document.getElementById('lightbox-img').src = src;
      document.getElementById('lightbox').classList.add('open');
    }
    function closeLightbox() {
      document.getElementById('lightbox').classList.remove('open');
    }
    document.addEventListener('keydown', e => {
      if (e.key === 'Escape') closeLightbox();
    });
  </script>
</body>
</html>
CARD_EOF
}

echo "==> Generating standalone character card pages (<domain>/<card>.html)..."

SERAPHINA_BADGES='            <span class="badge">Level 8 (Prof +3)</span>
            <span class="badge">AC 20 (Auto)</span>
            <span class="badge">HP 66 (Auto)</span>
            <span class="badge">Spell Save DC 15 / +7 Hit</span>
            <span class="badge">Source: character.typ</span>'

KAELEN_BADGES='            <span class="badge">Level 7 (Prof +3)</span>
            <span class="badge">AC 18 (+1 Studded Leather)</span>
            <span class="badge">Initiative +10 (Alert)</span>
            <span class="badge">Passive Inv. 29 / Perc. 22</span>
            <span class="badge">Source: examples/kaelen_rogue.typ</span>'

THOKK_BADGES='            <span class="badge">Level 5 (Prof +3)</span>
            <span class="badge">AC 18 (Unarmored + Shield)</span>
            <span class="badge">HP 70 (Tough Feat Auto)</span>
            <span class="badge">2-Page Martial Sheet</span>
            <span class="badge">Source: examples/thokk_barbarian.typ</span>'

# 1. Seraphina Vale standalone preview pages (root)
for name in seraphina seraphina_paladin_warlock character; do
  generate_card_page \
    "${DIST_DIR}/${name}.html" \
    "" \
    "seraphina" \
    "Seraphina Vale — Half-Elf Paladin (Oath of Devotion 6) / Warlock (The Celestial 2)" \
    "Demonstrates multiclass level &amp; Hit Dice aggregation (6d10 + 2d8), Aura of Protection (+4 global saving throw bonus), Half Plate + Shield + Defense Style (AC 20), and simultaneous Half-Caster + Warlock Pact Magic slot matrices." \
    "${SERAPHINA_BADGES}" \
    "seraphina_paladin_warlock.pdf" \
    "seraphina_page_" \
    "3" \
    "Seraphina Vale"
done

# 2. Kaelen Vane standalone preview pages (root)
for name in kaelen_rogue kaelen; do
  generate_card_page \
    "${DIST_DIR}/${name}.html" \
    "" \
    "kaelen_rogue" \
    "Kaelen &quot;Whisper&quot; Vane — Variant Human Rogue (Arcane Trickster 7)" \
    "Demonstrates Third-Caster progression (Caster Level 3 &rarr; 4&times;1st, 2&times;2nd slots), 4&times; Skill Expertise (Stealth +11, Sleight of Hand +11, Investigation +9, Perception +7), Observant (+5 Passives) &amp; Alert (+5 Initiative) feats, and Finesse DEX attack automation." \
    "${KAELEN_BADGES}" \
    "kaelen_rogue.pdf" \
    "kaelen_page_" \
    "3" \
    "Kaelen Vane"
done

# 3. Thokk Grimjaw standalone preview pages (root)
for name in thokk_barbarian thokk; do
  generate_card_page \
    "${DIST_DIR}/${name}.html" \
    "" \
    "thokk_barbarian" \
    "Thokk &quot;Ironhide&quot; Grimjaw — Half-Orc Barbarian (Path of the Totem Warrior 5)" \
    "Demonstrates non-caster auto-detection (automatically omits Page 3), Barbarian Unarmored Defense (10 + DEX + CON + Shield = AC 18), Tough feat HP calculation (+2 HP/lvl &rarr; 70 Max HP), and 2&times; carrying capacity (540 lb)." \
    "${THOKK_BADGES}" \
    "thokk_barbarian.pdf" \
    "thokk_page_" \
    "2" \
    "Thokk Grimjaw"
done

# 4. Auto-discover any additional `.typ` character cards in `cards/*.typ` or `examples/*.typ`
shopt -s nullglob
for typ_file in "${ROOT_DIR}"/cards/*.typ "${ROOT_DIR}"/examples/*.typ; do
  base="$(basename "${typ_file}" .typ)"
  if [[ "${base}" == "kaelen_rogue" || "${base}" == "thokk_barbarian" ]]; then
    continue
  fi
  echo "==> Compiling custom card [${typ_file#${ROOT_DIR}/}]..."
  typst compile --root "${ROOT_DIR}" "${typ_file}" "${DIST_DIR}/pdf/${base}.pdf"
  typst compile --root "${ROOT_DIR}" --ppi 180 "${typ_file}" "${DIST_DIR}/img/${base}_page_{p}.png"

  pages=0
  for _ in "${DIST_DIR}/img/${base}_page_"*.png; do
    pages=$((pages + 1))
  done

  CUSTOM_BADGES="            <span class=\"badge\">Source: ${typ_file#${ROOT_DIR}/}</span>"
  generate_card_page \
    "${DIST_DIR}/${base}.html" \
    "" \
    "${base}" \
    "${base}" \
    "Custom D&amp;D 5e character card compiled from ${typ_file#${ROOT_DIR}/}." \
    "${CUSTOM_BADGES}" \
    "${base}.pdf" \
    "${base}_page_" \
    "${pages}" \
    "${base}"
done
shopt -u nullglob

echo "==> Compiling standalone frameless HTML cards using native Typst HTML export [cards/*.html and dist/cards/*.html]..."
mkdir -p "${ROOT_DIR}/cards" "${DIST_DIR}/cards"

typst compile --features html --input target=html --root "${ROOT_DIR}" "${ROOT_DIR}/character.typ" "${ROOT_DIR}/cards/character.html"
cp "${ROOT_DIR}/cards/character.html" "${ROOT_DIR}/cards/seraphina.html"
cp "${ROOT_DIR}/cards/character.html" "${ROOT_DIR}/cards/seraphina_paladin_warlock.html"

cp "${ROOT_DIR}/cards/character.html" "${DIST_DIR}/cards/character.html"
cp "${ROOT_DIR}/cards/character.html" "${DIST_DIR}/cards/seraphina.html"
cp "${ROOT_DIR}/cards/character.html" "${DIST_DIR}/cards/seraphina_paladin_warlock.html"

shopt -s nullglob
for typ_file in "${ROOT_DIR}/examples"/*.typ "${ROOT_DIR}/cards"/*.typ; do
  base="$(basename "${typ_file}" .typ)"
  typst compile --features html --input target=html --root "${ROOT_DIR}" "${typ_file}" "${ROOT_DIR}/cards/${base}.html"
  cp "${ROOT_DIR}/cards/${base}.html" "${DIST_DIR}/cards/${base}.html"
done
shopt -u nullglob

echo "==> Generating interactive HTML preview gallery [dist/index.html & dist/cards/index.html]..."
cat > "${DIST_DIR}/index.html" << EOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Evermeet — Automated D&amp;D 5e Typst Character Sheet Preview</title>
  <style>
${SHARED_STYLES}
  </style>
</head>
<body>
  <header>
    <div class="container">
      <div class="header-top">
        <div>
          <h1>Evermeet — Automated D&amp;D 5e Character Sheet Preview</h1>
          <p class="subtitle">Built with Typst • Automated 5e Rules Engine (Multiclassing, AC, Attacks, Skills, Encumbrance &amp; Spell Slots)</p>
        </div>
      </div>
      <div class="controls">
        <div class="tabs" role="tablist">
          <button class="tab-btn active" onclick="selectChar('seraphina', this)">01. Seraphina Vale (Paladin 6 / Warlock 2)</button>
          <button class="tab-btn" onclick="selectChar('kaelen', this)">02. Kaelen Vane (Arcane Trickster Rogue 7)</button>
          <button class="tab-btn" onclick="selectChar('thokk', this)">03. Thokk Grimjaw (Totem Barbarian 5)</button>
        </div>
        <nav class="nav-links" aria-label="Direct Card Pages">
          <span class="nav-label">Card Pages:</span>
          <a class="nav-pill" href="cards/seraphina.html">/cards/seraphina.html</a>
          <a class="nav-pill" href="cards/kaelen_rogue.html">/cards/kaelen_rogue.html</a>
          <a class="nav-pill" href="cards/thokk_barbarian.html">/cards/thokk_barbarian.html</a>
        </nav>
      </div>
    </div>
  </header>

  <main class="container">
    <!-- Character 1: Seraphina -->
    <section id="panel-seraphina" class="char-panel active">
      <div class="char-meta">
        <div>
          <h2>Seraphina Vale — Half-Elf Paladin (Oath of Devotion 6) / Warlock (The Celestial 2)</h2>
          <p>Demonstrates multiclass level &amp; Hit Dice aggregation (6d10 + 2d8), Aura of Protection (+4 global saving throw bonus), Half Plate + Shield + Defense Style (AC 20), and simultaneous Half-Caster + Warlock Pact Magic slot matrices.</p>
          <div class="badges">
            <span class="badge">Level 8 (Prof +3)</span>
            <span class="badge">AC 20 (Auto)</span>
            <span class="badge">HP 66 (Auto)</span>
            <span class="badge">Spell Save DC 15 / +7 Hit</span>
            <span class="badge">Source: character.typ</span>
            <a class="badge" href="seraphina.html">/seraphina.html</a>
            <a class="badge" href="cards/seraphina.html">/cards/seraphina.html</a>
          </div>
        </div>
        <div class="action-group">
          <a class="btn-card-link" href="cards/seraphina.html">Open Card Page</a>
          <a class="btn-download" href="pdf/seraphina_paladin_warlock.pdf" target="_blank" rel="noopener">Download PDF (3 Pages)</a>
        </div>
      </div>
      <div class="pages-grid">
        <div class="page-card">
          <div class="page-card-header"><span>PAGE 01 // CORE &amp; COMBAT</span><span>Click to Zoom</span></div>
          <img src="img/seraphina_page_1.png" alt="Seraphina Page 1" onclick="openLightbox(this.src)" />
        </div>
        <div class="page-card">
          <div class="page-card-header"><span>PAGE 02 // FEATURES &amp; INVENTORY</span><span>Click to Zoom</span></div>
          <img src="img/seraphina_page_2.png" alt="Seraphina Page 2" onclick="openLightbox(this.src)" />
        </div>
        <div class="page-card">
          <div class="page-card-header"><span>PAGE 03 // SPELLCASTING GRIMOIRE</span><span>Click to Zoom</span></div>
          <img src="img/seraphina_page_3.png" alt="Seraphina Page 3" onclick="openLightbox(this.src)" />
        </div>
      </div>
    </section>

    <!-- Character 2: Kaelen -->
    <section id="panel-kaelen" class="char-panel">
      <div class="char-meta">
        <div>
          <h2>Kaelen "Whisper" Vane — Variant Human Rogue (Arcane Trickster 7)</h2>
          <p>Demonstrates Third-Caster progression (Caster Level 3 &rarr; 4&times;1st, 2&times;2nd slots), 4&times; Skill Expertise (Stealth +11, Sleight of Hand +11, Investigation +9, Perception +7), Observant (+5 Passives) &amp; Alert (+5 Initiative) feats, and Finesse DEX attack automation.</p>
          <div class="badges">
            <span class="badge">Level 7 (Prof +3)</span>
            <span class="badge">AC 18 (+1 Studded Leather)</span>
            <span class="badge">Initiative +10 (Alert)</span>
            <span class="badge">Passive Inv. 29 / Perc. 22</span>
            <span class="badge">Source: examples/kaelen_rogue.typ</span>
            <a class="badge" href="kaelen_rogue.html">/kaelen_rogue.html</a>
            <a class="badge" href="cards/kaelen_rogue.html">/cards/kaelen_rogue.html</a>
          </div>
        </div>
        <div class="action-group">
          <a class="btn-card-link" href="cards/kaelen_rogue.html">Open Card Page</a>
          <a class="btn-download" href="pdf/kaelen_rogue.pdf" target="_blank" rel="noopener">Download PDF (3 Pages)</a>
        </div>
      </div>
      <div class="pages-grid">
        <div class="page-card">
          <div class="page-card-header"><span>PAGE 01 // CORE &amp; COMBAT</span><span>Click to Zoom</span></div>
          <img src="img/kaelen_page_1.png" alt="Kaelen Page 1" onclick="openLightbox(this.src)" />
        </div>
        <div class="page-card">
          <div class="page-card-header"><span>PAGE 02 // FEATURES &amp; INVENTORY</span><span>Click to Zoom</span></div>
          <img src="img/kaelen_page_2.png" alt="Kaelen Page 2" onclick="openLightbox(this.src)" />
        </div>
        <div class="page-card">
          <div class="page-card-header"><span>PAGE 03 // SPELLCASTING GRIMOIRE</span><span>Click to Zoom</span></div>
          <img src="img/kaelen_page_3.png" alt="Kaelen Page 3" onclick="openLightbox(this.src)" />
        </div>
      </div>
    </section>

    <!-- Character 3: Thokk -->
    <section id="panel-thokk" class="char-panel">
      <div class="char-meta">
        <div>
          <h2>Thokk "Ironhide" Grimjaw — Half-Orc Barbarian (Path of the Totem Warrior 5)</h2>
          <p>Demonstrates non-caster auto-detection (automatically omits Page 3), Barbarian Unarmored Defense (10 + DEX + CON + Shield = AC 18), Tough feat HP calculation (+2 HP/lvl &rarr; 70 Max HP), and 2&times; carrying capacity (540 lb).</p>
          <div class="badges">
            <span class="badge">Level 5 (Prof +3)</span>
            <span class="badge">AC 18 (Unarmored + Shield)</span>
            <span class="badge">HP 70 (Tough Feat Auto)</span>
            <span class="badge">2-Page Martial Sheet</span>
            <span class="badge">Source: examples/thokk_barbarian.typ</span>
            <a class="badge" href="thokk_barbarian.html">/thokk_barbarian.html</a>
            <a class="badge" href="cards/thokk_barbarian.html">/cards/thokk_barbarian.html</a>
          </div>
        </div>
        <div class="action-group">
          <a class="btn-card-link" href="cards/thokk_barbarian.html">Open Card Page</a>
          <a class="btn-download" href="pdf/thokk_barbarian.pdf" target="_blank" rel="noopener">Download PDF (2 Pages)</a>
        </div>
      </div>
      <div class="pages-grid">
        <div class="page-card">
          <div class="page-card-header"><span>PAGE 01 // CORE &amp; COMBAT</span><span>Click to Zoom</span></div>
          <img src="img/thokk_page_1.png" alt="Thokk Page 1" onclick="openLightbox(this.src)" />
        </div>
        <div class="page-card">
          <div class="page-card-header"><span>PAGE 02 // FEATURES &amp; INVENTORY</span><span>Click to Zoom</span></div>
          <img src="img/thokk_page_2.png" alt="Thokk Page 2" onclick="openLightbox(this.src)" />
        </div>
      </div>
    </section>
  </main>

  <div id="lightbox" class="lightbox" onclick="closeLightbox()">
    <img id="lightbox-img" src="" alt="Full size sheet preview" />
  </div>

  <script>
    function selectChar(id, btn) {
      document.querySelectorAll('.char-panel').forEach(el => el.classList.remove('active'));
      document.querySelectorAll('.tab-btn').forEach(el => el.classList.remove('active'));
      document.getElementById('panel-' + id).classList.add('active');
      btn.classList.add('active');
    }
    function openLightbox(src) {
      document.getElementById('lightbox-img').src = src;
      document.getElementById('lightbox').classList.add('open');
    }
    function closeLightbox() {
      document.getElementById('lightbox').classList.remove('open');
    }
    document.addEventListener('keydown', e => {
      if (e.key === 'Escape') closeLightbox();
    });
  </script>
</body>
</html>
EOF

# Also provide dist/cards/index.html showing the cards index under /cards/
cp "${DIST_DIR}/cards/seraphina.html" "${DIST_DIR}/cards/index.html"

echo "==> Preview site built successfully in ${DIST_DIR}"

if [[ "${1:-}" == "--serve" ]]; then
  PORT="${2:-${PORT:-8000}}"
  echo "==> Serving preview locally at http://localhost:${PORT}/ ..."
  exec python3 -m http.server "${PORT}" --directory "${DIST_DIR}"
fi
