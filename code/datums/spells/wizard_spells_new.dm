#define SCHOOL_ABJURATION "abjuration" // mostly protective, barriers, removing curses, antimagic, banishing
#define SCHOOL_CONJURATION "conjuration" // teleportation / summoning
#define SCHOOL_DIVINATION "divination" // reveal information
#define SCHOOL_ENCHANTMENT "enchantment" // affects the minds of others (mindslaving)
#define SCHOOL_EVOCATION "evocation" // magical energy
#define SCHOOL_ILLUSION "illusion" // causes illusions, hallucinations, etc
#define SCHOOL_NECROMANCY "necromancy" // control life and death, can grant temp hitpoints
#define SCHOOL_TRANSMUTATION "transmutation" // change the properties of beings/objects

#define SLOT_BEHAVIOR_INSTANT 0
#define SLOT_BEHAVIOR_HOLD 1
#define SLOT_BEHAVIOR_CONSUME 2

#define CAST_SELF 0
#define CAST_TOUCH 1
#define CAST_VISION 2
#define CAST_RAY 3
#define CAST_PASSIVE 4
#define CAST_CUSTOM 5

/datum/spell/wizard
	var/school
	var/spell_level
	var/upcastable = FALSE
	/// Requires concentration, can only use one concentration spell at a time
	var/concentration = FALSE
	/// Don't recharge the spell slot while this spell is active, is it consumed?
	var/slot_behavior = SLOT_BEHAVIOR_INSTANT

	var/cast_type

/datum/spell/wizard/proc/upcast()

/**
 * MARK: ABJURATION
 */


/datum/spell/wizard/sanctuary
	name = "Sanctuary"
	desc = "You cannot be hurt, but you also can't cast other spells or hurt other people."
	school = SCHOOL_ABJURATION
	spell_level = 1
	cast_type = CAST_SELF
	concentration = TRUE

/datum/spell/wizard/mage_shield
	name = "Mage Shield"
	desc = "Gain a temporary body-wide shield, blocking up to 3 attacks."
	school = SCHOOL_ABJURATION
	spell_level = 2
	cast_type = CAST_TOUCH
	slot_behavior = SLOT_BEHAVIOR_HOLD

/datum/spell/wizard/counterspell
	name = "Counterspell"
	desc = "The next spell cast on you will be cast upon the spell's caster."
	school = SCHOOL_ABJURATION
	spell_level = 2
	cast_type = CAST_TOUCH
	slot_behavior = SLOT_BEHAVIOR_HOLD

/datum/spell/wizard/lesser_restoration
	name = "Lesser Restoration"
	desc = "Cures a creature of a disease or a negative condition affecting them."
	school = SCHOOL_ABJURATION
	spell_level = 2
	cast_type = CAST_TOUCH

/datum/spell/wizard/remove_curse
	name = "Remove Curse"
	desc = "Frees a creature or item of its curse, including spells of binding."
	school = SCHOOL_ABJURATION
	spell_level = 3
	cast_type = CAST_TOUCH

/datum/spell/wizard/resistance
	name = "Resistance"
	desc = "The target gains damage resistance against a damage type of your choice for a short time."
	school = SCHOOL_ABJURATION
	spell_level = 4
	cast_type = CAST_TOUCH
	slot_behavior = SLOT_BEHAVIOR_HOLD

/datum/spell/wizard/restoration
	name = "Restoration"
	desc = "Cures a creature of all negative dieases and conditions."
	school = SCHOOL_ABJURATION
	spell_level = 4
	cast_type = CAST_TOUCH

/datum/spell/wizard/stabilize
	name = "Stabilize"
	desc = "The next time the target creature falls asleep, they instead wake up and are forced to stand up"
	school = SCHOOL_ABJURATION
	spell_level = 4
	cast_type = CAST_TOUCH
	slot_behavior = SLOT_BEHAVIOR_HOLD

/datum/spell/wizard/banishment
	name = "Banishment"
	desc = "Banish a target to another dimension of your choice."
	school = SCHOOL_ABJURATION
	spell_level = 5
	cast_type = CAST_VISION
	concentration = TRUE

/datum/spell/wizard/resurrection
	name = "Resurrection"
	desc = "The first time you would die, you are revived and transported to a demiplane."
	school = SCHOOL_ABJURATION
	spell_level = 6
	cast_type = CAST_SELF
	slot_behavior = SLOT_BEHAVIOR_CONSUME

/**
 * MARK: CONJURATION
 */

/datum/spell/wizard/summon_item
	name = "Summon Item"
	// already exists in game
	school = SCHOOL_CONJURATION
	spell_level = 1

/datum/spell/wizard/blink
	name = "Blink"
	// already exists in game
	school = SCHOOL_CONJURATION
	spell_level = 1

/datum/spell/wizard/teleport
	name = "Teleport"
	// already exists in game
	school = SCHOOL_CONJURATION
	spell_level = 2

/datum/spell/wizard/arcane_step
	name = "Arcane Step"
	desc = "Instantly teleport to a location in your vision."
	school = SCHOOL_CONJURATION
	spell_level = 3

/datum/spell/wizard/jaunt
	name = "Jaunt"
	// already exists in game
	school = SCHOOL_CONJURATION
	spell_level = 3

/datum/spell/wizard/weapon
	name = "Conjure Lesser Weapon"
	desc = "Summon a weapon or equipment of weak magical significance."
	school = SCHOOL_CONJURATION
	spell_level = 3
	slot_behavior = SLOT_BEHAVIOR_HOLD

/datum/spell/wizard/demiplane
	name = "Demiplane"
	desc = "Create a 2-way portal to a small custom demiplane. Lichdom will not return you to this demiplane."
	school = SCHOOL_CONJURATION
	spell_level = 4

/datum/spell/wizard/spacetime_distortion
	name = "Spacetime Distortion"
	// already exists in game
	school = SCHOOL_CONJURATION
	spell_level = 4

/datum/spell/wizard/weapon/greater
	name = "Conjure Greater Weapon"
	desc = "Summon a weapon or equipment of signicance magical significance."
	school = SCHOOL_CONJURATION
	spell_level = 5

/datum/spell/wizard/conjure/demon
	name = "Conjure Demon"
	// a replacement for the demon bottles
	school = SCHOOL_CONJURATION
	spell_level = 5
	slot_behavior = SLOT_BEHAVIOR_HOLD

/datum/spell/wizard/wish
	name = "Wish"
	desc = "Make a wish. If granted, it may have a price or leave a clue to its nature."
	school = SCHOOL_CONJURATION
	spell_level = 6
	slot_behavior = SLOT_BEHAVIOR_CONSUME

/**
 * MARK: DIVINATION
 */

/datum/spell/wizard/commune
	name = "Commune"
	desc = "Send a message to anyone you know."
	school = SCHOOL_DIVINATION
	spell_level = 1

/datum/spell/wizard/announce
	name = "Announce"
	desc = "Send a message to everyone in the same sector as you."
	school = SCHOOL_DIVINATION
	spell_level = 2

/datum/spell/wizard/mind_spike
	name = "Mind Spike"
	desc = "Impale a creature. You can recall the target's location while in the same sector. You can remember one creature at a time."
	school = SCHOOL_DIVINATION
	spell_level = 3

/datum/spell/wizard/arcane_eye
	name = "Arcane Eye"
	desc = "Create a visible magical eye that can travel through walls, allowing you to explore the station without being in danger."
	school = SCHOOL_DIVINATION
	spell_level = 3

/datum/spell/wizard/locate
	name = "Locate"
	desc = "Locate a creature/object by its name."
	school = SCHOOL_DIVINATION
	spell_level = 4

/datum/spell/wizard/scry
	name = "Scry"
	desc = "Peer into the great beyond, allowing you to communicate with ghosts and see the entire world."
	school = SCHOOL_DIVINATION
	spell_level = 5

/datum/spell/wizard/clairvoyance
	name = "Clairvoyance"
	desc = "Gain x-ray vision, and the ability to always hear the voices of the dead."
	school = SCHOOL_DIVINATION
	spell_level = 6
	slot_behavior = SLOT_BEHAVIOR_CONSUME

/**
 * MARK: ENCHANTMENT
 */

/datum/spell/wizard/wild_accord
	name = "Wild Accord"
	desc = "Calm a non-sentient creature, it will no longer attack you."
	school = SCHOOL_ENCHANTMENT
	spell_level = 1

/datum/spell/wizard/pacify
	name = "Pacify"
	desc = "Disarm a creature of their willingness to harm anyone temporarily."
	school = SCHOOL_ENCHANTMENT
	spell_level = 2

/datum/spell/wizard/slow
	name = "Slow"
	desc = "Slow a single target, they will find it difficult to run."
	school = SCHOOL_ENCHANTMENT
	spell_level = 2

/datum/spell/wizard/command
	name = "Command"
	desc = "Command a target to Approach, Flee, Drop, Grovel, or Halt for a short time."
	school = SCHOOL_ENCHANTMENT
	spell_level = 3

/datum/spell/wizard/hold_person
	name = "Hold Person"
	desc = "Imprison a target in a temporary prison of their own mind, unable to move."
	school = SCHOOL_ENCHANTMENT
	spell_level = 4

/datum/spell/wizard/enthrall
	name = "Enthrall"
	desc = "Enthrall a non-wizard, they will be charmed until dead. They will obey your orders."
	school = SCHOOL_ENCHANTMENT
	spell_level = 5
	slot_behavior = SLOT_BEHAVIOR_HOLD

/datum/spell/wizard/powerword/kill
	name = "Powerword: Kill"
	desc = "Speak a word of power, condemning a single target to instantly die."
	school = SCHOOL_ENCHANTMENT
	spell_level = 6

/**
 * MARK: EVOCATION
 */

/datum/spell/wizard/shocking_grasp
	name = "Shocking Grasp"
	desc = "Shock a target in melee, knocking them down and slightly burning them."
	school = SCHOOL_EVOCATION
	spell_level = 1

/datum/spell/wizard/cure_wounds
	name = "Cure Wounds"
	desc = "A simple spell to stop bleeding and heal minor injuries."
	school = SCHOOL_EVOCATION
	spell_level = 1

/datum/spell/wizard/charge
	name = "Charge"
	// this spell already exists
	school = SCHOOL_EVOCATION
	spell_level = 1

/datum/spell/wizard/burning_hands
	name = "Burning Hands"
	desc = "Shoot a cone of fire, igniting the very air itself."
	school = SCHOOL_EVOCATION
	spell_level = 1

/datum/spell/wizard/fireball
	name = "Fireball"
	// already exists
	school = SCHOOL_EVOCATION
	spell_level = 2

/datum/spell/wizard/magic_missle
	name = "Magic Missle"
	// already exists
	school = SCHOOL_EVOCATION
	spell_level = 2

/datum/spell/wizard/forcewall
	// already exists
	school = SCHOOL_EVOCATION
	spell_level = 3

/datum/spell/wizard/emp
	name = "Shutdown"
	// already exists
	school = SCHOOL_EVOCATION
	spell_level = 3

/datum/spell/wizard/immolate
	name = "Immolate"
	desc = "Ignite a target in magical fire that cannot be put out, only stoppable by antimagic and the target's death."
	school = SCHOOL_EVOCATION
	spell_level = 4

/datum/spell/wizard/chain_lightning
	// already exists, will need a buff
	school = SCHOOL_EVOCATION
	spell_level = 5

/datum/spell/wizard/powerword/heal
	name = "Powerword Heal"
	desc = "Speak a word of power, forcing the aether to heal the target and revive them."
	school = SCHOOL_EVOCATION
	spell_level = 6

/**
 * MARK: ILLUSION
 */

/datum/spell/wizard/fear
	name = "Fear"
	desc = "Select a target, that target will not be able to move towards you."
	school = SCHOOL_ILLUSION
	spell_level = 1

/datum/spell/wizard/smoke
	name = "Smoke"
	// already exists
	school = SCHOOL_ILLUSION
	spell_level = 1

/datum/spell/wizard/invisbility
	name = "Lesser Invisibility"
	desc = "Become significantly harder to see, this illusion will be disrupted by casting spells."
	school = SCHOOL_ILLUSION
	spell_level = 2

/datum/spell/wizard/darkness
	name = "Darkness"
	desc = "Create a cloud of magical darkness."
	school = SCHOOL_ILLUSION
	spell_level = 2

/datum/spell/wizard/pass_without_trace
	name = "Pass Without Trace"
	desc = "Silences your footsteps."
	school = SCHOOL_ILLUSION
	spell_level = 2
	slot_behavior = SLOT_BEHAVIOR_HOLD

/datum/spell/wizard/disguise_self
	// This spells already exists
	school = SCHOOL_ILLUSION
	spell_level = 4
	slot_behavior = SLOT_BEHAVIOR_HOLD

/datum/spell/wizard/invisbility/greater
	name = "Invisibility"
	desc = "Become invisible, this illusion will be disrupted by casting spells."
	school = SCHOOL_ILLUSION
	spell_level = 5
	slot_behavior = SLOT_BEHAVIOR_HOLD
	concentration = TRUE

/datum/spell/wizard/simulacrum
	name = "Simulacrum"
	desc = "Create a duplicate of yourself, their spells do not replenish. They cannot be healed. They cannot conjure items, demons, similacrums, etc."
	school = SCHOOL_ILLUSION
	spell_level = 6
	slot_behavior = SLOT_BEHAVIOR_HOLD
	concentration = TRUE


/**
 * MARK: NECROMANCY
 */

/datum/spell/wizard/vitality_veil
	name = "Vitality Veil"
	name = "Grant the target 10 temporary hit points. Can be upcasted for additional hitpoints. Does not stack."
	school = SCHOOL_NECROMANCY
	spell_level = 1
	slot_behavior = SLOT_BEHAVIOR_HOLD
	upcastable = TRUE

/datum/spell/wizard/graves_grasp
	name = "Grave's Grasp"
	desc = "Does some damage to the target, and prevents them from being healed for 1 minute."
	school = SCHOOL_NECROMANCY
	spell_level = 1

/datum/spell/wizard/corpse_explosion
	name = "Corpse explosion"
	// this spell already exists
	school = SCHOOL_NECROMANCY
	spell_level = 2

/datum/spell/wizard/dirge_the_dead
	name = "Dirge the Dead"
	desc = "Instantly kill anyone in deep crit."
	school = SCHOOL_NECROMANCY
	spell_level = 3

/datum/spell/wizard/mercy
	name = "Aether's Mercy"
	desc = "The next time the target creature falls into a critical condition, they will instead be slightly cured and healed of the condition."
	school = SCHOOL_NECROMANCY
	spell_level = 4
	slot_behavior = SLOT_BEHAVIOR_HOLD

/datum/spell/wizard/curse
	name = "Curse"
	desc = "Fire a ray of sickness. A hit target will be forced to vomit, and gain toxin damage until your concentration breaks or is cured by antimagic."
	school = SCHOOL_NECROMANCY
	spell_level = 5
	slot_behavior = SLOT_BEHAVIOR_HOLD
	concentration = TRUE

/datum/spell/wizard/bind_soul
	name = "Bind Soul"
	// this spell already exists
	school = SCHOOL_NECROMANCY
	spell_level = 5
	slot_behavior = SLOT_BEHAVIOR_CONSUME

/datum/spell/wizard/animate_dead
	// replacement for the necromantic stone, functionally the same
	school = SCHOOL_NECROMANCY
	spell_level = 6
	slot_behavior = SLOT_BEHAVIOR_HOLD


/**
 * MARK: TRANSMUTATION
 */

/datum/spell/wizard/mending
	name = "Mending"
	desc = "Repair a inanimate object of damage, including emagging."
	school = SCHOOL_TRANSMUTATION
	spell_level = 1

/datum/spell/wizard/presdigiatation
	name = "Presdigiatation"
	desc = "Clean an object, or a summon a small hand-held light."
	school = SCHOOL_TRANSMUTATION
	spell_level = 1

/datum/spell/wizard/lesser_knock
	name = "Lesser Knock"
	desc = "A short range spell, imitating the effects of a single use emag."
	school = SCHOOL_TRANSMUTATION
	spell_level = 1

/datum/spell/wizard/knock
	name = "Knock"
	// this spell already exists
	school = SCHOOL_TRANSMUTATION
	spell_level = 2

/datum/spell/wizard/magic_weapon
	name = "Imbue Magic"
	desc = "Imbue an item with magic, making it do extra damage."
	// imbues a weapon with magic, giving it extra damage
	school = SCHOOL_TRANSMUTATION
	spell_level = 2

/datum/spell/wizard/darkvision
	name = "Darkvision"
	desc = "Give the target darkvision."
	school = SCHOOL_TRANSMUTATION
	spell_level = 2
	slot_behavior = SLOT_BEHAVIOR_HOLD

/datum/spell/wizard/water_walk
	// noslip
	school = SCHOOL_TRANSMUTATION
	spell_level = 2
	slot_behavior = SLOT_BEHAVIOR_HOLD

/datum/spell/wizard/greater_knock
	// this spell already exists
	school = SCHOOL_TRANSMUTATION
	spell_level = 3

/datum/spell/wizard/fleetfoot
	// nuka cola speed
	school = SCHOOL_TRANSMUTATION
	spell_level = 3
	slot_behavior = SLOT_BEHAVIOR_HOLD

/datum/spell/wizard/polymorph
	school = SCHOOL_TRANSMUTATION
	spell_level = 4
	slot_behavior = SLOT_BEHAVIOR_HOLD

/datum/spell/wizard/rod
	school = SCHOOL_TRANSMUTATION
	spell_level = 4

/datum/spell/wizard/disintegrate
	school = SCHOOL_TRANSMUTATION
	spell_level = 5

/datum/spell/wizard/haste
	// makes you click faster
	school = SCHOOL_TRANSMUTATION
	spell_level = 5
	slot_behavior = SLOT_BEHAVIOR_HOLD

/datum/spell/wizard/manipulate_mana
	name = "Manipulate Mana"
	desc = "Change your spell slots into more available spells and visa versa"
	school = SCHOOL_TRANSMUTATION
	spell_level = 6



/**
 * MARK: MISC
 */

/datum/spell/wizard/powerword

/datum/spell/wizard/ritual



