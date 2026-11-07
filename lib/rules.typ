// ============================================================================
// Evermeet D&D 5e Automated Rules & Calculation Engine (lib/rules.typ)
// ============================================================================
// Provides complete 5th Edition rules automation:
// - Ability modifiers & signed number formatting
// - Total character level, hit dice by class, & proficiency bonus progression
// - Saving throw & 18 canonical 5e skill calculations (proficiency, expertise,
//   Jack of All Trades, Remarkable Athlete, flat & global bonuses)
// - Passive Perception, Investigation, & Insight (including advantage/disadvantage
//   +5/-5 modifiers and Observant feat)
// - Armor Class (AC) engine supporting light/medium/heavy armor, shields,
//   Medium Armor Master, Fighting Style: Defense, and Unarmored Defense
//   (Barbarian, Monk, Draconic Resilience, Mage Armor)
// - Weapon & Spell Attack calculator (Finesse auto-selection of max(STR, DEX),
//   thrown/ranged/spell ability resolution, magic bonuses, Fighting Styles
//   like Archery & Dueling, Great Weapon Master / Sharpshooter notations)
// - Spellcasting engine: full/half/third/artificer/pact-magic multiclass
//   caster level calculation, standard 5e spell slot table (1st-9th level),
//   Warlock Pact Magic slot progression, Spell Save DC, and Spell Attack Bonus
// - Encumbrance & coin weight calculator
// ============================================================================

#let abilities-order = ("str", "dex", "con", "int", "wis", "cha")

#let ability-names = (
  str: (short: "STR", full: "Strength"),
  dex: (short: "DEX", full: "Dexterity"),
  con: (short: "CON", full: "Constitution"),
  int: (short: "INT", full: "Intelligence"),
  wis: (short: "WIS", full: "Wisdom"),
  cha: (short: "CHA", full: "Charisma"),
)

// Canonical 18 D&D 5e skills mapped to their governing ability
#let skills-catalog = (
  (id: "acrobatics",      name: "Acrobatics",      ability: "dex"),
  (id: "animal_handling", name: "Animal Handling", ability: "wis"),
  (id: "arcana",          name: "Arcana",          ability: "int"),
  (id: "athletics",       name: "Athletics",       ability: "str"),
  (id: "deception",       name: "Deception",       ability: "cha"),
  (id: "history",         name: "History",         ability: "int"),
  (id: "insight",         name: "Insight",         ability: "wis"),
  (id: "intimidation",    name: "Intimidation",    ability: "cha"),
  (id: "investigation",   name: "Investigation",   ability: "int"),
  (id: "medicine",        name: "Medicine",        ability: "wis"),
  (id: "nature",          name: "Nature",          ability: "int"),
  (id: "perception",      name: "Perception",      ability: "wis"),
  (id: "performance",     name: "Performance",     ability: "cha"),
  (id: "persuasion",      name: "Persuasion",      ability: "cha"),
  (id: "religion",        name: "Religion",        ability: "int"),
  (id: "sleight_of_hand", name: "Sleight of Hand", ability: "dex"),
  (id: "stealth",         name: "Stealth",         ability: "dex"),
  (id: "survival",        name: "Survival",        ability: "wis"),
)

// Default class metadata (Hit Die, primary saving throws, spellcaster progression)
// progression: "full" | "half" | "artificer" | "third" | "pact" | "none"
#let class-catalog = (
  barbarian: (hit_die: 12, saves: ("str", "con"), caster: "none",      spell_ability: none),
  bard:      (hit_die: 8,  saves: ("dex", "cha"), caster: "full",      spell_ability: "cha"),
  cleric:    (hit_die: 8,  saves: ("wis", "cha"), caster: "full",      spell_ability: "wis"),
  druid:     (hit_die: 8,  saves: ("int", "wis"), caster: "full",      spell_ability: "wis"),
  fighter:   (hit_die: 10, saves: ("str", "con"), caster: "none",      spell_ability: "int"), // Eldritch Knight uses "third"
  monk:      (hit_die: 8,  saves: ("str", "dex"), caster: "none",      spell_ability: "wis"),
  paladin:   (hit_die: 10, saves: ("wis", "cha"), caster: "half",      spell_ability: "cha"),
  ranger:    (hit_die: 10, saves: ("str", "dex"), caster: "half",      spell_ability: "wis"),
  rogue:     (hit_die: 8,  saves: ("dex", "int"), caster: "none",      spell_ability: "int"), // Arcane Trickster uses "third"
  sorcerer:  (hit_die: 6,  saves: ("con", "cha"), caster: "full",      spell_ability: "cha"),
  warlock:   (hit_die: 8,  saves: ("wis", "cha"), caster: "pact",      spell_ability: "cha"),
  wizard:    (hit_die: 6,  saves: ("int", "wis"), caster: "full",      spell_ability: "int"),
  artificer: (hit_die: 8,  saves: ("con", "int"), caster: "artificer", spell_ability: "int"),
)

// Standard 5e Armor Catalog
#let armor-catalog = (
  "none":             (name: "Unarmored",           category: "none",   base_ac: 10, dex_cap: none, stealth_disadv: false, min_str: 0,  weight: 0),
  padded:             (name: "Padded",              category: "light",  base_ac: 11, dex_cap: none, stealth_disadv: true,  min_str: 0,  weight: 8),
  leather:            (name: "Leather",             category: "light",  base_ac: 11, dex_cap: none, stealth_disadv: false, min_str: 0,  weight: 10),
  studded_leather:    (name: "Studded Leather",     category: "light",  base_ac: 12, dex_cap: none, stealth_disadv: false, min_str: 0,  weight: 13),
  mage_armor:         (name: "Mage Armor",          category: "spell",  base_ac: 13, dex_cap: none, stealth_disadv: false, min_str: 0,  weight: 0),
  hide:               (name: "Hide",                category: "medium", base_ac: 12, dex_cap: 2,    stealth_disadv: false, min_str: 0,  weight: 12),
  chain_shirt:        (name: "Chain Shirt",         category: "medium", base_ac: 13, dex_cap: 2,    stealth_disadv: false, min_str: 0,  weight: 20),
  scale_mail:         (name: "Scale Mail",          category: "medium", base_ac: 14, dex_cap: 2,    stealth_disadv: true,  min_str: 0,  weight: 45),
  breastplate:        (name: "Breastplate",         category: "medium", base_ac: 14, dex_cap: 2,    stealth_disadv: false, min_str: 0,  weight: 20),
  half_plate:         (name: "Half Plate",          category: "medium", base_ac: 15, dex_cap: 2,    stealth_disadv: true,  min_str: 0,  weight: 40),
  ring_mail:          (name: "Ring Mail",           category: "heavy",  base_ac: 14, dex_cap: 0,    stealth_disadv: true,  min_str: 0,  weight: 40),
  chain_mail:         (name: "Chain Mail",          category: "heavy",  base_ac: 16, dex_cap: 0,    stealth_disadv: true,  min_str: 13, weight: 55),
  splint:             (name: "Splint",              category: "heavy",  base_ac: 17, dex_cap: 0,    stealth_disadv: true,  min_str: 15, weight: 60),
  plate:              (name: "Plate",               category: "heavy",  base_ac: 18, dex_cap: 0,    stealth_disadv: true,  min_str: 15, weight: 65),
)

// Standard 5e Full/Multiclass Spell Slot Table (indexed by effective caster level 1..20)
// Each entry is an array of 9 integers for spell levels 1..9
#let standard-spell-slots = (
  (2, 0, 0, 0, 0, 0, 0, 0, 0), // Level 1
  (3, 0, 0, 0, 0, 0, 0, 0, 0), // Level 2
  (4, 2, 0, 0, 0, 0, 0, 0, 0), // Level 3
  (4, 3, 0, 0, 0, 0, 0, 0, 0), // Level 4
  (4, 3, 2, 0, 0, 0, 0, 0, 0), // Level 5
  (4, 3, 3, 0, 0, 0, 0, 0, 0), // Level 6
  (4, 3, 3, 1, 0, 0, 0, 0, 0), // Level 7
  (4, 3, 3, 2, 0, 0, 0, 0, 0), // Level 8
  (4, 3, 3, 3, 1, 0, 0, 0, 0), // Level 9
  (4, 3, 3, 3, 2, 0, 0, 0, 0), // Level 10
  (4, 3, 3, 3, 2, 1, 0, 0, 0), // Level 11
  (4, 3, 3, 3, 2, 1, 0, 0, 0), // Level 12
  (4, 3, 3, 3, 2, 1, 1, 0, 0), // Level 13
  (4, 3, 3, 3, 2, 1, 1, 0, 0), // Level 14
  (4, 3, 3, 3, 2, 1, 1, 1, 0), // Level 15
  (4, 3, 3, 3, 2, 1, 1, 1, 0), // Level 16
  (4, 3, 3, 3, 2, 1, 1, 1, 1), // Level 17
  (4, 3, 3, 3, 3, 1, 1, 1, 1), // Level 18
  (4, 3, 3, 3, 3, 2, 1, 1, 1), // Level 19
  (4, 3, 3, 3, 3, 2, 2, 1, 1), // Level 20
)

// Warlock Pact Magic table by Warlock class level (1..20)
#let warlock-pact-table = (
  (slots: 1, level: 1), // 1
  (slots: 2, level: 1), // 2
  (slots: 2, level: 2), // 3
  (slots: 2, level: 2), // 4
  (slots: 2, level: 3), // 5
  (slots: 2, level: 3), // 6
  (slots: 2, level: 4), // 7
  (slots: 2, level: 4), // 8
  (slots: 2, level: 5), // 9
  (slots: 2, level: 5), // 10
  (slots: 3, level: 5), // 11
  (slots: 3, level: 5), // 12
  (slots: 3, level: 5), // 13
  (slots: 3, level: 5), // 14
  (slots: 3, level: 5), // 15
  (slots: 3, level: 5), // 16
  (slots: 4, level: 5), // 17
  (slots: 4, level: 5), // 18
  (slots: 4, level: 5), // 19
  (slots: 4, level: 5), // 20
)

// Format an integer with an explicit sign ("+3", "+0", "-1")
#let fmt-mod(val) = {
  if val >= 0 { "+" + str(val) } else { "−" + str(calc.abs(val)) }
}

// Compute 5e ability modifier: floor((score - 10) / 2)
#let calc-ability-mod(score) = {
  calc.floor((score - 10) / 2)
}

// Compute 5e proficiency bonus from total character level: ceil(level / 4) + 1
#let calc-prof-bonus(total-level) = {
  let lvl = calc.max(1, total-level)
  calc.floor((lvl - 1) / 4) + 2
}

// Normalize classes list from character dictionary
// Supports either `classes: ((name: "Paladin", level: 6, subclass: "Oath of Devotion"), ...)`
// or single-class shorthand `class: "Paladin", level: 6, subclass: "Oath of Devotion"`
#let normalize-classes(char) = {
  if "classes" in char and type(char.classes) == array and char.classes.len() > 0 {
    char.classes.map(c => {
      let key = lower(c.at("name", default: "fighter"))
      let cat = class-catalog.at(key, default: (hit_die: 8, saves: (), caster: "none", spell_ability: none))
      let sub = lower(c.at("subclass", default: ""))
      // Auto-detect Eldritch Knight / Arcane Trickster third-casters if not explicitly specified
      let default-caster = if key in ("fighter", "rogue") and ("eldritch" in sub or "arcane" in sub) {
        "third"
      } else {
        cat.caster
      }
      (
        name: c.at("name", default: "Adventurer"),
        key: key,
        subclass: c.at("subclass", default: none),
        level: c.at("level", default: 1),
        hit_die: c.at("hit_die", default: cat.hit_die),
        caster: c.at("caster", default: default-caster),
        spell_ability: c.at("spell_ability", default: cat.spell_ability),
        saves: cat.saves,
      )
    })
  } else {
    let name = char.at("class", default: "Fighter")
    let key = lower(name)
    let cat = class-catalog.at(key, default: (hit_die: 8, saves: (), caster: "none", spell_ability: none))
    let sub = lower(char.at("subclass", default: ""))
    let default-caster = if key in ("fighter", "rogue") and ("eldritch" in sub or "arcane" in sub) {
      "third"
    } else {
      cat.caster
    }
    ((
      name: name,
      key: key,
      subclass: char.at("subclass", default: none),
      level: char.at("level", default: 1),
      hit_die: char.at("hit_die", default: cat.hit_die),
      caster: char.at("caster", default: default-caster),
      spell_ability: char.at("spell_ability", default: cat.spell_ability),
      saves: cat.saves,
    ),)
  }
}

// Normalize proficiency level into a numeric multiplier (0, 0.5, 1, 2)
// Accepts:
// - booleans (true -> 1, false -> 0)
// - numbers (0, 0.5, 1, 2)
// - strings ("none", "half", "jack", "proficient", "prof", "expertise", "expert")
#let parse-prof-multiplier(val) = {
  if val == none or val == false { 0 }
  else if val == true { 1 }
  else if type(val) == int or type(val) == float { val }
  else if type(val) == str {
    let s = lower(val)
    if s in ("expertise", "expert", "double", "2x", "2") { 2 }
    else if s in ("proficient", "prof", "1x", "1", "yes", "true") { 1 }
    else if s in ("half", "jack", "0.5", "athlete") { 0.5 }
    else { 0 }
  } else { 0 }
}

// Compute Armor Class (AC) automatically from armor configuration & abilities
#let compute-ac(char, mods) = {
  let armor-cfg = char.at("armor", default: (:))
  if type(armor-cfg) == int {
    return (
      total: armor-cfg,
      base_name: "Custom AC",
      formula: "Manual override",
      stealth_disadv: false,
      shield: false,
    )
  }

  let armor-type = lower(armor-cfg.at("type", default: "none"))
  let preset = armor-catalog.at(armor-type, default: armor-catalog.at("none"))
  let base-ac = armor-cfg.at("base_ac", default: preset.base_ac)
  let category = armor-cfg.at("category", default: preset.category)
  let dex-cap = if "dex_cap" in armor-cfg { armor-cfg.dex_cap } else { preset.dex_cap }
  let armor-bonus = armor-cfg.at("magic_bonus", default: 0)
  let has-shield = armor-cfg.at("shield", default: false)
  let shield-bonus = if has-shield { 2 + armor-cfg.at("shield_magic_bonus", default: 0) } else { 0 }
  let misc-bonus = armor-cfg.at("misc_bonus", default: 0)
  let defense-style = armor-cfg.at("fighting_style_defense", default: false)
  let medium-armor-master = armor-cfg.at("medium_armor_master", default: false)

  if category == "medium" and medium-armor-master and dex-cap == 2 {
    dex-cap = 3
  }

  let unarmored-mode = lower(armor-cfg.at("unarmored_defense", default: "none"))

  let core-ac = 10
  let formula-parts = ()

  if category == "none" and unarmored-mode != "none" {
    if unarmored-mode == "barbarian" {
      core-ac = 10 + mods.dex + mods.con
      formula-parts.push("10 + DEX (" + fmt-mod(mods.dex) + ") + CON (" + fmt-mod(mods.con) + ")")
    } else if unarmored-mode == "monk" {
      core-ac = 10 + mods.dex + mods.wis
      formula-parts.push("10 + DEX (" + fmt-mod(mods.dex) + ") + WIS (" + fmt-mod(mods.wis) + ")")
    } else if unarmored-mode == "draconic" {
      core-ac = 13 + mods.dex
      formula-parts.push("13 (Draconic) + DEX (" + fmt-mod(mods.dex) + ")")
    } else {
      core-ac = base-ac + mods.dex
      formula-parts.push(str(base-ac) + " + DEX (" + fmt-mod(mods.dex) + ")")
    }
  } else {
    let dex-contrib = if dex-cap == none {
      mods.dex
    } else if dex-cap == 0 {
      0
    } else {
      calc.min(mods.dex, dex-cap)
    }
    core-ac = base-ac + dex-contrib + armor-bonus
    formula-parts.push(str(base-ac) + " (" + armor-cfg.at("name", default: preset.name) + ")")
    if dex-cap != 0 {
      let cap-note = if dex-cap != none { ", max " + str(dex-cap) } else { "" }
      formula-parts.push(fmt-mod(dex-contrib) + " DEX" + cap-note)
    }
    if armor-bonus != 0 {
      formula-parts.push(fmt-mod(armor-bonus) + " Magic")
    }
  }

  let style-bonus = if defense-style and category in ("light", "medium", "heavy") { 1 } else { 0 }
  if has-shield {
    formula-parts.push("+" + str(shield-bonus) + " Shield")
  }
  if style-bonus != 0 {
    formula-parts.push("+1 Defense")
  }
  if misc-bonus != 0 {
    formula-parts.push(fmt-mod(misc-bonus) + " Misc")
  }

  let stealth-dis = if medium-armor-master and category == "medium" {
    false
  } else {
    armor-cfg.at("stealth_disadv", default: preset.stealth_disadv)
  }

  (
    total: core-ac + shield-bonus + style-bonus + misc-bonus,
    base_name: armor-cfg.at("name", default: preset.name),
    category: category,
    shield: has-shield,
    shield_bonus: shield-bonus,
    stealth_disadv: stealth-dis,
    formula: formula-parts.join(" "),
  )
}

// Compute Max HP (supports either explicit `hp.max` or automatic calculation from
// class hit dice, Constitution modifier, Tough feat, and Dwarven Toughness / Draconic Resilience)
#let compute-hp(char, classes, total-level, con-mod) = {
  let hp-cfg = char.at("hp", default: (:))
  let per-level-extra = (
    (if hp-cfg.at("tough_feat", default: false) { 2 } else { 0 })
    + (if hp-cfg.at("dwarven_toughness", default: false) { 1 } else { 0 })
    + (if hp-cfg.at("draconic_resilience", default: false) { 1 } else { 0 })
    + hp-cfg.at("bonus_per_level", default: 0)
  )

  let auto-max = 0
  for (idx, c) in classes.enumerate() {
    let hd = c.hit_die
    let avg-roll = calc.floor(hd / 2) + 1
    if idx == 0 {
      // First character level gets max Hit Die
      auto-max += hd + con-mod + per-level-extra
      if c.level > 1 {
        auto-max += (c.level - 1) * (avg-roll + con-mod + per-level-extra)
      }
    } else {
      auto-max += c.level * (avg-roll + con-mod + per-level-extra)
    }
  }
  auto-max += hp-cfg.at("flat_bonus", default: 0)
  auto-max = calc.max(1, auto-max)

  let max-hp = if "max" in hp-cfg and hp-cfg.max != auto and hp-cfg.max != none {
    hp-cfg.max
  } else {
    auto-max
  }

  let current-hp = hp-cfg.at("current", default: max-hp)
  let temp-hp = hp-cfg.at("temp", default: 0)

  // Group Hit Dice by die size (e.g. 6d10, 2d8)
  let hd-list = classes.map(c => (
    class: c.name,
    total: c.level,
    die: "d" + str(c.hit_die),
    spent: 0,
  ))

  let hit-dice-summary = classes.map(c => str(c.level) + "d" + str(c.hit_die)).join(" + ")

  (
    max: max-hp,
    auto_max: auto-max,
    current: current-hp,
    temp: temp-hp,
    hit_dice_summary: hit-dice-summary,
    hit_dice: hp-cfg.at("hit_dice", default: hd-list),
    death_saves: hp-cfg.at("death_saves", default: (successes: 0, failures: 0)),
  )
}

// Compute Spellcasting statistics, Save DC, Attack Bonus, and Multiclass/Pact Slot Table
#let compute-spellcasting(char, classes, mods, prof-bonus) = {
  let sc-cfg = char.at("spellcasting", default: (:))
  let enabled = sc-cfg.at("enabled", default: auto)

  // Calculate effective multiclass spellcaster level & Warlock pact level
  let full-levels = 0
  let half-levels = 0
  let third-levels = 0
  let artificer-levels = 0
  let pact-levels = 0
  let detected-ability = none
  let caster-classes = ()

  for c in classes {
    if c.caster != "none" and c.spell_ability != none and detected-ability == none {
      detected-ability = c.spell_ability
    }
    if c.caster == "full" {
      full-levels += c.level
      caster-classes.push(c)
    } else if c.caster == "half" {
      half-levels += c.level
      caster-classes.push(c)
    } else if c.caster == "artificer" {
      artificer-levels += c.level
      caster-classes.push(c)
    } else if c.caster == "third" {
      third-levels += c.level
      caster-classes.push(c)
    } else if c.caster == "pact" {
      pact-levels += c.level
      caster-classes.push(c)
    }
  }

  let non-pact-caster-count = full-levels + half-levels + third-levels + artificer-levels
  let is-multiclass-caster = caster-classes.filter(c => c.caster != "pact").len() > 1

  let effective-caster-level = if "caster_level" in sc-cfg and sc-cfg.caster_level != auto {
    sc-cfg.caster_level
  } else if is-multiclass-caster {
    // 5e Multiclass Spellcaster rules: floor(half/2) + floor(third/3) + ceil(artificer/2)
    full-levels + calc.floor(half-levels / 2) + calc.floor(third-levels / 3) + calc.ceil(artificer-levels / 2)
  } else {
    // Single spellcasting class progression
    if full-levels > 0 { full-levels }
    else if artificer-levels > 0 { calc.ceil(artificer-levels / 2) }
    else if half-levels > 0 {
      if half-levels == 1 { 0 } else { calc.ceil(half-levels / 2) }
    } else if third-levels > 0 {
      if third-levels < 3 { 0 } else { calc.ceil(third-levels / 3) }
    } else { 0 }
  }

  let has-spells = if enabled != auto {
    enabled
  } else {
    effective-caster-level > 0 or pact-levels > 0 or sc-cfg.at("spells", default: ()).len() > 0
  }

  let spell-ability = lower(sc-cfg.at("ability", default: if detected-ability != none { detected-ability } else { "int" }))
  let ability-mod = mods.at(spell-ability, default: 0)
  let dc-bonus = sc-cfg.at("dc_bonus", default: 0)
  let atk-bonus = sc-cfg.at("attack_bonus", default: dc-bonus)

  let save-dc = sc-cfg.at("save_dc", default: 8 + prof-bonus + ability-mod + dc-bonus)
  let spell-attack = sc-cfg.at("spell_attack", default: prof-bonus + ability-mod + atk-bonus)

  // Slots array (levels 1..9)
  let auto-slots = if effective-caster-level >= 1 and effective-caster-level <= 20 {
    standard-spell-slots.at(effective-caster-level - 1)
  } else {
    (0, 0, 0, 0, 0, 0, 0, 0, 0)
  }

  let custom-slots = sc-cfg.at("slots", default: auto)
  let slots-max = if custom-slots != auto and type(custom-slots) == array {
    custom-slots
  } else {
    auto-slots
  }
  let slots-used = sc-cfg.at("slots_used", default: (0, 0, 0, 0, 0, 0, 0, 0, 0))

  // Pact Magic info (if Warlock)
  let pact-info = if pact-levels >= 1 and pact-levels <= 20 {
    let pt = warlock-pact-table.at(pact-levels - 1)
    (
      active: true,
      warlock_level: pact-levels,
      slots: pt.slots,
      slot_level: pt.level,
      used: sc-cfg.at("pact_slots_used", default: 0),
    )
  } else {
    (active: false, warlock_level: 0, slots: 0, slot_level: 0, used: 0)
  }

  // Compute default prepared spell count (if applicable: ability_mod + level or half-level)
  let prepared-limit = if "prepared_limit" in sc-cfg {
    sc-cfg.prepared_limit
  } else if full-levels > 0 or half-levels > 0 or artificer-levels > 0 {
    let prep-lvl = full-levels + calc.floor(half-levels / 2) + calc.floor(artificer-levels / 2)
    calc.max(1, prep-lvl + ability-mod)
  } else {
    none
  }

  (
    enabled: has-spells,
    ability: spell-ability,
    ability_short: ability-names.at(spell-ability, default: (short: "INT")).short,
    ability_mod: ability-mod,
    caster_level: effective-caster-level,
    save_dc: save-dc,
    attack_bonus: spell-attack,
    dc_bonus: dc-bonus,
    prepared_limit: prepared-limit,
    slots_max: slots-max,
    slots_used: slots-used,
    pact: pact-info,
    cantrips: sc-cfg.at("cantrips", default: ()),
    spells: sc-cfg.at("spells", default: ()),
    notes: sc-cfg.at("notes", default: none),
  )
}

// Compute Weapon & Spell Attacks automatically
#let compute-attacks(char, mods, prof-bonus, spellcasting) = {
  let raw-attacks = char.at("attacks", default: ())
  let styles = char.at("fighting_styles", default: ()).map(s => lower(s))
  let has-archery = "archery" in styles
  let has-dueling = "dueling" in styles

  raw-attacks.map(atk => {
    let props = atk.at("properties", default: ())
    let props-lower = props.map(p => lower(p))
    let category = lower(atk.at("category", default: "melee")) // "melee" | "ranged" | "spell"
    let is-finesse = atk.at("finesse", default: false) or ("finesse" in props-lower)
    let is-ranged = category == "ranged" or atk.at("ranged", default: false)
    let is-spell = category == "spell"
    let is-two-handed = "two-handed" in props-lower or "heavy" in props-lower

    // Determine governing ability
    let abil = if "ability" in atk and atk.ability != auto {
      lower(atk.ability)
    } else if is-spell {
      spellcasting.ability
    } else if is-finesse {
      if mods.dex >= mods.str { "dex" } else { "str" }
    } else if is-ranged {
      "dex"
    } else {
      "str"
    }

    let abil-mod = mods.at(abil, default: 0)
    let proficient = atk.at("proficient", default: true)
    let magic-bonus = atk.at("magic_bonus", default: 0)
    let flat-hit = atk.at("hit_bonus", default: 0)
    let flat-dmg = atk.at("damage_bonus", default: 0)

    // Fighting styles
    let archery-bonus = if is-ranged and not is-spell and has-archery { 2 } else { 0 }
    let dueling-bonus = if category == "melee" and not is-two-handed and has-dueling and atk.at("dueling", default: true) { 2 } else { 0 }

    let to-hit = (
      abil-mod
      + (if proficient { prof-bonus } else { 0 })
      + magic-bonus
      + archery-bonus
      + flat-hit
    )

    let add-abil-to-dmg = atk.at("add_ability_to_damage", default: not is-spell)
    let dmg-mod = (
      (if add-abil-to-dmg { abil-mod } else { 0 })
      + magic-bonus
      + dueling-bonus
      + flat-dmg
    )

    let base-dice = atk.at("damage", default: "1d8")
    let dmg-formula = if dmg-mod == 0 {
      base-dice
    } else if dmg-mod > 0 {
      base-dice + " + " + str(dmg-mod)
    } else {
      base-dice + " − " + str(calc.abs(dmg-mod))
    }

    if "extra_damage" in atk and atk.extra_damage != none and atk.extra_damage != "" {
      dmg-formula += " + " + atk.extra_damage
    }

    (
      name: atk.at("name", default: "Unarmed Strike"),
      ability: upper(abil),
      proficient: proficient,
      magic_bonus: magic-bonus,
      to_hit: to-hit,
      to_hit_str: fmt-mod(to-hit),
      damage: dmg-formula,
      damage_type: atk.at("damage_type", default: "Bludgeoning"),
      range: atk.at("range", default: if is-ranged { "80/320 ft." } else { "5 ft." }),
      properties: props,
      notes: atk.at("notes", default: none),
    )
  })
}

// Compute Carrying Capacity, Equipment Weight, and Coin Totals
#let compute-inventory(char, scores) = {
  let inv = char.at("inventory", default: (:))
  let coins = inv.at("coins", default: (:))
  let cp = coins.at("cp", default: 0)
  let sp = coins.at("sp", default: 0)
  let ep = coins.at("ep", default: 0)
  let gp = coins.at("gp", default: 0)
  let pp = coins.at("pp", default: 0)

  let total-coins = cp + sp + ep + gp + pp
  let coin-weight = if inv.at("track_coin_weight", default: true) {
    calc.round(total-coins / 50.0, digits: 1)
  } else {
    0
  }
  let total-gp-value = calc.round(cp * 0.01 + sp * 0.1 + ep * 0.5 + gp + pp * 10, digits: 2)

  let items = inv.at("items", default: ()).map(item => {
    if type(item) == str {
      (name: item, qty: 1, weight: 0, equipped: true, notes: none)
    } else {
      let q = item.at("qty", default: 1)
      let w = item.at("weight", default: 0)
      (
        name: item.at("name", default: "Item"),
        qty: q,
        weight: w,
        total_weight: calc.round(q * w, digits: 2),
        equipped: item.at("equipped", default: true),
        attuned: item.at("attuned", default: false),
        notes: item.at("notes", default: none),
      )
    }
  })

  let items-weight = items.fold(0.0, (acc, it) => acc + it.at("total_weight", default: 0))
  let total-weight = calc.round(items-weight + coin-weight, digits: 1)

  let size-mult = inv.at("size_multiplier", default: 1) // 0.5 Tiny, 1 Small/Medium, 2 Large/Powerful Build
  let str-score = scores.at("str", default: 10)
  let capacity = str-score * 15 * size-mult
  let encumbered-threshold = str-score * 5 * size-mult
  let heavily-encumbered-threshold = str-score * 10 * size-mult
  let push-drag-lift = str-score * 30 * size-mult

  (
    coins: (cp: cp, sp: sp, ep: ep, gp: gp, pp: pp),
    total_coins: total-coins,
    coin_weight: coin-weight,
    total_gp_value: total-gp-value,
    items: items,
    items_weight: calc.round(items-weight, digits: 1),
    total_weight: total-weight,
    capacity: capacity,
    encumbered: encumbered-threshold,
    heavily_encumbered: heavily-encumbered-threshold,
    push_drag_lift: push-drag-lift,
    attuned_items: inv.at("attuned", default: items.filter(i => i.at("attuned", default: false)).map(i => i.name)),
    treasure: inv.at("treasure", default: ()),
  )
}

// ============================================================================
// Master Character Evaluation Function: `evaluate-character(char)`
// ============================================================================
// Takes a user-defined character dictionary and returns a rich `computed`
// dictionary containing all raw inputs AND every derived 5e statistic.
#let evaluate-character(char) = {
  let classes = normalize-classes(char)
  let total-level = classes.fold(0, (sum, c) => sum + c.level)
  let prof-bonus = char.at("proficiency_bonus", default: calc-prof-bonus(total-level))

  let class-summary = classes.map(c => {
    let sub = if c.subclass != none and c.subclass != "" { " (" + c.subclass + ")" } else { "" }
    c.name + sub + " " + str(c.level)
  }).join(" / ")

  // 1. Ability Scores & Modifiers
  let raw-abilities = char.at("abilities", default: (:))
  let scores = (:)
  let mods = (:)
  for ab in abilities-order {
    let sc = raw-abilities.at(ab, default: 10)
    scores.insert(ab, sc)
    mods.insert(ab, calc-ability-mod(sc))
  }

  // 2. Saving Throws
  // Automatically grant saving throw proficiencies from the primary (first) class
  // unless overridden, plus any additional saves listed in `char.saves`
  let save-cfg = char.at("saves", default: (:))
  let global-save-bonus = save-cfg.at("global_bonus", default: 0) // e.g. Aura of Protection or Cloak of Protection
  let primary-saves = if classes.len() > 0 { classes.at(0).saves } else { () }
  let custom-bonuses = save-cfg.at("bonuses", default: (:))

  let saves = (:)
  for ab in abilities-order {
    let explicit-prof = if type(save-cfg) == dictionary and ab in save-cfg {
      parse-prof-multiplier(save-cfg.at(ab))
    } else if type(save-cfg) == array and ab in save-cfg {
      1
    } else if ab in primary-saves {
      1
    } else {
      0
    }
    let flat = custom-bonuses.at(ab, default: 0)
    let total = mods.at(ab) + calc.floor(prof-bonus * explicit-prof) + global-save-bonus + flat
    saves.insert(ab, (
      ability: ab,
      short: ability-names.at(ab).short,
      full: ability-names.at(ab).full,
      proficient: explicit-prof >= 1,
      multiplier: explicit-prof,
      mod: total,
      mod_str: fmt-mod(total),
    ))
  }

  // 3. Skills (18 canonical skills + Jack of All Trades / Remarkable Athlete support)
  let skills-cfg = char.at("skills", default: (:))
  let jack-of-all-trades = char.at("jack_of_all_trades", default: classes.any(c => c.key == "bard" and c.level >= 2))
  let remarkable-athlete = char.at("remarkable_athlete", default: false)
  let skill-bonuses = char.at("skill_bonuses", default: (:))
  let skill-advantages = char.at("skill_advantages", default: ())

  let computed-skills = skills-catalog.map(sk => {
    let raw-mult = if sk.id in skills-cfg {
      parse-prof-multiplier(skills-cfg.at(sk.id))
    } else if sk.name in skills-cfg {
      parse-prof-multiplier(skills-cfg.at(sk.name))
    } else {
      0
    }

    let eff-mult = if raw-mult > 0 {
      raw-mult
    } else if remarkable-athlete and sk.ability in ("str", "dex", "con") {
      0.55 // Remarkable Athlete rounds up half proficiency
    } else if jack-of-all-trades {
      0.5
    } else {
      0
    }

    let prof-add = if eff-mult == 0.55 {
      calc.ceil(prof-bonus / 2)
    } else {
      calc.floor(prof-bonus * eff-mult)
    }

    let flat = skill-bonuses.at(sk.id, default: 0)
    let total = mods.at(sk.ability) + prof-add + flat
    let has-adv = sk.id in skill-advantages or sk.name in skill-advantages

    (
      id: sk.id,
      name: sk.name,
      ability: sk.ability,
      ability_short: ability-names.at(sk.ability).short,
      multiplier: eff-mult,
      proficient: raw-mult >= 1,
      expertise: raw-mult >= 2,
      half_prof: eff-mult > 0 and eff-mult < 1,
      advantage: has-adv,
      mod: total,
      mod_str: fmt-mod(total),
    )
  })

  // Helper to lookup computed skill by id
  let skill-by-id = (:)
  for sk in computed-skills {
    skill-by-id.insert(sk.id, sk)
  }

  // 4. Passive Scores (Perception, Investigation, Insight)
  // Supports Observant feat (+5 to Passive Perception & Investigation) and Advantage (+5)
  let feats-cfg = char.at("feats", default: ())
  let has-observant = char.at("observant_feat", default: false)
  let passives-cfg = char.at("passives", default: (:))
  let perc-adv = if skill-by-id.perception.advantage { 5 } else { 0 }
  let inv-adv = if skill-by-id.investigation.advantage { 5 } else { 0 }
  let ins-adv = if skill-by-id.insight.advantage { 5 } else { 0 }

  let passive-perception = passives-cfg.at(
    "perception",
    default: 10 + skill-by-id.perception.mod + perc-adv + (if has-observant { 5 } else { 0 }),
  )
  let passive-investigation = passives-cfg.at(
    "investigation",
    default: 10 + skill-by-id.investigation.mod + inv-adv + (if has-observant { 5 } else { 0 }),
  )
  let passive-insight = passives-cfg.at(
    "insight",
    default: 10 + skill-by-id.insight.mod + ins-adv,
  )

  // 5. Initiative (DEX mod + Jack of All Trades + Alert feat +5 + War Magic / Dread Ambusher / flat bonus)
  let init-cfg = char.at("initiative", default: (:))
  let alert-bonus = if char.at("alert_feat", default: false) { 5 } else { 0 }
  let jack-init = if jack-of-all-trades { calc.floor(prof-bonus / 2) } else { 0 }
  let init-bonus = if type(init-cfg) == int {
    init-cfg
  } else {
    mods.dex + alert-bonus + jack-init + init-cfg.at("bonus", default: 0)
  }

  // 6. Armor Class, HP, Spellcasting, Attacks, Inventory
  let ac = compute-ac(char, mods)
  let hp = compute-hp(char, classes, total-level, mods.con)
  let spellcasting = compute-spellcasting(char, classes, mods, prof-bonus)
  let attacks = compute-attacks(char, mods, prof-bonus, spellcasting)
  let inventory = compute-inventory(char, scores)

  (
    // Identity & Bio
    name: char.at("name", default: "Unnamed Adventurer"),
    player: char.at("player", default: "Player"),
    race: char.at("race", default: "Human"),
    background: char.at("background", default: "Outlander"),
    alignment: char.at("alignment", default: "Neutral Good"),
    xp: char.at("xp", default: "Milestone"),
    inspiration: char.at("inspiration", default: false),
    classes: classes,
    class_summary: class-summary,
    total_level: total-level,
    prof_bonus: prof-bonus,
    prof_bonus_str: fmt-mod(prof-bonus),

    // Abilities, Saves, Skills, Passives
    scores: scores,
    mods: mods,
    saves: saves,
    save_notes: save-cfg.at("notes", default: none),
    skills: computed-skills,
    passives: (
      perception: passive-perception,
      investigation: passive-investigation,
      insight: passive-insight,
    ),

    // Combat Stats
    ac: ac,
    initiative: init-bonus,
    initiative_str: fmt-mod(init-bonus),
    speed: char.at("speed", default: "30 ft."),
    senses: char.at("senses", default: "Normal"),
    defenses: char.at("defenses", default: (resistances: (), immunities: (), vulnerabilities: (), conditions: ())),
    hp: hp,
    attacks: attacks,
    combat_actions: char.at("combat_actions", default: (:)),

    // Proficiencies, Resources, Features, Inventory, Lore, Spellcasting
    proficiencies: char.at("proficiencies", default: (:)),
    resources: char.at("resources", default: ()),
    features: char.at("features", default: ()),
    inventory: inventory,
    biography: char.at("biography", default: (:)),
    spellcasting: spellcasting,
  )
}
