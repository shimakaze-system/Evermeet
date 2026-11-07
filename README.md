# Evermeet — Automated D&D 5e Character Sheet in Typst

A clean, modern minimalist, printer-friendly 3-page **Dungeons & Dragons 5th Edition** character sheet built in [Typst](https://typst.app), featuring an automated 5e rules & calculation engine and a GitHub Actions CI preview builder.

## Quick Start

Compile a single character sheet into a PDF using Typst:

```bash
typst compile character.typ character.pdf
```

Or build the full multi-character HTML preview gallery (`dist/index.html`, PNG page renders, and PDFs) locally or in CI:

```bash
./scripts/build_preview.sh
```

## Project Structure

- [`character.typ`](character.typ) — Showcase character definition (`#let character = (...)`) for **Seraphina Vale** (Level 8 Paladin 6 / Celestial Warlock 2).
- [`examples/kaelen_rogue.typ`](examples/kaelen_rogue.typ) — Dummy sample character **Kaelen "Whisper" Vane** (Level 7 Arcane Trickster Rogue with 4× Expertise, Observant, Alert, and Third-Caster spell slots).
- [`examples/thokk_barbarian.typ`](examples/thokk_barbarian.typ) — Dummy sample character **Thokk "Ironhide" Grimjaw** (Level 5 Bear Totem Barbarian demonstrating Unarmored Defense, Tough feat HP, and automatic 2-page non-caster rendering).
- [`lib/rules.typ`](lib/rules.typ) — Automated D&D 5e calculation & rules engine (`evaluate-character`).
- [`lib/sheet.typ`](lib/sheet.typ) — Clean Modern Minimalist 3-page layout and modular UI components (`character-sheet`).
- [`scripts/build_preview.sh`](scripts/build_preview.sh) — Compiles all dummy characters into PDFs and high-DPI PNGs and generates the static HTML preview gallery (`dist/index.html`).
- [`.github/workflows/preview.yml`](.github/workflows/preview.yml) — GitHub Actions CI workflow that compiles the dummy character sheets, generates the preview site, uploads the `character-sheet-preview-site` artifact, and deploys to GitHub Pages when enabled.

## Automated 5e Rules & Calculations

Define only your raw ability scores, class levels, equipment, and proficiencies—the Typst engine automatically computes:

1. **Level & Proficiency Progression**: Sums single-class or multiclass levels (`total_level`), groups Hit Dice by class die size (`d6`–`d12`), and computes Proficiency Bonus ($\lfloor (\text{Level} - 1)/4 \rfloor + 2$).
2. **Ability Scores & Modifiers**: Computes $\lfloor (\text{Score} - 10)/2 \rfloor$ with explicit signed formatting (`+3`, `+0`, `−1`).
3. **Saving Throws**: Automatically grants saving throw proficiencies from the primary class (or custom overrides) and supports global bonuses like Paladin's *Aura of Protection* (`saves.global_bonus`).
4. **All 18 Canonical Skills**: Supports non-proficient (`0`), half-proficient / *Jack of All Trades* / *Remarkable Athlete* (`"half"`), proficient (`"proficient"` or `true`), and expertise (`"expertise"` or `2`), plus per-skill flat bonuses and `[Adv]` markers.
5. **Passive Senses**: Automatically calculates Passive Perception, Passive Investigation, and Passive Insight ($10 + \text{Skill Mod} + 5\text{ if Advantage} + 5\text{ if Observant feat}$).
6. **Armor Class (AC) Engine**: Supports the full 5e armor catalog (`padded`, `leather`, `studded_leather`, `mage_armor`, `hide`, `chain_shirt`, `scale_mail`, `breastplate`, `half_plate`, `ring_mail`, `chain_mail`, `splint`, `plate`), automatic DEX caps (`+2` on medium, `+3` with *Medium Armor Master*, `0` on heavy), shields (`+2` + magic bonus), *Fighting Style: Defense* (`+1`), and Unarmored Defense (*Barbarian*, *Monk*, *Draconic Resilience*).
7. **Hit Points (HP)**: When `hp.max: auto`, automatically computes 5e average HP from class levels, Hit Dice, Constitution modifier, *Tough* feat (`+2/lvl`), and *Dwarven Toughness* / *Draconic Resilience* (`+1/lvl`).
8. **Weapon & Spell Attack Calculator**: Automatically selects the governing ability (`STR`, `DEX` for ranged, `max(STR, DEX)` for `finesse` weapons, or spellcasting ability for spell attacks), adds Proficiency Bonus, magic weapon bonuses (`+1/+2/+3`), and Fighting Styles (*Archery* `+2` to hit, *Dueling* `+2` damage).
9. **Multiclass & Warlock Pact Magic Spellcasting**: Computes effective caster level across Full (`bard`, `cleric`, `druid`, `sorcerer`, `wizard`), Half (`paladin`, `ranger`), Artificer, and Third (`eldritch knight`, `arcane trickster`) casters, populates the 1st–9th level spell slot matrix, tracks Warlock *Pact Magic* slots separately, and computes **Spell Save DC** ($8 + \text{Prof} + \text{Mod}$) and **Spell Attack Bonus** ($\text{Prof} + \text{Mod}$).
10. **Inventory, Wealth & Encumbrance**: Sums item weights (`qty * weight`) and coin weight ($\text{Total Coins} / 50\text{ lb}$), converts currency to total GP value, and calculates carrying capacity ($\text{STR} \times 15\text{ lb}$), encumbered thresholds, and push/drag/lift limits.
