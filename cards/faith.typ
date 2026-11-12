#import "../lib/sheet.typ": character-sheet
#import "@preview/cuti:0.2.1": show-cn-fakebold
#show: show-cn-fakebold

#set text(
  lang: "zh",
  region: "cn",
  size: 10.5pt,
  cjk-latin-spacing: auto,
)

#let character = (
  // 1. Identity & Class
  name: "Eufassië",
  player: "Gyara",
  race: "影灵",
  background: "失忆的旅人<银毫学院学生>",
  alignment: "混乱中立",
  xp: "300 XP",
  inspiration: false,

  // Single class shorthand (with Ranger rules metadata for Chinese class name):
  class: "游侠",
  subclass: "",
  level: 2,
  hit_die: 10,
  caster: "half",
  spell_ability: "wis",

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

  // 2.5 Saving Throws (游侠熟练：力量、敏捷)
  saves: (
    str: true,
    dex: true,
    notes: "对避免或结束自身魅惑状态的豁免具有优势 (影灵)",
  ),

  // 3. Skills ("proficient", "expertise", or "half")
  skills: (
    stealth: "expertise",        // 隐匿：游侠熟练 + 2级精研专精 (+8)
    perception: "proficient",    // 察觉：影灵敏锐感官熟练 (+6)
    survival: "proficient",      // 求生：游侠熟练 (+6)
    investigation: "proficient", // 调查：游侠熟练 (+2)
    intimidation: "proficient",  // 威吓：银毫学院学生背景 (+2)
    persuasion: "proficient",    // 游说：银毫学院学生背景 (+2)
  ),

  // 4. Armor & Defense (Auto-calculates AC = 12 + 4 DEX = 16)
  armor: (
    type: "studded_leather",
    name: "镶钉皮甲",
    shield: false,
    magic_bonus: 0,
  ),
  fighting_styles: ("archery",),

  speed: "30 尺",
  senses: "黑暗视觉 60 尺",
  defenses: (
    resistances: ("死灵伤害 (影灵)",),
    immunities: ("魔法睡眠 (影灵)",),
  ),

  // 5. Hit Points (1级: 10+1 = 11, 2级投骰: 5+1 = 6, 共 17)
  hp: (
    max: 11+6,
    current: 17,
    temp: 0,
    hit_dice: (
      (class: "游侠", total: 2, die: "d10", spent: 0),
    ),
    death_saves: (successes: 0, failures: 0),
  ),

  // 6. Attacks (Auto-calculates Hit & Damage from STR/DEX/Finesse/Spell + Prof + Fighting Style)
  attacks: (
    (
      name: "长弓 <缓速 Slow>",
      category: "ranged",
      proficient: true,
      magic_bonus: 0,
      damage: "1d8",
      damage_type: "穿刺",
      range: "150/600 尺",
      properties: ("弹药", "重型", "双手"),
      notes: "精通【缓速】：命中造成伤害时目标速度 -10 尺至你下回合开始",
    ),
    (
      name: "刺剑 <侵扰 Vex>",
      category: "melee",
      finesse: true,
      proficient: true,
      magic_bonus: 0,
      damage: "1d8",
      damage_type: "穿刺",
      range: "5 尺",
      properties: ("灵巧",),
      notes: "精通【侵扰】：命中造成伤害时直到你下回合结束前对其下次攻击具有优势",
    ),
  ),

  // 6.5 Class Resources, Action Economy & Proficiencies
  resources: (
    (name: "鸦后祝福 (传送)", max: 2, used: 0, recharge: "长休", notes: "附赠动作传送 30 尺 (熟练加值次数)"),
    (name: "宿敌：猎人印记", max: 2, used: 0, recharge: "长休", notes: "不消耗法术位施放"),
    (name: "斯翠海文入门：银光锐语", max: 1, used: 0, recharge: "长休", notes: "不消耗法术位施放"),
  ),

  combat_actions: (
    actions: (
      "长弓 +8 / 1d8+4",
      "刺剑 +6 / 1d8+4",
    ),
    bonus_actions: (
      "鸦后祝福 (魔法传送 30 尺)",
      "猎人印记 (专注，额外 1d6 力场伤害)",
      "神莓术浆果 (吃下或喂食恢复 1 HP)",
    ),
    reactions: (
      "借机攻击",
      "银光锐语",
    ),
    special: (
      "武器精通：长弓【缓速】；刺剑【侵扰】",
    ),
  ),

  proficiencies: (
    armor: ("轻甲", "中甲", "盾牌"),
    weapons: ("简易武器", "军用武器"),
    tools: ("盗贼工具",),
    languages: ("通用语", "精灵语", "侏儒语", "龙语"),
  ),

  // 7. Features, Inventory & Biography (Page 2)
  features: (
    (
      name: "影灵",
      source: "影灵",
      description: "60尺黑暗视觉；具有察觉技能熟练；具有死灵伤害抗性；为避免或结束自身魅惑状态的豁免具有优势，且魔法无法使你陷入睡眠。",
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
      description: "掌握2种武器的精通词条（长休可更换）：长弓【缓速】（命中并造成伤害使目标速度减10尺至你下回合开始）；刺剑【侵扰】（命中并造成伤害使你直到下回合结束前对该目标的下次攻击检定具有优势）。",
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
    track_coin_weight: true,
    items: (
      (name: "镶钉皮甲", qty: 1, weight: 13, equipped: true, notes: "AC 12 + 敏捷"),
      (name: "猫猫面具", qty: 1, weight: 0, equipped: true, notes: "你使用武器或徒手造成的伤害提高 0"),
      (name: "长弓", qty: 1, weight: 2, equipped: true, notes: "武器精通：缓速"),
      (name: "箭袋与箭矢", qty: 40, weight: 0.075, equipped: true, notes: "共 3 lb"),
      (name: "刺剑", qty: 1, weight: 2, equipped: true, notes: "武器精通：侵扰"),
      (name: "材料包", qty: 1, weight: 2, equipped: true, notes: "施法材料"),
      (name: "盗贼工具", qty: 1, weight: 1, equipped: false),
      (name: "探索套组", qty: 1, weight: 10, equipped: false),
      (name: "署名为渡鸦女王的语焉不详的密信", qty: 1, weight: 0, equipped:false, notes: "清理掉那个……。渡鸦女王")
    ),
  ),
  biography: (
    traits: "习惯在旧卷轴和笔记本的空白处记下零碎的线索，试图拼凑出遗忘的过去。",
    ideals: "求知与自由。唯有追寻真相与掌控自己的命运，才不被过往的阴影所束缚。",
    bonds: "仅有的线索是一身来源不明的服装、与一封署名鸦后的密令。",
    flaws: "对自身来历的执念有时会让Eufassië忽略眼前的危险，或是过度揣测他人的意图。",
    appearance: "影灵。苍白肤色与深邃眼眸，身着镶钉皮甲，背负长弓与用破烂不堪的带有神秘印记的布装饰的行囊。",
    backstory: "数年前，当Eufassië从无尽的黑暗中惊醒时，她没有关于自己处境的任何信息。仅有的线索是穿在身上的不知名服装、看起来就很诡异的猫猫面具、与口袋里署名渡鸦女王的一封信。处理掉那个……麻烦？什么麻烦？除了这些以外，剩下的就只有在脑海中回响的名字：Eufassië。不管怎样，首先得活下去。自称Eufassië的女孩选择成为一个猎手，去处理周围村落没法处理的大型野兽，以此赚取一点生活费用。尽管戴着猫猫面具的神秘外乡猎手短暂引起周围市镇的一点话题，但是这话题也很快就消散了。Eufassië本以为这就是她人生的路途，但是事情似乎发生了一点变化。",
  ),

  // 8. Spellcasting (Page 3)
  // 豁免 DC = 8 + 2 (熟练) + 4 (感知) = 14；法术攻击加值 = +6
  // 2级游侠半施法者：等效施法者等级 1 -> 2 个 1 环法术位
  spellcasting: (
    ability: "wis",
    dc_bonus: 0,
    prepared_limit: "3 (+2)",
    slots_used: (0, 0, 0, 0, 0, 0, 0, 0, 0),
    notes: "施法法器：材料包",
    cantrips: (
      (name: "神导术", time: "1 动作", range: "触碰", components: "V, S", concentration: true, notes: "你触碰一名自愿生物并选择一项技能。直到法术结束为止，受术生物在进行使用到所选技能的任何属性检定时，该次检定具有1d4加值。"),
      (name: "恶言相加", time: "1 动作", range: "60 尺", components: "V", attack_save: "感知豁免", notes: "你对施法距离内一名你能看见或听见的生物连珠炮式地释出一串蕴涵微妙惑控的侮辱。目标必须通过一次感知豁免，否则受到1d6点心灵伤害，且在其下一回合结束前，其进行的下一次攻击检定具有劣势。"),
    ),
    spells: (
      (level: 1, name: "银光锐语", prepared: true, always_prepared: true, time: "1 反应", range: "60 尺", duration: "立即", notes: "You magically distract the triggering creature and turn its momentary uncertainty into encouragement for another creature. The triggering creature must reroll the d20 and use the lower roll.You can then choose a different creature you can see within range (you can choose yourself). The chosen creature has advantage on the next attack roll, ability check, or saving throw it makes within 1 minute. A creature can be empowered by only one use of this spell at a time."),
      (level: 1, name: "猎人印记", prepared: true, always_prepared: true, concentration: true, time: "1 附赠动作", range: "90 尺", duration: "专注，至多 1 小时", notes: "你指定施法距离内一个你能看见的生物并以魔法标记其作为你的猎物。每当你以攻击检定命中该目标时，你对其额外造成1d6力场伤害，且每当你为寻找目标生物而进行感知（察觉或求生）检定时都具有优势，直至法术结束。如果在法术结束前目标 HP 降至 0，则你可以用附赠动作 将标记转移至施法距离内的另一个可见生物。升环施法:使用三环或四环法术位施展该法术时，其专注可以维持至多8小时。使用环阶5+的法术位施展该法术时，其专注可以维持至多 24 小时。"),
      (level: 1, name: "纠缠术", prepared: true, time: "1 动作", components: "V, S", concentration: true, 
      duration: "专注，至多1分钟",range: "90 尺", attack_save: "力量豁免", notes: "缠绕的植物在施法距离内从20尺方格区域地面中破土而出。在法术持续时间内，这片被植物覆盖的区域变为困难地形 。法术结束时，这些植物会消失。在你施展法术时，该区域内的生物（除你之外）必须成功于一次力量豁免，否则陷入束缚状态，直到法术终止。一名因此被束缚的生物可以用其动作进行一次力量（运动）检定对抗该法术的豁免DC。检定成功则成功摆脱缠绕在其身上的藤蔓并不再被其束缚。"),
      (level: 1, name: "神莓术", prepared: true, time: "1 动作", range: "自身", duration: "24 小时", attack_save: "治疗", notes: "10颗浆果出现在你手里。果子在法术持续时间内充满魔法。一名生物可以用一个附赠动作吃下一颗浆果。吃掉一颗浆果者恢复1生命值，且一枚浆果就可以满足该生物一整天的营养需求。法术结束时还没有被吃掉的浆果会消失。"),
      (level: 1, name: "动物交谈", prepared: true, ritual: true, time: "1 动作或仪式", range: "自身", components: "V, S", duration: "10 分钟", attack_save: "沟通", notes: "你在法术持续时间内获得理解野兽生物并用语言与其沟通的能力，并且你可以对它们使用交涉动作时任何技能选项都可以适用。大多数野兽在谈及和生存与伙伴无关的话题时能说的很少，但至少，一只野兽能够给你提供周遭的地点和怪物的情报，包括任何它们近一日内察觉到过的东西。"),
    ),
  ),
)

#character-sheet(character)
