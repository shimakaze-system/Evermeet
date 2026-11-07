#!/usr/bin/env bash
# ============================================================================
# Evermeet D&D 5e Preview Site Builder (`scripts/build_preview.sh`)
# ============================================================================
# Compiles the showcase character (`character.typ`) and all dummy sample
# characters (`examples/*.typ`) into PDFs and high-DPI PNG page previews,
# then generates a static interactive preview site in `dist/index.html`.
# ============================================================================

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_DIR="${ROOT_DIR}/dist"

mkdir -p "${DIST_DIR}/pdf" "${DIST_DIR}/img"

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

echo "==> Generating interactive HTML preview gallery [dist/index.html]..."
cat > "${DIST_DIR}/index.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Evermeet — Automated D&amp;D 5e Typst Character Sheet Preview</title>
  <style>
    :root {
      --bg: #0f1115;
      --surface: #181b22;
      --surface-alt: #222631;
      --border: #2e3444;
      --text: #f3f4f6;
      --muted: #9ca3af;
      --accent: #e5e7eb;
      --badge-bg: #272c3a;
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
    .tabs {
      display: flex;
      flex-wrap: wrap;
      gap: 0.5rem;
    }
    .tab-btn {
      background: var(--surface-alt);
      color: var(--muted);
      border: 1px solid var(--border);
      padding: 0.55rem 1rem;
      border-radius: 6px;
      font-size: 0.88rem;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.15s ease;
    }
    .tab-btn:hover {
      color: var(--text);
      border-color: #4b5563;
    }
    .tab-btn.active {
      background: var(--text);
      color: var(--bg);
      border-color: var(--text);
    }
    .btn-download {
      display: inline-flex;
      align-items: center;
      gap: 0.45rem;
      background: var(--surface-alt);
      color: var(--text);
      text-decoration: none;
      padding: 0.55rem 1rem;
      border-radius: 6px;
      border: 1px solid var(--border);
      font-size: 0.86rem;
      font-weight: 600;
      transition: background 0.15s ease;
    }
    .btn-download:hover {
      background: #2d3343;
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
    /* Lightbox modal for full-resolution page inspection */
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
          </div>
        </div>
        <a class="btn-download" href="pdf/seraphina_paladin_warlock.pdf" target="_blank" rel="noopener">Download PDF (3 Pages)</a>
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
          <p>Demonstrates Third-Caster progression (Caster Level 3 → 4×1st, 2×2nd slots), 4× Skill Expertise (Stealth +11, Sleight of Hand +11, Investigation +9, Perception +7), Observant (+5 Passives) &amp; Alert (+5 Initiative) feats, and Finesse DEX attack automation.</p>
          <div class="badges">
            <span class="badge">Level 7 (Prof +3)</span>
            <span class="badge">AC 18 (+1 Studded Leather)</span>
            <span class="badge">Initiative +10 (Alert)</span>
            <span class="badge">Passive Inv. 29 / Perc. 22</span>
            <span class="badge">Source: examples/kaelen_rogue.typ</span>
          </div>
        </div>
        <a class="btn-download" href="pdf/kaelen_rogue.pdf" target="_blank" rel="noopener">Download PDF (3 Pages)</a>
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
          <p>Demonstrates non-caster auto-detection (automatically omits Page 3), Barbarian Unarmored Defense (10 + DEX + CON + Shield = AC 18), Tough feat HP calculation (+2 HP/lvl → 70 Max HP), and 2× carrying capacity (540 lb).</p>
          <div class="badges">
            <span class="badge">Level 5 (Prof +3)</span>
            <span class="badge">AC 18 (Unarmored + Shield)</span>
            <span class="badge">HP 70 (Tough Feat Auto)</span>
            <span class="badge">2-Page Martial Sheet</span>
            <span class="badge">Source: examples/thokk_barbarian.typ</span>
          </div>
        </div>
        <a class="btn-download" href="pdf/thokk_barbarian.pdf" target="_blank" rel="noopener">Download PDF (2 Pages)</a>
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

echo "==> Preview site built successfully in ${DIST_DIR}"
