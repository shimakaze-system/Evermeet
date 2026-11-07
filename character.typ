// ============================================================================
// Evermeet D&D 5e Automated Character Sheet — Showcase Character (`character.typ`)
// ============================================================================
// Compile with:
//   typst compile character.typ character.pdf
//
// Everything on the sheet is automatically derived from the `character`
// dictionary below:
// - Total Level (6 + 2 = 8) & Proficiency Bonus (+3)
// - Ability Modifiers (+3 STR, +2 DEX, +2 CON, +0 INT, +1 WIS, +4 CHA)
// - Saving Throws (WIS & CHA proficiency from Paladin primary class + +4 global
//   bonus from Paladin Aura of Protection!)
// - All 18 Skills (Proficient, Expertise, or Half-Proficiency)
// - Passive Senses (Perception, Investigation, Insight)
// - Armor Class (Half Plate 15 + DEX capped at +2 + Shield +2 + Defense Style +1 = 20)
// - Max HP (Auto-computed from 6d10 Paladin + 2d8 Warlock + CON mod, or custom)
// - Weapon & Spell Attack Hit/Damage bonuses (including Dueling +2, Finesse,
//   Magic weapon bonuses, and Spell Attack bonus)
// - Spellcasting: Save DC (8 + 3 + 4 = 15), Spell Attack (+7), Half-Caster
//   Paladin slots (4 / 2) AND Warlock Pact Magic slots (2 x 1st-level Short Rest)
// - Carrying Capacity, Encumbrance thresholds, Gear Weight & Coin Weight
// ============================================================================

#import "lib/sheet.typ": character-sheet

#let character = (
  // --- Identity & Progression ---
  name: "Seraphina Vale",
  player: "Shimakaze",
  race: "Half-Elf (High Elf Heritage)",
  background: "Knight of the Order",
  alignment: "Lawful Good",
  xp: "34,000 XP",
  inspiration: true,

  // Supports single class OR multiclass array!
  // Total level, Hit Dice, Proficiency Bonus, Saving Throws, and Multiclass/Pact
  // Spell Slots are all derived automatically from this list.
  classes: (
    (name: "Paladin", subclass: "Oath of Devotion", level: 6),
    (name: "Warlock", subclass: "The Celestial", level: 2),
  ),

  // --- Raw Ability Scores (Modifiers are auto-computed) ---
  abilities: (
    str: 16, // +3
    dex: 14, // +2
    con: 14, // +2
    int: 10, // +0
    wis: 12, // +1
    cha: 18, // +4
  ),

  // --- Saving Throws ---
  // Primary class (Paladin -> WIS, CHA) is granted automatically.
  // `global_bonus: 4` applies Aura of Protection (+CHA mod) to all 6 saves!
  saves: (
    global_bonus: 4,
    notes: "Aura of Protection (+4 to all saves within 10 ft.); Fey Ancestry (Adv. vs Charmed)",
  ),

  // --- Skill Proficiencies ---
  // Use `true` / `"prof"` for Proficiency (1x), `"expertise"` for Expertise (2x),
  // or `"half"` for Half-Proficiency (0.5x).
  skills: (
    athletics: "proficient",
    insight: "proficient",
    intimidation: "proficient",
    perception: "expertise", // Skill Expert feat
    persuasion: "proficient",
    religion: "proficient",
  ),
  skill_advantages: (),
  observant_feat: false,
  alert_feat: false,

  // --- Armor & Defense Configuration (Auto-calculates AC = 20) ---
  armor: (
    type: "half_plate",           // Base 15 + DEX (max 2) -> 17
    shield: true,                 // +2 Shield -> 19
    fighting_style_defense: true, // +1 Fighting Style: Defense -> 20
    medium_armor_master: false,
    magic_bonus: 0,
  ),
  fighting_styles: ("defense", "dueling"),

  speed: "30 ft.",
  senses: "Darkvision 60 ft.",
  defenses: (
    resistances: ("Radiant (Celestial Resistance)",),
    immunities: ("Disease (Divine Health)", "Magical Sleep (Fey Ancestry)"),
  ),

  // --- Hit Points & Hit Dice ---
  // Leaving `max: auto` automatically computes 5e average HP:
  // Level 1 Paladin: 10 + 2 (CON) = 12
  // Levels 2-6 Paladin (5 lvls): 5 * (6 + 2) = 40
  // Levels 1-2 Warlock (2 lvls): 2 * (5 + 2) = 14
  // Total Auto Max HP = 66
  hp: (
    max: auto,
    current: 58,
    temp: 10,
    hit_dice: (
      (class: "Paladin", total: 6, die: "d10", spent: 1),
      (class: "Warlock", total: 2, die: "d8", spent: 0),
    ),
    death_saves: (successes: 0, failures: 0),
  ),

  // --- Automated Attacks & Weapons ---
  // Automatically determines governing ability (STR, DEX for Finesse/Ranged,
  // CHA for Spell/Hexblade), adds Proficiency Bonus, Magic Bonus, and Fighting
  // Styles (e.g. Dueling +2 damage on one-handed melee weapons).
  attacks: (
    (
      name: "Sunblade Longsword +1",
      category: "melee",
      finesse: true,
      proficient: true,
      magic_bonus: 1,
      damage: "1d8",
      damage_type: "Radiant",
      range: "5 ft.",
      properties: ("Versatile (1d10)", "Finesse", "Luminous"),
      notes: "+1d8 vs Undead; Dueling (+2 dmg)",
    ),
    (
      name: "Silvered Dagger",
      category: "melee",
      finesse: true,
      proficient: true,
      magic_bonus: 0,
      damage: "1d4",
      damage_type: "Piercing",
      range: "20/60 ft.",
      properties: ("Finesse", "Light", "Thrown"),
      notes: "Dueling (+2 dmg) when melee",
    ),
    (
      name: "Javelin of Lightning",
      category: "melee",
      proficient: true,
      magic_bonus: 0,
      damage: "1d6",
      damage_type: "Piercing",
      range: "30/120 ft.",
      properties: ("Thrown",),
      notes: "1/Dawn: 4d6 Lightning line (DC 13)",
    ),
    (
      name: "Eldritch Blast (Agonizing)",
      category: "spell",
      ability: "cha",
      proficient: true,
      add_ability_to_damage: true, // Agonizing Blast adds CHA mod (+4) per beam
      damage: "1d10",
      damage_type: "Force",
      range: "120 ft.",
      properties: ("2 Beams (Lvl 5+)", "V, S"),
      notes: "Repelling Blast: push 10 ft. per hit",
    ),
  ),

  // --- Class Resources & Limited-Use Pools ---
  resources: (
    (name: "Lay on Hands Pool", max: 30, used: 5, recharge: "Long Rest", notes: "5 HP cures 1 poison/disease"),
    (name: "Channel Divinity", max: 1, used: 0, recharge: "Short Rest", notes: "Sacred Weapon / Turn the Unholy"),
    (name: "Healing Light (d6s)", max: 3, used: 1, recharge: "Long Rest", notes: "Bonus Action 60 ft. (1 + Warlock lvl)"),
    (name: "Divine Sense", max: 5, used: 1, recharge: "Long Rest", notes: "1 + CHA mod uses"),
  ),

  // --- Action Economy Quick Reference ---
  combat_actions: (
    actions: (
      "Extra Attack (2x Weapon Attacks)",
      "Cast a Spell / Eldritch Blast (2 beams)",
      "Channel Divinity: Sacred Weapon (+4 to hit, 1 min)",
      "Lay on Hands (Touch, up to 30 HP)",
    ),
    bonus_actions: (
      "Healing Light (1d6–4d6 healing at 60 ft.)",
      "Divine Smite Setup / Smite Spells",
      "Sanctuary / Shield of Faith",
    ),
    reactions: (
      "Opportunity Attack",
      "Hellish Rebuke (2d10 Fire, DEX DC 15)",
    ),
    special: (
      "Divine Smite: Expend any Paladin or Pact slot on hit for +2d8 Radiant (+1d8 per slot above 1st, +1d8 vs Undead/Fiend)",
    ),
  ),

  // --- Proficiencies & Languages ---
  proficiencies: (
    armor: ("All Armor", "Shields"),
    weapons: ("Simple Weapons", "Martial Weapons"),
    tools: ("Dragonchess Set", "Calligrapher's Supplies"),
    languages: ("Common", "Elvish", "Celestial", "Sylvan"),
  ),

  // --- Page 2: Features, Traits & Feats ---
  features: (
    (
      name: "Divine Smite",
      source: "Paladin 2",
      description: "When you hit a creature with a melee weapon attack, you can expend one spell slot (including Warlock Pact Magic slots) to deal 2d8 radiant damage to the target, plus 1d8 for each spell level higher than 1st (max 5d8), and +1d8 against undead or fiends.",
    ),
    (
      name: "Aura of Protection",
      source: "Paladin 6",
      description: "Whenever you or a friendly creature within 10 feet of you must make a saving throw, the creature gains a +4 bonus to the saving throw (equal to your Charisma modifier). You must be conscious to grant this bonus.",
    ),
    (
      name: "Channel Divinity: Sacred Weapon & Turn the Unholy",
      source: "Oath of Devotion 3",
      description: "Sacred Weapon: As an action, imbue one weapon with positive energy for 1 minute, adding +4 (CHA) to attack rolls and emitting bright light 20 ft. Turn the Unholy: Fiends and undead within 30 ft. must make a WIS save (DC 15) or be turned for 1 minute.",
    ),
    (
      name: "Extra Attack & Fighting Style (Defense + Dueling)",
      source: "Paladin 5",
      description: "Attack twice whenever you take the Attack action on your turn. +1 AC while wearing armor; +2 damage rolls with a melee weapon wielded in one hand.",
    ),
    (
      name: "Healing Light",
      source: "Celestial Warlock 1",
      description: "Pool of 3d6 (1 + Warlock level). As a bonus action, heal one creature you can see within 60 feet by spending up to 4d6 at once. Recharges on a Long Rest.",
    ),
    (
      name: "Eldritch Invocations: Agonizing Blast & Repelling Blast",
      source: "Warlock 2",
      description: "Agonizing Blast: Add +4 (CHA modifier) to the damage of every Eldritch Blast beam on hit. Repelling Blast: Push a creature hit by Eldritch Blast up to 10 feet straight away from you.",
    ),
    (
      name: "Fey Ancestry & Skill Expert (+1 CHA, Perception Expertise)",
      source: "Half-Elf / Feat",
      description: "Advantage on saving throws against being charmed, and magic cannot put you to sleep. Expertise in Perception (+7 total, Passive Perception 17).",
    ),
  ),

  // --- Page 2: Inventory, Wealth & Encumbrance ---
  inventory: (
    coins: (cp: 40, sp: 85, ep: 0, gp: 420, pp: 12),
    track_coin_weight: true, // 557 coins = 11.1 lb automatically added
    size_multiplier: 1,
    items: (
      (name: "Half Plate Armor of the Silver Order", qty: 1, weight: 40, equipped: true, notes: "AC 15 + DEX (max 2)"),
      (name: "Emblazoned Steel Shield", qty: 1, weight: 6, equipped: true, notes: "Holy Symbol integrated (+2 AC)"),
      (name: "Sunblade Longsword +1", qty: 1, weight: 3, equipped: true, attuned: true, notes: "Finesse, Radiant blade"),
      (name: "Javelin of Lightning", qty: 1, weight: 2, equipped: true, attuned: false, notes: "1/day 4d6 lightning bolt"),
      (name: "Cloak of Billowing & Silver Signet Ring", qty: 1, weight: 1, equipped: true, attuned: false),
      (name: "Pearl of Power", qty: 1, weight: 0.5, equipped: true, attuned: true, notes: "Action: recover up to 3rd-lvl slot 1/day"),
      (name: "Silvered Dagger", qty: 2, weight: 1, equipped: true),
      (name: "Explorer's Pack (Bedroll, Rope, Torch, Mess Kit)", qty: 1, weight: 25, equipped: false),
      (name: "Potion of Greater Healing (4d4 + 4)", qty: 2, weight: 0.5, equipped: true),
      (name: "Reliquary of Evermeet & Prayer Book", qty: 1, weight: 3, equipped: true),
    ),
  ),

  // --- Page 2: Character Lore & Personality ---
  biography: (
    traits: "I face every planar threat with calm composure and unwavering courtesy, believing that light endures even in the deepest shadow.",
    ideals: "Compassion & Duty. Strength exists to shelter those who cannot wield a blade of their own (Lawful Good).",
    bonds: "I swore my sacred oath before the Silver Spire of Evermeet, bound to a solar emissary who rescued my company from the Shadowfell.",
    flaws: "I struggle to retreat when innocents are in danger, even when tactical withdrawal is the only rational choice.",
    appearance: "6'0\", 155 lbs. Silver-braided hair, luminous amber eyes, half-plate filigree etched with celestial constellations.",
    backstory: "Once a border outrider of the Silver Marches, Seraphina sealed a pact with the Celestial Unicorn Lurue's herald after holding a breached sanctuary for three nights.",
  ),

  // --- Page 3: Automated Spellcasting ---
  // Save DC (15), Spell Attack (+7), Paladin slots (4 x 1st, 2 x 2nd), and
  // Warlock Pact slots (2 x 1st on Short Rest) are all calculated automatically!
  spellcasting: (
    ability: "cha",
    slots_used: (1, 0, 0, 0, 0, 0, 0, 0, 0),
    pact_slots_used: 1,
    notes: "Holy Symbol on Shield + Rod Focus",
    cantrips: (
      (
        name: "Eldritch Blast",
        time: "1 Action",
        range: "120 ft.",
        components: "V, S",
        notes: "2 beams (+7 to hit, 1d10+4 Force each, push 10 ft.)",
      ),
      (
        name: "Sacred Flame",
        time: "1 Action",
        range: "60 ft.",
        components: "V, S",
        notes: "DEX Save DC 15 or 2d8 Radiant (ignores cover)",
      ),
      (
        name: "Light",
        time: "1 Action",
        range: "Touch",
        components: "V, M",
        notes: "20 ft. bright light + 20 ft. dim light for 1 hour",
      ),
      (
        name: "Thaumaturgy",
        time: "1 Action",
        range: "30 ft.",
        components: "V",
        notes: "Booming voice, tremors, flickering flames, open doors",
      ),
    ),
    spells: (
      (
        level: 1,
        name: "Bless",
        prepared: true,
        always_prepared: false,
        concentration: true,
        time: "1 Action",
        range: "30 ft.",
        duration: "1 min",
        attack_save: "Buff",
        notes: "Up to 3 allies add +1d4 to Attack Rolls and Saving Throws",
      ),
      (
        level: 1,
        name: "Protection from Evil and Good",
        prepared: true,
        always_prepared: true,
        concentration: true,
        time: "1 Action",
        range: "Touch",
        duration: "10 min",
        attack_save: "Buff",
        notes: "Oath Spell: Aberrations, Celestials, Elementals, Fey, Fiends, Undead have Disadv.",
      ),
      (
        level: 1,
        name: "Sanctuary",
        prepared: true,
        always_prepared: true,
        concentration: false,
        time: "1 Bonus",
        range: "30 ft.",
        duration: "1 min",
        attack_save: "WIS 15",
        notes: "Oath Spell: Attackers must pass WIS DC 15 save or choose a new target",
      ),
      (
        level: 1,
        name: "Shield of Faith",
        prepared: true,
        always_prepared: false,
        concentration: true,
        time: "1 Bonus",
        range: "60 ft.",
        duration: "10 min",
        attack_save: "+2 AC",
        notes: "Shimmering field grants +2 AC to target creature (raises Seraphina to AC 22)",
      ),
      (
        level: 1,
        name: "Cure Wounds",
        prepared: true,
        always_prepared: true,
        concentration: false,
        time: "1 Action",
        range: "Touch",
        duration: "Instant",
        attack_save: "Heal",
        notes: "Celestial Pact: Restore 1d8 + 4 HP (+1d8 per slot level above 1st)",
      ),
      (
        level: 1,
        name: "Guiding Bolt",
        prepared: true,
        always_prepared: true,
        concentration: false,
        time: "1 Action",
        range: "120 ft.",
        duration: "1 round",
        attack_save: "+7 Hit",
        notes: "Celestial Pact: 4d6 Radiant damage and next attack against target has Advantage",
      ),
      (
        level: 1,
        name: "Hellish Rebuke",
        prepared: true,
        always_prepared: true,
        concentration: false,
        time: "1 Reaction",
        range: "60 ft.",
        duration: "Instant",
        attack_save: "DEX 15",
        notes: "Warlock Pact: 2d10 Fire damage on reaction when damaged (half on save)",
      ),
      (
        level: 1,
        name: "Wrathful Smite",
        prepared: true,
        always_prepared: false,
        concentration: true,
        time: "1 Bonus",
        range: "Self",
        duration: "1 min",
        attack_save: "WIS 15",
        notes: "+1d6 Psychic on next hit; target Frightened on failed WIS save",
      ),
      (
        level: 2,
        name: "Lesser Restoration",
        prepared: true,
        always_prepared: true,
        concentration: false,
        time: "1 Action",
        range: "Touch",
        duration: "Instant",
        attack_save: "Cure",
        notes: "Oath Spell: End one disease or blinded, deafened, paralyzed, or poisoned condition",
      ),
      (
        level: 2,
        name: "Zone of Truth",
        prepared: true,
        always_prepared: true,
        concentration: false,
        time: "1 Action",
        range: "60 ft.",
        duration: "10 min",
        attack_save: "CHA 15",
        notes: "Oath Spell: 15-ft. radius sphere; creatures cannot speak a deliberate lie",
      ),
      (
        level: 2,
        name: "Find Steed",
        prepared: true,
        always_prepared: false,
        concentration: false,
        time: "10 min",
        range: "30 ft.",
        duration: "Instant",
        attack_save: "Summon",
        notes: "Summons celestial warhorse spirit (telepathic bond 1 mile, shared self-spells)",
      ),
      (
        level: 2,
        name: "Aid",
        prepared: true,
        always_prepared: false,
        concentration: false,
        time: "1 Action",
        range: "30 ft.",
        duration: "8 hours",
        attack_save: "Buff",
        notes: "3 allies increase Max HP and Current HP by +5 for 8 hours",
      ),
    ),
  ),
)

#character-sheet(character)
