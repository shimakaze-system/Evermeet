// ============================================================================
// Dummy Sample 3: Thokk "Ironhide" Grimjaw — Level 5 Barbarian (Totem Warrior)
// ============================================================================
// Demonstrates:
// - Non-Spellcaster Auto-Detection: Automatically omits Page 3 (Spellcasting
//   Grimoire) and renders a tight 2-page martial sheet!
// - Barbarian Unarmored Defense (`unarmored_defense: "barbarian"`) + Shield:
//   10 + DEX (+2) + CON (+4) + Shield (+2) = AC 18 automatically!
// - Tough Feat (`tough_feat: true`) + d12 Hit Die + +4 CON modifier:
//   Level 1: 12 + 4 + 2 = 18; Levels 2-5 (4 lvls): 4 * (7 + 4 + 2) = 52 ->
//   Max HP 70 automatically derived!
// - Powerful Build (`size_multiplier: 2`) doubling carrying capacity to 540 lb
//   and Push/Drag/Lift to 1,080 lb!
// ============================================================================

#import "../lib/sheet.typ": character-sheet

#let character = (
  name: "Thokk \"Ironhide\" Grimjaw",
  player: "Dummy Sample 03",
  race: "Half-Orc",
  background: "Outlander (Tribal Marauder)",
  alignment: "Chaotic Good",
  xp: "6,500 XP",
  inspiration: false,

  class: "Barbarian",
  subclass: "Path of the Totem Warrior (Bear)",
  level: 5,

  abilities: (
    str: 18, // +4
    dex: 14, // +2
    con: 18, // +4
    int: 8,  // -1
    wis: 12, // +1
    cha: 10, // +0
  ),

  saves: (
    notes: "Danger Sense (Advantage on DEX saves vs visible effects)",
  ),

  skills: (
    athletics: "proficient",
    intimidation: "proficient",
    nature: "proficient",
    perception: "proficient",
    survival: "proficient",
  ),
  skill_advantages: ("athletics",), // While raging

  armor: (
    type: "none",
    unarmored_defense: "barbarian", // 10 + DEX (+2) + CON (+4) = 16
    shield: true,                   // +2 Shield = 18
  ),

  speed: "40 ft.",
  senses: "Darkvision 60 ft.",
  defenses: (
    resistances: ("All Damage except Psychic while Raging (Bear Totem)",),
    immunities: (),
  ),

  hp: (
    max: auto, // 18 + 4*13 = 70
    tough_feat: true,
    current: 70,
    temp: 0,
  ),

  attacks: (
    (
      name: "Greataxe of the Frost Giant +1",
      category: "melee",
      proficient: true,
      magic_bonus: 1,
      damage_bonus: 2, // +2 Rage damage
      damage: "1d12",
      damage_type: "Slashing",
      range: "5 ft.",
      properties: ("Heavy", "Two-Handed"),
      notes: "Savage Attacks (+1d12 on Crit); Reckless Attack",
    ),
    (
      name: "Handaxe (Thrown / Dual)",
      category: "melee",
      proficient: true,
      damage_bonus: 2, // +2 Rage damage in melee
      damage: "1d6",
      damage_type: "Slashing",
      range: "20/60 ft.",
      properties: ("Light", "Thrown"),
      notes: "Draws as part of attack",
    ),
    (
      name: "Heavy Javelin",
      category: "melee",
      proficient: true,
      damage: "1d6",
      damage_type: "Piercing",
      range: "30/120 ft.",
      properties: ("Thrown",),
      notes: "Long-range opener to maintain Rage",
    ),
  ),

  resources: (
    (name: "Rage (Bear Totem)", max: 3, used: 1, recharge: "Long Rest", notes: "+2 Melee Dmg, Resist All except Psychic"),
    (name: "Relentless Endurance", max: 1, used: 0, recharge: "Long Rest", notes: "Drop to 1 HP instead of 0 HP"),
  ),

  combat_actions: (
    actions: (
      "Extra Attack (2x Greataxe / Grapple / Shove)",
      "Reckless Attack (Adv. on STR melee attacks this turn)",
    ),
    bonus_actions: (
      "Enter / End Rage (1 minute, +2 melee damage, Adv. on STR checks/saves)",
    ),
    reactions: (
      "Opportunity Attack",
    ),
    special: (
      "Relentless Endurance: When reduced to 0 HP but not killed outright, drop to 1 HP instead (1/Long Rest)",
    ),
  ),

  proficiencies: (
    armor: ("Light Armor", "Medium Armor", "Shields"),
    weapons: ("Simple Weapons", "Martial Weapons"),
    tools: ("Drum (Horn of the North)", "Herbalism Kit"),
    languages: ("Common", "Orc", "Giant"),
  ),

  features: (
    (
      name: "Rage & Totem Spirit: Bear",
      source: "Barbarian 1 / 3",
      description: "Enter a rage as a bonus action (3/Long Rest). Gain Advantage on STR checks and saves, +2 damage on STR melee attacks, and resistance to all damage except psychic damage while raging.",
    ),
    (
      name: "Unarmored Defense & Fast Movement",
      source: "Barbarian 1 / 5",
      description: "While not wearing any armor, your AC equals 10 + DEX modifier (+2) + CON modifier (+4) = 16 (+2 with Shield = 18). Your speed increases by +10 ft. (to 40 ft.) while not wearing heavy armor.",
    ),
    (
      name: "Reckless Attack & Danger Sense",
      source: "Barbarian 2",
      description: "Reckless Attack: Gain advantage on melee STR attack rolls during your turn, but attack rolls against you have advantage until your next turn. Danger Sense: Advantage on DEX saves against effects you can see.",
    ),
    (
      name: "Relentless Endurance & Savage Attacks",
      source: "Half-Orc",
      description: "Relentless Endurance: Drop to 1 HP instead of 0 HP once per long rest. Savage Attacks: Roll one of the weapon's damage dice one additional time on a melee critical hit.",
    ),
    (
      name: "Tough Feat (+2 HP per Level)",
      source: "Feat",
      description: "Your hit point maximum increases by an amount equal to twice your level (+10 HP at level 5).",
    ),
  ),

  inventory: (
    coins: (cp: 90, sp: 45, ep: 0, gp: 150, pp: 0),
    track_coin_weight: true,
    size_multiplier: 2, // Powerful Build / Bear Totem carrying capacity
    items: (
      (name: "Greataxe of the Frost Giant +1", qty: 1, weight: 7, equipped: true, attuned: true),
      (name: "Iron-banded Oak Shield", qty: 1, weight: 6, equipped: true, notes: "+2 AC when wielding 1H"),
      (name: "Balanced Handaxes", qty: 2, weight: 2, equipped: true),
      (name: "Heavy Javelins", qty: 4, weight: 2, equipped: true),
      (name: "Bracers of the Bear Totem", qty: 1, weight: 1, equipped: true, notes: "Tribal totem focus"),
      (name: "Traveler's Furs, Mess Kit & 50 ft. Hemp Rope", qty: 1, weight: 18, equipped: true),
      (name: "Potion of Healing (2d4 + 2)", qty: 2, weight: 0.5, equipped: true),
    ),
  ),

  biography: (
    traits: "I place no stock in wealthy or well-mannered folk; actions and scars speak louder than titles.",
    ideals: "Kinship. My companions are my clan, and I will stand between them and any monster.",
    bonds: "I carry a carved bear tooth from the Spine of the World, sworn to avenge my fallen chieftain.",
    flaws: "There is no room for caution in a life lived to the fullest.",
    appearance: "6'7\", 280 lbs. Frost-scarred gray skin, braided dark hair, wolf-pelt mantle.",
    backstory: "Survivor of a frost giant raid in Icewind Dale who channels the indomitable spirit of the Great Bear.",
  ),
)

#character-sheet(character)
