// ============================================================================
// Evermeet D&D 5e Character Sheet UI Components & Layout Engine (lib/sheet.typ)
// ============================================================================
// Clean Modern Minimalist aesthetic:
// - High-contrast monochrome/grayscale palette for crisp screen & print output
// - Modular UI components (section frames, ability score cards, proficiency
//   markers, slot trackers, combat stat pills, attack tables, spell tables)
// - Full 3-page automated layout:
//   * Page 1: Core Attributes, Saves, 18 Skills, Combat & Health, Attacks,
//             Action Economy, Resources, and Proficiencies
//   * Page 2: Features & Traits, Inventory & Automatic Encumbrance, Coin Purse,
//             Attunement Tracker, and Character Lore / Personality
//   * Page 3: Automated Spellcasting Dashboard, Multiclass/Pact Slot Trackers,
//             Cantrips, and Grimoire grouped by Spell Level
// ============================================================================

#import "rules.typ": evaluate-character, abilities-order, ability-names, fmt-mod

// Clean Modern Minimalist Color Palette (Printer-friendly high contrast)
#let palette = (
  ink:         luma(18),   // Primary dark ink
  charcoal:    luma(45),   // Header bar fill
  slate:       luma(95),   // Secondary labels & muted text
  border-dark: luma(35),   // Primary structural border
  border:      luma(165),  // Subtle divider / inner border
  border-soft: luma(210),  // Light table row separator
  bg-tint:     luma(245),  // Soft card background tint
  bg-alt:      luma(236),  // Highlighted pill / zebra row fill
  white:       luma(255),
)

// Typography helpers
#let font-sans = ("Roboto", "Liberation Sans", "DejaVu Sans")
#let font-serif = ("Libertinus Serif", "Liberation Serif", "DejaVu Serif")
#let font-mono = ("DejaVu Sans Mono", "Liberation Mono")

#let label-text(body, size: 6.5pt, color: palette.slate, tracking: 0.6pt) = {
  text(
    font: font-sans,
    size: size,
    weight: "bold",
    fill: color,
    tracking: tracking,
    upper(body),
  )
}

// Proficiency indicator icon:
// - 0: empty circle
// - 0.5: half-filled / dotted circle (Jack of All Trades / Remarkable Athlete)
// - 1: solid black circle (Proficient)
// - 2: double ring with solid core (Expertise)
#let prof-pip(multiplier, size: 6.5pt) = {
  box(width: size + 2pt, height: size, baseline: 10%, align(center + horizon, {
    if multiplier >= 2 {
      circle(
        radius: size / 2,
        stroke: 0.8pt + palette.ink,
        fill: palette.white,
        inset: 0pt,
        align(center + horizon, circle(radius: size / 4, fill: palette.ink, stroke: none)),
      )
    } else if multiplier >= 1 {
      circle(radius: size / 2.2, fill: palette.ink, stroke: 0.75pt + palette.ink)
    } else if multiplier > 0 {
      circle(
        radius: size / 2.2,
        fill: palette.bg-alt,
        stroke: (paint: palette.ink, thickness: 0.75pt, dash: "densely-dotted"),
        align(center + horizon, circle(radius: size / 5, fill: palette.ink, stroke: none)),
      )
    } else {
      circle(radius: size / 2.2, fill: palette.white, stroke: 0.65pt + palette.slate)
    }
  }))
}

// Printable checkbox / resource tracker box
#let check-pip(checked: false, size: 7pt, radius: 1.2pt) = {
  box(
    width: size,
    height: size,
    baseline: 12%,
    radius: radius,
    stroke: 0.75pt + palette.ink,
    fill: if checked { palette.ink } else { palette.white },
  )
}

// Framed Section Container with crisp header bar
#let section-box(title, right-badge: none, fill: palette.white, inset: 6.5pt, body) = {
  block(
    width: 100%,
    stroke: 0.9pt + palette.border-dark,
    radius: 3pt,
    fill: fill,
    clip: true,
    below: 6.5pt,
    stack(
      dir: ttb,
      block(
        width: 100%,
        fill: palette.charcoal,
        inset: (x: 7pt, y: 4pt),
        grid(
          columns: (1fr, auto),
          align: (left + horizon, right + horizon),
          text(
            font: font-sans,
            size: 7.2pt,
            weight: "bold",
            fill: palette.white,
            tracking: 0.8pt,
            upper(title),
          ),
          if right-badge != none {
            text(font: font-sans, size: 6.8pt, weight: "medium", fill: luma(220), right-badge)
          },
        ),
      ),
      block(width: 100%, inset: inset, body),
    ),
  )
}

// Ability Score Card (Big Modifier on top, Score pill at bottom)
#let ability-card(short-name, full-name, score, mod) = {
  block(
    width: 100%,
    stroke: 0.9pt + palette.border-dark,
    radius: 3pt,
    fill: palette.bg-tint,
    inset: (x: 4pt, top: 5pt, bottom: 5pt),
    below: 5.5pt,
    align(center, stack(
      dir: ttb,
      spacing: 2.5pt,
      label-text(short-name, size: 7.5pt, color: palette.ink, tracking: 0.8pt),
      text(font: font-sans, size: 5.8pt, fill: palette.slate, full-name),
      v(1pt),
      block(
        width: 88%,
        fill: palette.white,
        stroke: 0.75pt + palette.border-dark,
        radius: 2.5pt,
        inset: (y: 4.5pt),
        text(font: font-sans, size: 15pt, weight: "bold", fill: palette.ink, fmt-mod(mod)),
      ),
      v(0.5pt),
      box(
        fill: palette.charcoal,
        radius: 8pt,
        inset: (x: 7.5pt, y: 2pt),
        text(font: font-mono, size: 7.5pt, weight: "bold", fill: palette.white, str(score)),
      ),
    )),
  )
}

// Top Character Identity Banner
#let header-banner(c, page-label: "PAGE 1 // CORE & COMBAT") = {
  block(
    width: 100%,
    stroke: 1.1pt + palette.border-dark,
    radius: 3.5pt,
    fill: palette.white,
    clip: true,
    below: 7pt,
    stack(
      dir: ttb,
      // Top dark title bar
      block(
        width: 100%,
        fill: palette.ink,
        inset: (x: 10pt, y: 6.5pt),
        grid(
          columns: (1fr, auto),
          align: (left + horizon, right + horizon),
          stack(
            dir: ttb,
            spacing: 5.5pt,
            text(
              font: font-serif,
              size: 16.5pt,
              weight: "bold",
              fill: palette.white,
              tracking: 0.3pt,
              bottom-edge: "descender",
              c.name,
            ),
            text(
              font: font-sans,
              size: 8pt,
              weight: "medium",
              fill: luma(215),
              top-edge: "ascender",
              c.race + "  •  " + c.class_summary,
            ),
          ),
          stack(
            dir: ltr,
            spacing: 6pt,
            box(
              stroke: 0.75pt + luma(160),
              radius: 2.5pt,
              fill: palette.charcoal,
              inset: (x: 7pt, y: 4pt),
              align(center, stack(
                dir: ttb,
                spacing: 2pt,
                text(font: font-sans, size: 5.5pt, weight: "bold", fill: luma(195), tracking: 0.6pt, "LEVEL"),
                text(font: font-mono, size: 11pt, weight: "bold", fill: palette.white, str(c.total_level)),
              )),
            ),
            box(
              stroke: 0.75pt + luma(160),
              radius: 2.5pt,
              fill: palette.charcoal,
              inset: (x: 7pt, y: 4pt),
              align(center, stack(
                dir: ttb,
                spacing: 2pt,
                text(font: font-sans, size: 5.5pt, weight: "bold", fill: luma(195), tracking: 0.6pt, "PROF BONUS"),
                text(font: font-mono, size: 11pt, weight: "bold", fill: palette.white, c.prof_bonus_str),
              )),
            ),
          ),
        ),
      ),
      // Metadata strip
      block(
        width: 100%,
        fill: palette.bg-tint,
        inset: (x: 10pt, y: 4.5pt),
        grid(
          columns: (1.2fr, 1.1fr, 1fr, 0.9fr, auto),
          gutter: 8pt,
          align: (left + horizon, left + horizon, left + horizon, left + horizon, right + horizon),
          stack(dir: ttb, spacing: 2pt, label-text("Background", size: 5.5pt), text(size: 7.8pt, weight: "medium", c.background)),
          stack(dir: ttb, spacing: 2pt, label-text("Alignment", size: 5.5pt), text(size: 7.8pt, weight: "medium", c.alignment)),
          stack(dir: ttb, spacing: 2pt, label-text("Player", size: 5.5pt), text(size: 7.8pt, weight: "medium", c.player)),
          stack(dir: ttb, spacing: 2pt, label-text("Experience", size: 5.5pt), text(size: 7.8pt, weight: "medium", str(c.xp))),
          text(font: font-mono, size: 6.5pt, weight: "bold", fill: palette.slate, page-label),
        ),
      ),
    ),
  )
}

// KPI Stat Pill (AC, Initiative, Speed, Inspiration, etc.)
#let stat-pill(label, value, subtext: none, prominent: false) = {
  let val-str = str(value)
  let val-size = if val-str.len() > 8 { 10.5pt } else if val-str.len() > 5 { 12pt } else { 14.5pt }
  block(
    width: 100%,
    height: 46pt,
    stroke: (if prominent { 1.2pt } else { 0.85pt }) + palette.border-dark,
    radius: 3pt,
    fill: if prominent { palette.bg-tint } else { palette.white },
    inset: (x: 4pt, y: 4.5pt),
    align(center + horizon, stack(
      dir: ttb,
      spacing: 3pt,
      label-text(label, size: 6pt, color: palette.ink),
      text(font: font-mono, size: val-size, weight: "bold", fill: palette.ink, val-str),
      if subtext != none {
        text(font: font-sans, size: 5.6pt, fill: palette.slate, subtext)
      },
    )),
  )
}

// ============================================================================
// PAGE 1: Core Attributes, Skills, Combat, Attacks, Actions & Resources
// ============================================================================
#let render-page-one(c) = {
  header-banner(c, page-label: "SHEET 01 // CORE & COMBAT")

  grid(
    columns: (54pt, 148pt, 1fr),
    gutter: 8pt,

    // COLUMN 1: 6 Ability Score Cards + Inspiration Badge
    {
      for ab in abilities-order {
        ability-card(
          ability-names.at(ab).short,
          ability-names.at(ab).full,
          c.scores.at(ab),
          c.mods.at(ab),
        )
      }
      // Heroic Inspiration Box
      block(
        width: 100%,
        stroke: 0.9pt + palette.border-dark,
        radius: 3pt,
        fill: palette.white,
        inset: (x: 4pt, y: 5pt),
        align(center, stack(
          dir: ttb,
          spacing: 3pt,
          label-text("Inspiration", size: 5.8pt, color: palette.ink),
          check-pip(checked: c.inspiration, size: 11pt, radius: 2pt),
        )),
      )
    },

    // COLUMN 2: Saving Throws, 18 Skills, Passive Senses
    {
      // Saving Throws
      section-box("Saving Throws", right-badge: "Auto", inset: 5.5pt)[
        #stack(
          dir: ttb,
          spacing: 3.2pt,
          ..abilities-order.map(ab => {
            let sv = c.saves.at(ab)
            grid(
              columns: (12pt, 24pt, 1fr),
              align: (left + horizon, right + horizon, left + horizon),
              column-gutter: 4pt,
              prof-pip(sv.multiplier),
              text(font: font-mono, size: 8pt, weight: "bold", fill: palette.ink, sv.mod_str),
              text(
                font: font-sans,
                size: 7.8pt,
                weight: if sv.proficient { "bold" } else { "regular" },
                fill: palette.ink,
                sv.full,
              ),
            )
          }),
        )
        #if c.save_notes != none [
          #line(length: 100%, stroke: 0.5pt + palette.border-soft)
          #text(size: 6.5pt, style: "italic", fill: palette.slate, c.save_notes)
        ]
      ]

      // 18 Canonical Skills
      section-box("Skills", right-badge: "● Prof  ◎ Exp", inset: 5.5pt)[
        #stack(
          dir: ttb,
          spacing: 2.85pt,
          ..c.skills.map(sk => {
            grid(
              columns: (11pt, 22pt, 1fr, auto),
              align: (left + horizon, right + horizon, left + horizon, right + horizon),
              column-gutter: 3.5pt,
              prof-pip(sk.multiplier, size: 6pt),
              text(font: font-mono, size: 7.6pt, weight: "bold", fill: palette.ink, sk.mod_str),
              text(
                font: font-sans,
                size: 7.4pt,
                weight: if sk.proficient or sk.expertise { "bold" } else { "regular" },
                fill: palette.ink,
                sk.name + (if sk.advantage { " [Adv]" } else { "" }),
              ),
              text(font: font-mono, size: 6pt, fill: palette.slate, sk.ability_short),
            )
          }),
        )
      ]

      // Passive Senses
      section-box("Passive Senses", inset: 5.5pt)[
        #stack(
          dir: ttb,
          spacing: 3.5pt,
          ..(
            ("Passive Perception (WIS)", c.passives.perception),
            ("Passive Investigation (INT)", c.passives.investigation),
            ("Passive Insight (WIS)", c.passives.insight),
          ).map(pair => {
            grid(
              columns: (24pt, 1fr),
              column-gutter: 6pt,
              align: (center + horizon, left + horizon),
              box(
                width: 24pt,
                fill: palette.bg-alt,
                stroke: 0.65pt + palette.border-dark,
                radius: 2pt,
                inset: (y: 2pt),
                text(font: font-mono, size: 8pt, weight: "bold", str(pair.at(1))),
              ),
              text(size: 7.3pt, weight: "medium", pair.at(0)),
            )
          }),
        )
      ]
    },

    // COLUMN 3: Combat Dashboard, HP, Hit Dice/Death Saves, Attacks, Actions, Resources & Proficiencies
    {
      // Top Combat Stat Row
      grid(
        columns: (1.1fr, 1fr, 1fr, 1.3fr),
        gutter: 6pt,
        stat-pill(
          "Armor Class",
          c.ac.total,
          subtext: c.ac.base_name + (if c.ac.shield { " + Shield" } else { "" }),
          prominent: true,
        ),
        stat-pill("Initiative", c.initiative_str, subtext: "DEX " + fmt-mod(c.mods.dex)),
        stat-pill("Speed", c.speed, subtext: if c.ac.stealth_disadv { "Stealth Disadv." } else { "Normal Gait" }),
        stat-pill("Hit Dice", c.hp.hit_dice_summary, subtext: "Total Pool"),
      )
      v(-1pt)

      // Hit Points, Hit Dice & Death Saves Box
      section-box("Vitality & Defense", right-badge: c.ac.formula, inset: 6pt)[
        #grid(
          columns: (1.25fr, 1fr),
          gutter: 8pt,
          // Left: Max HP, Current HP, Temp HP
          block(
            width: 100%,
            stroke: 0.65pt + palette.border,
            radius: 2.5pt,
            fill: palette.bg-tint,
            inset: 6pt,
            stack(
              dir: ttb,
              spacing: 5pt,
              grid(
                columns: (1fr, 1fr, 1fr),
                gutter: 4pt,
                align: center,
                stack(
                  dir: ttb,
                  spacing: 2pt,
                  label-text("Max HP", size: 5.6pt),
                  text(font: font-mono, size: 12pt, weight: "bold", str(c.hp.max)),
                ),
                stack(
                  dir: ttb,
                  spacing: 2pt,
                  label-text("Current HP", size: 5.6pt),
                  text(font: font-mono, size: 12pt, weight: "bold", str(c.hp.current)),
                ),
                stack(
                  dir: ttb,
                  spacing: 2pt,
                  label-text("Temp HP", size: 5.6pt),
                  text(font: font-mono, size: 12pt, weight: "bold", if c.hp.temp > 0 { "+" + str(c.hp.temp) } else { "—" }),
                ),
              ),
              line(length: 100%, stroke: 0.5pt + palette.border),
              grid(
                columns: (auto, 1fr),
                column-gutter: 5pt,
                label-text("Senses:", size: 5.8pt, color: palette.ink),
                text(size: 7pt, c.senses),
              ),
            ),
          ),
          // Right: Hit Dice Spend & Death Saving Throws
          block(
            width: 100%,
            stroke: 0.65pt + palette.border,
            radius: 2.5pt,
            fill: palette.white,
            inset: 6pt,
            stack(
              dir: ttb,
              spacing: 4.5pt,
              label-text("Hit Dice Tracker", size: 5.8pt, color: palette.ink),
              ..c.hp.hit_dice.map(hd => {
                grid(
                  columns: (auto, 1fr),
                  column-gutter: 5pt,
                  align: (left + horizon, right + horizon),
                  text(font: font-mono, size: 7.2pt, weight: "bold", str(hd.total) + hd.die),
                  stack(
                    dir: ltr,
                    spacing: 2.5pt,
                    ..range(calc.min(10, hd.total)).map(i => check-pip(checked: i < hd.at("spent", default: 0), size: 6.2pt)),
                  ),
                )
              }),
              line(length: 100%, stroke: 0.5pt + palette.border-soft),
              label-text("Death Saving Throws", size: 5.8pt, color: palette.ink),
              grid(
                columns: (1fr, auto, 1fr, auto),
                column-gutter: 4pt,
                align: horizon,
                text(size: 6.5pt, weight: "medium", "Succ"),
                stack(dir: ltr, spacing: 2pt, ..range(3).map(i => check-pip(checked: i < c.hp.death_saves.at("successes", default: 0), size: 6pt))),
                text(size: 6.5pt, weight: "medium", "Fail"),
                stack(dir: ltr, spacing: 2pt, ..range(3).map(i => check-pip(checked: i < c.hp.death_saves.at("failures", default: 0), size: 6pt))),
              ),
            ),
          ),
        )
        #let res = c.defenses.at("resistances", default: ())
        #let imm = c.defenses.at("immunities", default: ())
        #if res.len() > 0 or imm.len() > 0 [
          #v(2pt)
          #grid(
            columns: (1fr, 1fr),
            gutter: 6pt,
            if res.len() > 0 {
              text(size: 6.8pt)[*Resistances:* #res.join(", ")]
            },
            if imm.len() > 0 {
              text(size: 6.8pt)[*Immunities:* #imm.join(", ")]
            },
          )
        ]
      ]

      // Automated Weapon & Spell Attacks Table
      section-box("Attacks & Spellcasting", right-badge: "Auto-Calculated Hit & Damage", inset: 0pt)[
        #table(
          columns: (1.45fr, 34pt, 36pt, 1.35fr, 0.9fr),
          align: (left + horizon, center + horizon, center + horizon, left + horizon, left + horizon),
          stroke: (x, y) => (
            bottom: 0.5pt + palette.border-soft,
            top: if y == 0 { none } else { 0.5pt + palette.border-soft },
          ),
          fill: (x, y) => if y == 0 { palette.bg-alt } else if calc.even(y) { palette.bg-tint } else { palette.white },
          inset: (x: 6pt, y: 4.5pt),
          table.header(
            label-text("Weapon / Attack", size: 5.8pt, color: palette.ink),
            label-text("Stat", size: 5.8pt, color: palette.ink),
            label-text("Hit", size: 5.8pt, color: palette.ink),
            label-text("Damage", size: 5.8pt, color: palette.ink),
            label-text("Range / Notes", size: 5.8pt, color: palette.ink),
          ),
          ..c.attacks.map(atk => (
            stack(
              dir: ttb,
              spacing: 1.5pt,
              text(size: 7.6pt, weight: "bold", fill: palette.ink, atk.name),
              if atk.properties.len() > 0 {
                text(size: 6pt, fill: palette.slate, atk.properties.join(", "))
              },
            ),
            text(font: font-mono, size: 6.8pt, weight: "medium", atk.ability),
            box(
              fill: palette.charcoal,
              radius: 2pt,
              inset: (x: 4.5pt, y: 2pt),
              text(font: font-mono, size: 7.8pt, weight: "bold", fill: palette.white, atk.to_hit_str),
            ),
            stack(
              dir: ttb,
              spacing: 1.5pt,
              text(font: font-mono, size: 7.4pt, weight: "bold", atk.damage),
              text(size: 6pt, fill: palette.slate, atk.damage_type),
            ),
            stack(
              dir: ttb,
              spacing: 1.5pt,
              text(size: 6.8pt, atk.range),
              if atk.notes != none { text(size: 5.8pt, style: "italic", fill: palette.slate, atk.notes) },
            ),
          )).flatten()
        )
      ]

      // Class & Feature Resource Trackers (Limited-Use Pools)
      if c.resources.len() > 0 {
        section-box("Class Resources & Limited-Use Pools", right-badge: "Short / Long Rest", inset: 5.5pt)[
          #grid(
            columns: (1fr, 1fr),
            gutter: 6pt,
            ..c.resources.map(res => {
              let max-uses = res.at("max", default: 1)
              let used = res.at("used", default: 0)
              let recharge = res.at("recharge", default: "Long Rest")
              block(
                width: 100%,
                stroke: 0.6pt + palette.border,
                radius: 2.5pt,
                fill: palette.bg-tint,
                inset: (x: 6pt, y: 4.5pt),
                stack(
                  dir: ttb,
                  spacing: 3pt,
                  grid(
                    columns: (1fr, auto),
                    text(size: 7.4pt, weight: "bold", res.name),
                    text(font: font-mono, size: 6pt, fill: palette.slate, recharge),
                  ),
                  if max-uses <= 12 {
                    stack(
                      dir: ltr,
                      spacing: 3pt,
                      ..range(max-uses).map(i => check-pip(checked: i < used, size: 6.8pt)),
                      h(4pt),
                      if "notes" in res and res.notes != none {
                        text(size: 6.2pt, fill: palette.slate, res.notes)
                      },
                    )
                  } else {
                    grid(
                      columns: (auto, 1fr),
                      column-gutter: 6pt,
                      text(font: font-mono, size: 7.5pt, weight: "bold", str(max-uses - used) + " / " + str(max-uses) + " pts"),
                      if "notes" in res and res.notes != none {
                        text(size: 6.2pt, fill: palette.slate, res.notes)
                      },
                    )
                  },
                ),
              )
            }),
          )
        ]
      }

      // Action Economy Quick Reference + Proficiencies & Languages
      grid(
        columns: (1.1fr, 0.9fr),
        gutter: 6pt,
        section-box("Action Economy Summary", inset: 5.5pt)[
          #let acts = c.combat_actions
          #stack(
            dir: ttb,
            spacing: 4pt,
            ..(
              ("Action", acts.at("actions", default: ("Attack", "Cast a Spell", "Dash / Disengage / Dodge"))),
              ("Bonus Action", acts.at("bonus_actions", default: ("Off-hand / Class Feature",))),
              ("Reaction", acts.at("reactions", default: ("Opportunity Attack",))),
              ("Special", acts.at("special", default: ())),
            ).filter(pair => pair.at(1).len() > 0).map(pair => {
              stack(
                dir: ttb,
                spacing: 1.5pt,
                label-text(pair.at(0), size: 5.8pt, color: palette.ink),
                text(size: 6.9pt, fill: palette.charcoal, pair.at(1).join(" • ")),
              )
            }),
          )
        ],
        section-box("Proficiencies & Languages", inset: 5.5pt)[
          #let p = c.proficiencies
          #stack(
            dir: ttb,
            spacing: 3.8pt,
            ..(
              ("Armor", p.at("armor", default: ("None",))),
              ("Weapons", p.at("weapons", default: ("Simple",))),
              ("Tools", p.at("tools", default: ("None",))),
              ("Languages", p.at("languages", default: ("Common",))),
            ).map(pair => {
              stack(
                dir: ttb,
                spacing: 1.2pt,
                label-text(pair.at(0), size: 5.8pt, color: palette.ink),
                text(size: 6.8pt, fill: palette.charcoal, if type(pair.at(1)) == array { pair.at(1).join(", ") } else { str(pair.at(1)) }),
              )
            }),
          )
        ],
      )
    },
  )
}

// ============================================================================
// PAGE 2: Features & Traits, Equipment & Automated Encumbrance, Lore & Notes
// ============================================================================
#let render-page-two(c) = {
  header-banner(c, page-label: "SHEET 02 // FEATURES & INVENTORY")

  grid(
    columns: (1.18fr, 0.82fr),
    gutter: 8pt,

    // LEFT COLUMN: Racial Traits, Class Features, Feats & Boons
    {
      section-box("Features, Traits & Feats", right-badge: "Complete Reference", inset: 6.5pt)[
        #if c.features.len() == 0 [
          #text(size: 7.5pt, style: "italic", fill: palette.slate, "No features listed.")
        ] else [
          #stack(
            dir: ttb,
            spacing: 6pt,
            ..c.features.map(feat => {
              block(
                width: 100%,
                stroke: (left: 2pt + palette.ink),
                inset: (left: 6pt, y: 1pt),
                stack(
                  dir: ttb,
                  spacing: 2pt,
                  grid(
                    columns: (1fr, auto),
                    align: (left + horizon, right + horizon),
                    text(size: 8pt, weight: "bold", fill: palette.ink, feat.at("name", default: "Feature")),
                    if "source" in feat and feat.source != none {
                      box(
                        fill: palette.bg-alt,
                        radius: 2pt,
                        inset: (x: 4pt, y: 1.5pt),
                        text(font: font-mono, size: 5.8pt, weight: "bold", fill: palette.charcoal, feat.source),
                      )
                    },
                  ),
                  text(size: 7.1pt, fill: palette.charcoal, par(leading: 0.45em, feat.at("description", default: ""))),
                ),
              )
            }),
          )
        ]
      ]
    },

    // RIGHT COLUMN: Coin Purse, Automated Encumbrance, Equipment Table, Attunement & Character Lore
    {
      let inv = c.inventory

      // Wealth & Encumbrance Dashboard
      section-box(
        "Wealth & Carrying Capacity",
        right-badge: "Total Value: " + str(inv.total_gp_value) + " gp",
        inset: 6pt,
      )[
        #stack(
          dir: ttb,
          spacing: 5.5pt,
          // 5 Coin denomination boxes
          grid(
            columns: (1fr, 1fr, 1fr, 1fr, 1fr),
            gutter: 4pt,
            ..(
              ("CP", inv.coins.cp),
              ("SP", inv.coins.sp),
              ("EP", inv.coins.ep),
              ("GP", inv.coins.gp),
              ("PP", inv.coins.pp),
            ).map(coin => {
              block(
                width: 100%,
                stroke: 0.7pt + palette.border-dark,
                radius: 2.5pt,
                fill: palette.bg-tint,
                inset: (y: 3.5pt),
                align(center, stack(
                  dir: ttb,
                  spacing: 1.5pt,
                  label-text(coin.at(0), size: 5.8pt, color: palette.ink),
                  text(font: font-mono, size: 8.5pt, weight: "bold", str(coin.at(1))),
                )),
              )
            }),
          ),
          // Automated Weight & Encumbrance Bar
          block(
            width: 100%,
            stroke: 0.65pt + palette.border,
            radius: 2.5pt,
            fill: palette.white,
            inset: 5pt,
            stack(
              dir: ttb,
              spacing: 3.5pt,
              grid(
                columns: (1fr, 1fr, 1fr),
                align: center,
                stack(
                  dir: ttb,
                  spacing: 1.5pt,
                  label-text("Carried Wt.", size: 5.5pt),
                  text(font: font-mono, size: 8.2pt, weight: "bold", str(inv.total_weight) + " lb"),
                ),
                stack(
                  dir: ttb,
                  spacing: 1.5pt,
                  label-text("Max Capacity", size: 5.5pt),
                  text(font: font-mono, size: 8.2pt, weight: "bold", str(inv.capacity) + " lb"),
                ),
                stack(
                  dir: ttb,
                  spacing: 1.5pt,
                  label-text("Push / Drag", size: 5.5pt),
                  text(font: font-mono, size: 8.2pt, weight: "bold", str(inv.push_drag_lift) + " lb"),
                ),
              ),
              // Visual Load Bar
              {
                let pct = calc.min(100, calc.round((inv.total_weight / calc.max(1, inv.capacity)) * 100))
                stack(
                  dir: ttb,
                  spacing: 2pt,
                  block(
                    width: 100%,
                    height: 5pt,
                    radius: 2pt,
                    fill: palette.bg-alt,
                    stroke: 0.4pt + palette.border-dark,
                    clip: true,
                    block(width: pct * 1%, height: 100%, fill: palette.charcoal),
                  ),
                  grid(
                    columns: (1fr, auto),
                    text(size: 5.8pt, fill: palette.slate, "Gear: " + str(inv.items_weight) + " lb + Coins: " + str(inv.coin_weight) + " lb"),
                    text(size: 5.8pt, fill: palette.slate, "Encumbered: " + str(inv.encumbered) + " lb"),
                  ),
                )
              },
            ),
          ),
        )
      ]

      // Equipment & Inventory Table
      section-box("Equipment & Inventory", right-badge: str(inv.items.len()) + " Entries", inset: 0pt)[
        #table(
          columns: (22pt, 1fr, 38pt),
          align: (center + horizon, left + horizon, right + horizon),
          stroke: (x, y) => (
            bottom: 0.5pt + palette.border-soft,
            top: if y == 0 { none } else { 0.5pt + palette.border-soft },
          ),
          fill: (x, y) => if y == 0 { palette.bg-alt } else if calc.even(y) { palette.bg-tint } else { palette.white },
          inset: (x: 5pt, y: 3.6pt),
          table.header(
            label-text("Qty", size: 5.6pt, color: palette.ink),
            label-text("Item / Description", size: 5.6pt, color: palette.ink),
            label-text("Wt (lb)", size: 5.6pt, color: palette.ink),
          ),
          ..inv.items.map(it => (
            text(font: font-mono, size: 7pt, weight: "bold", str(it.qty)),
            stack(
              dir: ttb,
              spacing: 1pt,
              text(
                size: 7.2pt,
                weight: if it.at("attuned", default: false) { "bold" } else { "regular" },
                it.name + (if it.at("attuned", default: false) { " [Attuned]" } else { "" }),
              ),
              if it.notes != none { text(size: 5.8pt, fill: palette.slate, it.notes) },
            ),
            text(font: font-mono, size: 6.8pt, fill: palette.charcoal, if it.total_weight > 0 { str(it.total_weight) } else { "—" }),
          )).flatten()
        )
      ]

      // Magic Item Attunement (3 Slots)
      section-box("Magic Item Attunement", right-badge: str(inv.attuned_items.len()) + " / 3 Slots", inset: 5.5pt)[
        #stack(
          dir: ttb,
          spacing: 3.5pt,
          ..range(3).map(idx => {
            let has-item = idx < inv.attuned_items.len()
            let item-name = if has-item { inv.attuned_items.at(idx) } else { "Empty Attunement Slot" }
            grid(
              columns: (12pt, 1fr),
              column-gutter: 5pt,
              align: horizon,
              check-pip(checked: has-item, size: 7pt),
              text(
                size: 7.2pt,
                weight: if has-item { "bold" } else { "regular" },
                style: if has-item { "normal" } else { "italic" },
                fill: if has-item { palette.ink } else { palette.slate },
                item-name,
              ),
            )
          }),
        )
      ]

      // Personality, Ideals, Bonds, Flaws & Backstory
      let bio = c.biography
      section-box("Personality & Backstory", inset: 6pt)[
        #stack(
          dir: ttb,
          spacing: 4.5pt,
          ..(
            ("Personality Traits", bio.at("traits", default: none)),
            ("Ideals", bio.at("ideals", default: none)),
            ("Bonds", bio.at("bonds", default: none)),
            ("Flaws", bio.at("flaws", default: none)),
            ("Appearance & Allies", bio.at("appearance", default: none)),
            ("Backstory & Notes", bio.at("backstory", default: none)),
          ).filter(p => p.at(1) != none and p.at(1) != "").map(pair => {
            stack(
              dir: ttb,
              spacing: 1.5pt,
              label-text(pair.at(0), size: 5.8pt, color: palette.ink),
              text(size: 7pt, fill: palette.charcoal, par(leading: 0.42em, pair.at(1))),
            )
          }),
        )
      ]
    },
  )
}

// ============================================================================
// PAGE 3: Automated Spellcasting Dashboard, Slot Matrix & Grimoire
// ============================================================================
#let render-page-three(c) = {
  let sc = c.spellcasting
  header-banner(c, page-label: "SHEET 03 // SPELLCASTING GRIMOIRE")

  // Top Spellcasting KPI Bar
  grid(
    columns: (1fr, 1fr, 1fr, 1fr, 1.3fr),
    gutter: 6pt,
    stat-pill("Spell Ability", sc.ability_short, subtext: "Mod " + fmt-mod(sc.ability_mod), prominent: true),
    stat-pill("Spell Save DC", sc.save_dc, subtext: "8 + Prof + " + sc.ability_short, prominent: true),
    stat-pill("Spell Attack", fmt-mod(sc.attack_bonus), subtext: "Prof + " + sc.ability_short, prominent: true),
    stat-pill("Caster Level", sc.caster_level, subtext: if sc.pact.active { "Pact Lvl " + str(sc.pact.warlock_level) } else { "5e Progression" }),
    stat-pill(
      "Prepared Limit",
      if sc.prepared_limit != none { sc.prepared_limit } else { "Known" },
      subtext: if sc.notes != none { sc.notes } else { "Spell Focus Active" },
    ),
  )
  v(5pt)

  // Automated Spell Slot Tracker Matrix (1st - 9th Level + Pact Magic if Warlock)
  section-box(
    "Automated Spell Slot Matrix (5e Progression)",
    right-badge: if sc.pact.active {
      "Pact Magic: " + str(sc.pact.slots) + " Slots (Level " + str(sc.pact.slot_level) + " • Short Rest)"
    } else {
      "Long Rest Recovery"
    },
    inset: 6pt,
  )[
    #grid(
      columns: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
      gutter: 4.5pt,
      ..range(9).map(idx => {
        let lvl = idx + 1
        let max-s = if idx < sc.slots_max.len() { sc.slots_max.at(idx) } else { 0 }
        let used-s = if idx < sc.slots_used.len() { sc.slots_used.at(idx) } else { 0 }
        block(
          width: 100%,
          stroke: (if max-s > 0 { 0.8pt + palette.border-dark } else { 0.5pt + palette.border-soft }),
          radius: 2.5pt,
          fill: if max-s > 0 { palette.bg-tint } else { palette.white },
          inset: (x: 4pt, y: 4pt),
          align(center, stack(
            dir: ttb,
            spacing: 3pt,
            label-text("Level " + str(lvl), size: 5.8pt, color: if max-s > 0 { palette.ink } else { palette.slate }),
            if max-s > 0 {
              stack(
                dir: ltr,
                spacing: 2.5pt,
                ..range(max-s).map(i => check-pip(checked: i < used-s, size: 6.5pt)),
              )
            } else {
              text(font: font-mono, size: 7pt, fill: palette.slate, "—")
            },
            text(font: font-mono, size: 6pt, fill: palette.slate, str(max-s) + " total"),
          )),
        )
      }),
    )
    #if sc.pact.active [
      #v(4pt)
      #block(
        width: 100%,
        stroke: 0.75pt + palette.border-dark,
        radius: 2.5pt,
        fill: palette.bg-alt,
        inset: (x: 8pt, y: 4.5pt),
        grid(
          columns: (auto, auto, 1fr),
          column-gutter: 10pt,
          align: horizon,
          label-text("Warlock Pact Magic Slots (Level " + str(sc.pact.slot_level) + "):", size: 6.2pt, color: palette.ink),
          stack(
            dir: ltr,
            spacing: 3.5pt,
            ..range(sc.pact.slots).map(i => check-pip(checked: i < sc.pact.used, size: 7.5pt)),
          ),
          text(size: 6.8pt, fill: palette.charcoal, "All Pact Magic slots recharge on a Short or Long Rest."),
        ),
      )
    ]
  ]

  // Cantrips (Level 0 Spells)
  if sc.cantrips.len() > 0 {
    section-box("Cantrips (At-Will // Level 0)", right-badge: str(sc.cantrips.len()) + " Known", inset: 0pt)[
      #table(
        columns: (1.2fr, 58pt, 64pt, 54pt, 2fr),
        align: (left + horizon, center + horizon, center + horizon, center + horizon, left + horizon),
        stroke: (x, y) => (
          bottom: 0.5pt + palette.border-soft,
          top: if y == 0 { none } else { 0.5pt + palette.border-soft },
        ),
        fill: (x, y) => if y == 0 { palette.bg-alt } else if calc.even(y) { palette.bg-tint } else { palette.white },
        inset: (x: 6pt, y: 4pt),
        table.header(
          label-text("Cantrip Name", size: 5.8pt, color: palette.ink),
          label-text("Cast Time", size: 5.8pt, color: palette.ink),
          label-text("Range", size: 5.8pt, color: palette.ink),
          label-text("Comp.", size: 5.8pt, color: palette.ink),
          label-text("Effect / Scaling Summary", size: 5.8pt, color: palette.ink),
        ),
        ..sc.cantrips.map(sp => (
          text(size: 7.4pt, weight: "bold", sp.at("name", default: "Cantrip")),
          text(size: 6.8pt, sp.at("time", default: "1 Action")),
          text(size: 6.8pt, sp.at("range", default: "60 ft.")),
          text(font: font-mono, size: 6.4pt, sp.at("components", default: "V, S")),
          text(size: 6.8pt, fill: palette.charcoal, sp.at("notes", default: "")),
        )).flatten()
      )
    ]
  }

  // Leveled Spells (1st - 9th Level)
  if sc.spells.len() > 0 {
    section-box(
      "Leveled Spells Grimoire",
      right-badge: "● Prepared / Always Prepared   [C] Concentration   [R] Ritual",
      inset: 0pt,
    )[
      #table(
        columns: (24pt, 28pt, 1.35fr, 54pt, 58pt, 68pt, 46pt, 2.05fr),
        align: (
          center + horizon,
          center + horizon,
          left + horizon,
          center + horizon,
          center + horizon,
          center + horizon,
          center + horizon,
          left + horizon,
        ),
        stroke: (x, y) => (
          bottom: 0.5pt + palette.border-soft,
          top: if y == 0 { none } else { 0.5pt + palette.border-soft },
        ),
        fill: (x, y) => if y == 0 { palette.bg-alt } else if calc.even(y) { palette.bg-tint } else { palette.white },
        inset: (x: 5pt, y: 4.2pt),
        table.header(
          label-text("Prep", size: 5.6pt, color: palette.ink),
          label-text("Lvl", size: 5.6pt, color: palette.ink),
          label-text("Spell Name", size: 5.6pt, color: palette.ink),
          label-text("Time", size: 5.6pt, color: palette.ink),
          label-text("Range", size: 5.6pt, color: palette.ink),
          label-text("Duration", size: 5.6pt, color: palette.ink),
          label-text("Save/Hit", size: 5.6pt, color: palette.ink),
          label-text("Effect & Tactical Notes", size: 5.6pt, color: palette.ink),
        ),
        ..sc.spells.map(sp => {
          let prep = sp.at("prepared", default: true)
          let always = sp.at("always_prepared", default: false)
          let conc = sp.at("concentration", default: false)
          let ritual = sp.at("ritual", default: false)
          let badges = (
            if conc { "[C]" } else { none },
            if ritual { "[R]" } else { none },
          ).filter(x => x != none).join(" ")

          (
            prof-pip(if always { 2 } else if prep { 1 } else { 0 }, size: 6pt),
            box(
              fill: palette.charcoal,
              radius: 2pt,
              inset: (x: 4pt, y: 1.5pt),
              text(font: font-mono, size: 6.6pt, weight: "bold", fill: palette.white, str(sp.at("level", default: 1))),
            ),
            text(
              size: 7.4pt,
              weight: "bold",
              fill: palette.ink,
              sp.at("name", default: "Spell") + (if badges != "" { " " + badges } else { "" }),
            ),
            text(size: 6.6pt, sp.at("time", default: "1 Action")),
            text(size: 6.6pt, sp.at("range", default: "60 ft.")),
            text(size: 6.6pt, sp.at("duration", default: "Instant")),
            text(font: font-mono, size: 6.6pt, weight: "medium", sp.at("attack_save", default: "—")),
            text(size: 6.7pt, fill: palette.charcoal, sp.at("notes", default: "")),
          )
        }).flatten()
      )
    ]
  }
}

// ============================================================================
// Top-Level Template Function: `character-sheet(data, paper: "a4")`
// ============================================================================
#let character-sheet(data, paper: "a4") = {
  let c = evaluate-character(data)
  let is-html = sys.inputs.at("target", default: "") == "html"

  set document(
    title: c.name + " — D&D 5e Character Sheet",
    author: c.player,
  )

  set text(
    font: font-sans,
    size: 7.5pt,
    fill: palette.ink,
  )

  if is-html {
    html.elem("style", "
*, *::before, *::after {
  box-sizing: border-box;
}
html, body {
  margin: 0;
  padding: 0;
  background-color: #ffffff;
  color: #121212;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
}
.card-root {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: flex-start;
  gap: 24px;
  padding: 24px 0;
  background-color: #ffffff;
  min-height: 100vh;
}
.card-page-wrapper {
  width: 533pt;
  max-width: 100%;
  background: #ffffff;
  border: none;
  box-shadow: none;
  margin: 0 auto;
}
.card-page-wrapper svg.typst-doc {
  display: block;
  width: 100%;
  height: auto;
}
@media print {
  html, body, .card-root {
    background: #ffffff !important;
    padding: 0 !important;
    gap: 0 !important;
  }
  .card-page-wrapper {
    width: 100% !important;
    max-width: none !important;
    page-break-after: always;
    break-after: page;
  }
  .card-page-wrapper:last-child {
    page-break-after: auto;
    break-after: auto;
  }
}
")
    html.elem("div", attrs: (class: "card-root"), {
      html.elem("div", attrs: (class: "card-page-wrapper"), html.frame(block(width: 533pt, render-page-one(c))))
      html.elem("div", attrs: (class: "card-page-wrapper"), html.frame(block(width: 533pt, render-page-two(c))))
      if c.spellcasting.enabled {
        html.elem("div", attrs: (class: "card-page-wrapper"), html.frame(block(width: 533pt, render-page-three(c))))
      }
    })
  } else {
    set page(
      paper: paper,
      margin: (x: 11mm, top: 10mm, bottom: 11mm),
      footer: context {
        let pg = counter(page).get().first()
        let total = counter(page).final().first()
        grid(
          columns: (1fr, auto, 1fr),
          align: (left + horizon, center + horizon, right + horizon),
          text(font: font-mono, size: 6.2pt, fill: palette.slate, "EVERMEET 5E AUTOMATED CHARACTER SHEET"),
          text(font: font-sans, size: 6.5pt, weight: "bold", fill: palette.charcoal, c.name + " (" + c.class_summary + ")"),
          text(font: font-mono, size: 6.2pt, fill: palette.slate, "PAGE " + str(pg) + " OF " + str(total)),
        )
      },
    )

    // Page 1: Core Attributes, Skills & Combat
    render-page-one(c)

    // Page 2: Features, Inventory, Encumbrance & Lore
    pagebreak()
    render-page-two(c)

    // Page 3: Spellcasting (automatically rendered when the character has spells/caster levels)
    if c.spellcasting.enabled {
      pagebreak()
      render-page-three(c)
    }
  }
}

