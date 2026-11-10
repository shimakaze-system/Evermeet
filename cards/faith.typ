#import "../lib/sheet.typ": character-sheet // Use "../lib/sheet.typ" if inside examples/

#let character = (
  // 1. Identity & Class
  name: "Faith",
  player: "Your Name",
  race: "High Elf",
  background: "Sage",
  alignment: "Neutral Good",
  xp: "6,500 XP",
  inspiration: false,

  // Single class shorthand:
  class: "Wizard",
  subclass: "School of Evocation",
  level: 5,
  // (Or for multiclassing, use `classes: ((name: "Fighter", level: 2), (name: "Wizard", level: 5))`)

  // 2. Raw Ability Scores (Modifiers are auto-calculated)
  abilities: (
    str: 8,
    dex: 16,
    con: 14,
    int: 18,
    wis: 12,
    cha: 10,
  ),

  // 3. Skills ("proficient", "expertise", or "half")
  skills: (
    arcana: "expertise",
    history: "proficient",
    investigation: "proficient",
    perception: "proficient",
  ),

  // 4. Armor & Defense (Auto-calculates AC)
  // Built-in types: "none", "padded", "leather", "studded_leather", "mage_armor",
  // "hide", "chain_shirt", "scale_mail", "breastplate", "half_plate",
  // "ring_mail", "chain_mail", "splint", "plate"
  armor: (
    type: "mage_armor", // 13 + DEX (+3) = AC 16
    shield: false,
    magic_bonus: 0,
  ),

  // 5. Hit Points (`max: auto` computes 5e average HP from Hit Dice + CON)
  hp: (
    max: auto,
    current: 32,
    temp: 0,
  ),

  // 6. Attacks (Auto-calculates Hit & Damage from STR/DEX/Finesse/Spell + Prof + Magic)
  attacks: (
    (
      name: "Dagger +1",
      category: "melee",
      finesse: true, // Automatically uses max(STR, DEX) -> DEX (+3)
      proficient: true,
      magic_bonus: 1,
      damage: "1d4",
      damage_type: "Piercing",
      range: "20/60 ft.",
      properties: ("Finesse", "Light", "Thrown"),
    ),
    (
      name: "Fire Bolt",
      category: "spell", // Automatically uses spellcasting ability (INT +4)
      proficient: true,
      damage: "2d10",
      damage_type: "Fire",
      range: "120 ft.",
      properties: ("V, S",),
    ),
  ),

  // 7. Features, Inventory & Biography (Page 2)
  features: (
    (
      name: "Sculpt Spells",
      source: "Evocation 2",
      description: "Create pockets of relative safety within the effects of your evocation spells.",
    ),
  ),
  inventory: (
    coins: (cp: 0, sp: 25, ep: 0, gp: 150, pp: 2),
    items: (
      (name: "Arcane Grimoire +1", qty: 1, weight: 3, attuned: true),
      (name: "Scholar's Pack", qty: 1, weight: 10),
    ),
  ),
  biography: (
    traits: "Always taking notes in the margins of old scrolls.",
    ideals: "Knowledge. The path to power and self-improvement is through knowledge.",
    bonds: "My spellbook is my most treasured possession.",
    flaws: "I overlook obvious solutions in favor of complicated ones.",
  ),

  // 8. Spellcasting (Page 3 — omit this block for non-casters to get a 2-page sheet)
  // Save DC, Spell Attack, and 1st-9th level spell slots are calculated automatically!
  spellcasting: (
    ability: "int",
    dc_bonus: 1, // e.g., +1 from Arcane Grimoire
    cantrips: (
      (name: "Fire Bolt", time: "1 Action", range: "120 ft.", components: "V, S", notes: "2d10 Fire"),
      (name: "Mage Hand", time: "1 Action", range: "30 ft.", components: "V, S", notes: "Spectral hand"),
    ),
    spells: (
      (level: 1, name: "Mage Armor", prepared: true, time: "1 Action", range: "Touch", duration: "8 hours", attack_save: "AC 13+DEX", notes: "Base AC becomes 13 + DEX modifier"),
      (level: 1, name: "Shield", prepared: true, time: "1 Reaction", range: "Self", duration: "1 round", attack_save: "+5 AC", notes: "+5 AC until start of next turn"),
      (level: 3, name: "Fireball", prepared: true, time: "1 Action", range: "150 ft.", duration: "Instant", attack_save: "DEX Save", notes: "8d6 Fire in 20-ft. radius sphere"),
    ),
  ),
)

#character-sheet(character)
