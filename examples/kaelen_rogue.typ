// ============================================================================
// Dummy Sample 2: Kaelen Vane — Level 7 Rogue (Arcane Trickster)
// ============================================================================
// Demonstrates:
// - Single-class Third-Caster (Arcane Trickster 7 -> Effective Caster Level 3 ->
//   4 x 1st-level & 2 x 2nd-level spell slots automatically derived!)
// - Expertise (2x Proficiency Bonus) across 4 skills: Stealth (+11), Sleight of
//   Hand (+11), Thieves' Tools, Perception (+9), and Investigation (+10)
// - Observant Feat (+5 to Passive Perception -> 24, Passive Investigation -> 25)
// - Alert Feat (+5 to Initiative -> +10)
// - Studded Leather Armor (12 + DEX +5 = AC 17)
// - Finesse & Ranged Attacks auto-selecting DEX (+5)
// ============================================================================

#import "../lib/sheet.typ": character-sheet

#let character = (
  name: "Kaelen \"Whisper\" Vane",
  player: "Dummy Sample 02",
  race: "Variant Human",
  background: "Urban Bounty Hunter",
  alignment: "Chaotic Neutral",
  xp: "23,000 XP",
  inspiration: true,

  class: "Rogue",
  subclass: "Arcane Trickster",
  level: 7,

  abilities: (
    str: 10, // +0
    dex: 20, // +5
    con: 14, // +2
    int: 16, // +3
    wis: 12, // +1
    cha: 10, // +0
  ),

  // Primary class (Rogue -> DEX, INT) saves granted automatically (+8 DEX, +6 INT)
  saves: (
    notes: "Evasion (0 dmg on DEX save success, half on fail)",
  ),

  skills: (
    acrobatics: "proficient",
    deception: "proficient",
    insight: "proficient",
    investigation: "expertise",
    perception: "expertise",
    sleight_of_hand: "expertise",
    stealth: "expertise",
  ),
  skill_advantages: ("investigation",),
  observant_feat: true, // +5 Passive Perception & Investigation
  alert_feat: true,     // +5 Initiative

  armor: (
    type: "studded_leather", // Base 12 + DEX (+5) = 17
    shield: false,
    magic_bonus: 1,          // +1 Glamoured Studded Leather -> AC 18
  ),

  speed: "30 ft.",
  senses: "Darkvision 60 ft. (Goggles of Night), Passive Inv. 29",
  defenses: (
    resistances: ("Uncanny Dodge (Half damage from 1 attack/round via Reaction)",),
    immunities: (),
  ),

  hp: (
    max: auto, // 8+2 + 6*(5+2) = 52
    current: 52,
    temp: 0,
  ),

  attacks: (
    (
      name: "Rapier of Warning +1",
      category: "melee",
      finesse: true,
      proficient: true,
      magic_bonus: 1,
      damage: "1d8",
      damage_type: "Piercing",
      range: "5 ft.",
      properties: ("Finesse", "Adv. on Initiative"),
      extra_damage: "4d6 Sneak",
      notes: "Booming Blade (+1d8 Thunder on hit)",
    ),
    (
      name: "Shadow Blade (2nd-Lvl Spell)",
      category: "melee",
      finesse: true,
      proficient: true,
      damage: "2d8",
      damage_type: "Psychic",
      range: "20/60 ft.",
      properties: ("Finesse", "Light", "Thrown"),
      extra_damage: "4d6 Sneak",
      notes: "Advantage on attacks in dim light or darkness",
    ),
    (
      name: "Hand Crossbow +1",
      category: "ranged",
      proficient: true,
      magic_bonus: 1,
      damage: "1d6",
      damage_type: "Piercing",
      range: "30/120 ft.",
      properties: ("Light", "Loading"),
      extra_damage: "4d6 Sneak",
      notes: "Qualifies for Sneak Attack within 30 ft.",
    ),
  ),

  resources: (
    (name: "Spell Slots (1st Level)", max: 4, used: 1, recharge: "Long Rest", notes: "Shield / Silvery Barbs"),
    (name: "Spell Slots (2nd Level)", max: 2, used: 0, recharge: "Long Rest", notes: "Shadow Blade / Invisibility"),
  ),

  combat_actions: (
    actions: (
      "Attack + Sneak Attack (+4d6 once per turn)",
      "Cast a Spell (Booming Blade + Rapier Strike)",
      "Mage Hand Legerdemain",
    ),
    bonus_actions: (
      "Cunning Action: Dash, Disengage, or Hide",
      "Mage Hand Legerdemain (Pick lock/pocket at 30 ft.)",
      "Summon / Recall Shadow Blade",
    ),
    reactions: (
      "Uncanny Dodge (Halve attack damage)",
      "Shield (+5 AC until start of next turn)",
      "Opportunity Attack (triggers off-turn 4d6 Sneak Attack!)",
    ),
  ),

  proficiencies: (
    armor: ("Light Armor",),
    weapons: ("Simple Weapons", "Hand Crossbows", "Longswords", "Rapiers", "Shortswords"),
    tools: ("Thieves' Tools [Expertise]", "Forgery Kit", "Gaming Set (Dice)"),
    languages: ("Common", "Thieves' Cant", "Undercommon"),
  ),

  features: (
    (
      name: "Sneak Attack (4d6)",
      source: "Rogue 1",
      description: "Once per turn, deal an extra 4d6 damage to one creature you hit with an attack using a finesse or ranged weapon if you have advantage on the attack roll, or if another enemy of the target is within 5 ft. of it.",
    ),
    (
      name: "Cunning Action",
      source: "Rogue 2",
      description: "Your quick thinking and agility allow you to move and act quickly. You can take a bonus action on each of your turns in combat to take the Dash, Disengage, or Hide action.",
    ),
    (
      name: "Mage Hand Legerdemain",
      source: "Arcane Trickster 3",
      description: "Your spectral Mage Hand is invisible and can stow/retrieve objects, use thieves' tools to pick locks and disarm traps at range, and perform Sleight of Hand checks unnoticed as a Bonus Action.",
    ),
    (
      name: "Uncanny Dodge & Evasion",
      source: "Rogue 5 / Rogue 7",
      description: "Uncanny Dodge: Use your reaction to halve the attack's damage against you from an attacker you can see. Evasion: Take no damage on a successful DEX save and only half damage on a failed save.",
    ),
    (
      name: "Observant & Alert Feats",
      source: "Feats",
      description: "Observant: Read lips, +5 bonus to Passive Perception and Passive Investigation. Alert: +5 to Initiative, cannot be surprised while conscious, hidden creatures don't gain advantage against you.",
    ),
  ),

  inventory: (
    coins: (cp: 15, sp: 60, ep: 10, gp: 680, pp: 5),
    track_coin_weight: true,
    items: (
      (name: "Glamoured Studded Leather +1", qty: 1, weight: 13, equipped: true, notes: "Bonus action: illusion disguise"),
      (name: "Rapier of Warning +1", qty: 1, weight: 2, equipped: true, attuned: true),
      (name: "Hand Crossbow +1 & 40 Bolts", qty: 1, weight: 6, equipped: true),
      (name: "Masterwork Thieves' Tools", qty: 1, weight: 1, equipped: true, notes: "Expertise (+11 check)"),
      (name: "Goggles of Night", qty: 1, weight: 0.5, equipped: true, notes: "Grants 60 ft. Darkvision"),
      (name: "Cloak of Elvenkind", qty: 1, weight: 1, equipped: true, attuned: true, notes: "Adv. on Stealth; Disadv. to spot"),
      (name: "Silk Rope (50 ft.) & Grappling Hook", qty: 1, weight: 9, equipped: true),
      (name: "Vial of Basic Poison & Smoke Grenade", qty: 3, weight: 0.5, equipped: true),
    ),
  ),

  biography: (
    traits: "I always sit with my back to the wall and know every exit in a tavern within ten seconds of walking in.",
    ideals: "Precision. A clean job leaves no witnesses, no blood, and a baffled mark.",
    bonds: "I owe my mentor in the Baldur's Gate Watch a life debt for clearing my name.",
    flaws: "I can't resist testing an 'unpickable' lock or arcane ward.",
    appearance: "5'9\", lean build, dark charcoal coat shifting seamlessly into merchant attire.",
    backstory: "An inquisitive investigator and rooftop operative who blends streetcraft with stolen wizardry.",
  ),

  spellcasting: (
    ability: "int",
    slots_used: (1, 0, 0, 0, 0, 0, 0, 0, 0),
    notes: "Arcane Focus / Component Pouch",
    cantrips: (
      (name: "Mage Hand (Invisible)", time: "1 Action", range: "30 ft.", components: "V, S", notes: "Legerdemain: invisible, bonus action lockpick/pocket"),
      (name: "Booming Blade", time: "1 Action", range: "Self (5 ft.)", components: "S, M", notes: "Melee weapon attack +1d8 Thunder (+2d8 if target moves)"),
      (name: "Minor Illusion", time: "1 Action", range: "30 ft.", components: "S, M", notes: "Sound or 5-ft. cube image for 1 minute (INT DC 14)"),
    ),
    spells: (
      (level: 1, name: "Find Familiar", prepared: true, ritual: true, time: "1 Hour", range: "10 ft.", duration: "Instant", attack_save: "Summon", notes: "Owl familiar (Flyby Help action for Sneak Attack)"),
      (level: 1, name: "Shield", prepared: true, time: "1 Reaction", range: "Self", duration: "1 round", attack_save: "+5 AC", notes: "+5 AC (to AC 23) + immunity to Magic Missile"),
      (level: 1, name: "Silvery Barbs", prepared: true, time: "1 Reaction", range: "60 ft.", duration: "Instant", attack_save: "Reroll", notes: "Force enemy reroll + grant ally Advantage"),
      (level: 1, name: "Disguise Self", prepared: true, time: "1 Action", range: "Self", duration: "1 hour", attack_save: "INT 14", notes: "Illusionary appearance change"),
      (level: 2, name: "Shadow Blade", prepared: true, concentration: true, time: "1 Bonus", range: "Self", duration: "1 min", attack_save: "+8 Hit", notes: "2d8 Psychic finesse blade; Adv. in dim/darkness"),
      (level: 2, name: "Invisibility", prepared: true, concentration: true, time: "1 Action", range: "Touch", duration: "1 hour", attack_save: "Stealth", notes: "Target invisible until it attacks or casts a spell"),
    ),
  ),
)

#character-sheet(character)
