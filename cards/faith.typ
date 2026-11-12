#import "../lib/sheet.typ": character-sheet // Use "../lib/sheet.typ" if inside examples/

#let character = (
  // 1. Identity & Class
  name: "Dúfath",
  player: "Gyara",
  race: "影灵",
  background: "失忆的旅人<银毫学院学生>",
  alignment: "混乱中立",
  xp: "300 XP",
  inspiration: false,

  // Single class shorthand:
  class: "游侠",
  subclass: "",
  level: 2,

  // 2. Raw Ability Scores (Modifiers are auto-calculated)
  // 掷骰: 17, 16, 13, 11, 10, 8 + 2024背景属性值加值 (+2 敏捷, +1 感知)
  abilities: (
    str: 8,
    dex: 16+2,
    con: 13,
    int: 11,
    wis: 17+1,
    cha: 10,
  ),

  // 3. Skills ("proficient", "expertise", or "half")
  skills: (
    stealth: "expertise",        // 隐匿：2级巧匠专精 (+8)
    perception: "proficient",    // 察觉：游侠熟练 (+6)
    survival: "proficient",      // 求生：游侠熟练 (+6)
    investigation: "proficient", // 调查：游侠熟练 (+2)
    intimidation: "proficient",  // 威吓：银毫学院学生背景 (+2)
    persuasion: "proficient",    // 游说：银毫学院学生背景 (+2)
  ),

  // 4. Armor & Defense (Auto-calculates AC)
  // 镶嵌皮甲: 12 + DEX (+4) = AC 16
  armor: (
    type: "镶钉皮甲",
    shield: false,
    magic_bonus: 0,
  ),

  // 5. Hit Points (`max: auto` computes 5e average HP from Hit Dice + CON: 10+1 + 6+1 = 18)
  hp: (
    max: 11+6,
    current: 18,
    temp: 0,
  ),

  // 6. Attacks (Auto-calculates Hit & Damage from STR/DEX/Finesse/Spell + Prof + Magic)
  attacks: (
    (
      name: "长弓<缓速 Slow>",
      category: "ranged",
      proficient: true,
      magic_bonus: 0,
      hit_bonus: 2,
      damage: "1d8",
      damage_type: "穿刺",
      range: "150/600 尺",
      properties: ("弹药", "重型", "双手", "精通：当你用这把武器命中了一个生物并造成伤害时，你可以将对方的速度减少10尺，直至你的下一回合开始。如果该生物被拥有缓速词条的武器多次命中，其速度削减量也不会因此超过10尺。"),
    ),
    (
      name: "刺剑<侵扰 Vex>",
      category: "melee",
      finesse: true,
      proficient: true,
      magic_bonus: 0,
      damage: "1d8",
      damage_type: "穿刺",
      range: "5 尺",
      properties: ("灵巧", "精通：当你用这把武器命中一个生物并对其造成伤害时，直到你的下一回合结束前，你对该生物的下一次攻击检定将具有优势。"),
    ),
  ),

  // 7. Features, Inventory & Biography (Page 2)
  features: (
    (
      name: "影灵",
      source: "影灵",
      description: "60尺黑暗视觉；具有死灵伤害抗性；为避免或结束自身魅惑状态的豁免具有优势，且魔法无法使你陷入睡眠。",
    ),
    (
      name: "鸦后祝福",
      source: "影灵",
      description: "附赠动作魔法性地传送至30尺内可见未占据空间，每长休可使用等同于熟练加值次数（2次）。3级起，传送后直到你下回合开始前对所有伤害具有抗性。",
    ),
    (
      name: "斯翠海文入门",
      source: "银毫学院学生",
      description: "施法属性为<感知>。习得2个戏法<神导术> & <恶言相加> 与1个1环法术<银光锐语>。每长休可不消耗法术位施放1次银光锐语，亦可使用你拥有的任何法术位施放。银毫法术表加入可选列表。",
    ),
    (
      name: "宿敌",
      source: "游侠 1",
      description: "你始终准备着法术<猎人印记>。你可以不消耗法术位施放它2次，完成长休后恢复所有消耗次数。",
    ),
    (
      name: "武器精通 Weapon Mastery",
      source: "游侠 1",
      description: "掌握2种武器的精通词条（长休可更换）：长弓【减速】（命中并造成伤害使目标速度减10尺至你下回合开始）；刺剑【侵扰】（命中并造成伤害使你直到下回合结束前对该目标的下次攻击检定具有优势）。",
    ),
    (
      name: "熟练探险家 Deft Explorer",
      source: "游侠 2",
      description: "精研：隐匿获得技能专精。语言学：额外掌握2门自选语言（侏儒语，龙语）。",
    ),
    (
      name: "战斗风格：箭术",
      source: "游侠 2",
      description: "你使用远程武器进行的攻击检定获得 +2 加值。",
    ),
  ),
  inventory: (
    coins: (cp: 0, sp: 0, ep: 0, gp: 50, pp: 0),
    items: (
      (name: "镶嵌皮甲", qty: 1, weight: 13),
      (name: "长弓", qty: 1, weight: 2),
      (name: "箭袋与箭矢", qty: 40, weight: 3),
      (name: "刺剑", qty: 1, weight: 2),
      (name: "材料包", qty: 1, weight: 2),
      (name: "盗贼工具", qty: 1, weight: 1),
      (name: "探索套组", qty: 1, weight: 10),
    ),
  ),
  biography: (
    traits: "Always taking notes in the margins of old scrolls.",
    ideals: "Knowledge. The path to power and self-improvement is through knowledge.",
    bonds: "My spellbook is my most treasured possession.",
    flaws: "I overlook obvious solutions in favor of complicated ones.",
  ),

  // 8. Spellcasting (Page 3)
  // 豁免 DC = 8 + 2 (熟练) + 4 (感知) = 14；法术攻击加值 = +6
  spellcasting: (
    ability: "wis",
    dc_bonus: 0,
    cantrips: (
      (name: "神导术", time: "1 动作", range: "触碰", components: "V, S", notes: "专注至多1分钟，触碰自愿生物选定1项技能，其该技能检定 +1d4"),
      (name: "恶言相加", time: "1 动作", range: "60 尺", components: "V", notes: "感知豁免，失败受 1d6 心灵伤害且下回合结束前下次攻击检定具有劣势"),
    ),
    spells: (
      (level: 1, name: "银光锐语", prepared: true, time: "1 反应", range: "60 尺", duration: "立即", attack_save: "重骰", notes: "专长常驻（每长休免费1次+可用法术位）；可见生物攻击/属性/豁免成功时强迫重骰并取低，令30尺内1生物1分钟内下次检定获优势"),
      (level: 1, name: "猎人印记", prepared: true, time: "1 附赠动作", range: "90 尺", duration: "专注 1 小时", attack_save: "自动", notes: "宿敌常驻（每长休免费2次）；攻击命中目标额外造成 1d6 力场伤害"),
      (level: 1, name: "命令术", prepared: true, time: "1 动作", range: "60 尺", duration: "立即", attack_save: "感知豁免", notes: "银毫扩展表准备；非专注硬控！下达单字口令（靠近/放下/逃跑/匍匐/立定），失败则在下一回合执行并结束回合"),
      (level: 1, name: "纠缠术", prepared: true, time: "1 动作", range: "90 尺", duration: "专注 1 分钟", attack_save: "力量豁免", notes: "20尺方形区域变为困难地形，区域内生物力量豁免失败则陷入束缚状态"),
      (level: 1, name: "神莓术", prepared: true, time: "1 动作", range: "自身", duration: "24 小时", attack_save: "治疗", notes: "创造10颗魔法浆果，以附赠动作吃下或喂食恢复 1 点生命值并提供一天所需营养"),
    ),
  ),
)

#character-sheet(character)
