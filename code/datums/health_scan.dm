#define ADD_FATAL(text) data["fatal"] += list(list("text" = text))
// #define ADD_FATAL_COLOR(text, color) data["fatal"] += list(list("text" = text, "color" = color))
#define ADD_WARNING(text) data["warnings"] += list(list("text" = text))
// #define ADD_WARNING_COLOR(text, color) data["warnings"] += list(list("text" = text, "color" = color))
#define ADD_INFO(text) data["info"] += list(list("text" = text))
#define ADD_INFO_COLOR(text, color) data["info"] += list(list("text" = text, "color" = color))

/datum/ui_module/health_scan
	var/mob/living/carbon/human/target // todo remove this, making it work on any living thing
	var/list/hard_data
	var/has_chem_scan = FALSE

/datum/ui_module/health_scan/New(datum/_host, mob/living/new_target)
	..()
	target = new_target

/datum/ui_module/health_scan/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/ui_state/state = GLOB.default_state, datum/tgui/master_ui = null)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		if(isobserver(user))
			state = GLOB.observer_state
		ui = new(user, src, ui_key, "Healthscan", "Health Scan", 700, 600, master_ui, state = state)
		ui.open()

/datum/ui_module/health_scan/ui_data(mob/user)
	if(length(hard_data))
		return hard_data

	return update_data()

/datum/ui_module/health_scan/ui_static_data(mob/user)
	. = ..()
	// todo remove this message later
	// gets rid of getStaminaLoss/clone?
	if(length(hard_data))
		hard_data["world_time"] = world.time
		return hard_data


	return update_data()

/datum/ui_module/health_scan/proc/update_data()

	var/list/data = list()
	data["name"] = target.name

	var/oxy = target.getOxyLoss()
	if(HAS_TRAIT(target, TRAIT_FAKEDEATH))
		oxy = max(rand(1, 40), oxy, (300 - (target.getToxLoss() + target.getFireLoss() + target.getBruteLoss())))
	data["oxygen"] = oxy
	data["toxin"] = target.getToxLoss()
	data["burn"] = target.getFireLoss()
	data["brute"] = target.getBruteLoss()

	// var/status = "Dead"
	// if(!HAS_TRAIT(target, TRAIT_FAKEDEATH)) // status still shows as "Dead"
	// 	switch(target.stat == DEAD)
	// 		if(DEAD)
	// 			if(!target.ghost_can_reenter())
	// 				status = "Dead \[DNR\]"
	// 		if(CONSCIOUS)
	// 			status = "Alive"
	// 		if(UNCONSCIOUS)
	// 			status = "Unconscious"

	data["health"] = target.health
	data["maxHealth"] = target.maxHealth
	var/stat = target.stat
	if(stat == DEAD && !target.ghost_can_reenter())
		stat = DEAD + 1 // a new... unlocked level (jk, just represents dnr on the JS side)
	if(HAS_TRAIT(target, TRAIT_FAKEDEATH))
		stat = DEAD
	data["stat"] = stat
	// data["stat_word"] = status
	// data["dnr"] = target.ghost_can_reenter()
	data["bodytemp"] = target.bodytemperature - T0C
	data["bodytempF"] = (target.bodytemperature * 1.8) - 459.67
	if(target.timeofdeath && (target.stat == DEAD || (HAS_TRAIT(target, TRAIT_FAKEDEATH))))
		data["timeofdeath"] = station_time_timestamp("hh:mm:ss", target.timeofdeath)
		data["death_ticks"] = target.timeofdeath

	// list-data["localized_damage"] // todo

	// require immediate medical attention for revival
	data["fatal"] = list()
	// requires medical attention
	data["warnings"] = list()
	// less important, but still necessary data
	data["info"] = list()

	data["viruses"] = list()
	data["crit_alert"] = null
	for(var/datum/disease/D in target.viruses)
		if(D.visibility_flags & HIDDEN_SCANNER)
			continue
		var/list/virus_data = list("form" = D.form, "name" = D.name, "stage" = D.stage, "max_stages" = D.max_stages, "cure_text" = D.cure_text)
		// Snowflaking heart problems, because they are special (and common).
		if(istype(D, /datum/disease/critical))
			data["crit_alert"] = virus_data
			continue
		data["viruses"] += list(virus_data)

	if(target.undergoing_cardiac_arrest())
		var/obj/item/organ/internal/heart/heart = target.get_int_organ(/obj/item/organ/internal/heart)
		if(!heart)
			ADD_FATAL("Subject has no heart.")
		else if(!(heart.status & ORGAN_DEAD))
			ADD_FATAL("Subject's heart has stopped. Possible Cure: Electric Shock")
		else
			ADD_FATAL("Subject's heart is necrotic.")

	if(!target.get_int_organ(/obj/item/organ/internal/brain))
		ADD_FATAL("Subject has no brain.")
	else
		if(target.getBrainLoss() >= 100)
			ADD_FATAL("Subject is brain dead.")
		else if(target.getBrainLoss() >= 60)
			ADD_WARNING("Severe brain damage detected. Subject likely to have dementia.")
		else if(target.getBrainLoss() >= 10)
			ADD_INFO("Significant brain damage detected. Subject may have had a concussion.")

	var/broken_bone = FALSE
	var/internal_bleed = FALSE
	var/burn_wound = FALSE
	for(var/name in target.bodyparts_by_name)
		var/obj/item/organ/external/e = target.bodyparts_by_name[name]
		if(!e)
			continue
		var/limb = e.name
		if(e.status & ORGAN_BROKEN)
			if((e.limb_name in list("l_arm", "r_arm", "l_hand", "r_hand", "l_leg", "r_leg", "l_foot", "r_foot")) && !(e.status & ORGAN_SPLINTED))
				ADD_INFO("Unsecured fracture in subject [limb]. Splinting recommended for transport.")
			broken_bone = TRUE
		if(e.has_infected_wound())
			ADD_INFO("Infected wound detected in subject [limb]. Disinfection recommended.")
		burn_wound = burn_wound || (e.status & ORGAN_BURNT)
		internal_bleed = internal_bleed || (e.status & ORGAN_INT_BLEEDING)
	if(broken_bone)
		ADD_WARNING("Bone fractures detected. Full bodyscan required for location.")
	if(internal_bleed)
		ADD_WARNING("Internal bleeding detected. Full bodyscan required for location.")
	if(burn_wound)
		ADD_WARNING("Critical burn detected. Examine patient's body for location.")

	data["hasBlood"] = FALSE
	var/blood_id = target.get_blood_id()
	if(blood_id && !(NO_BLOOD in target.dna.species.species_traits))
		data["hasBlood"] = TRUE
		if(target.bleed_rate)
			ADD_INFO("Subject is bleeding!")
		var/blood_percent =  round((target.blood_volume / BLOOD_VOLUME_NORMAL)*100)
		var/blood_type = target.dna.blood_type
		if(blood_id != "blood")//special blood substance
			var/datum/reagent/R = GLOB.chemical_reagents_list[blood_id]
			if(R)
				blood_type = R.name
			else
				blood_type = blood_id

		data["blood_percent"] = blood_percent
		data["blood_volume"] = round(target.blood_volume)
		data["max_blood"] = target.max_blood
		data["blood_type"] = blood_type
		data["pulse"] = target.get_pulse(GETPULSE_TOOL)
		// if(target.blood_volume <= BLOOD_VOLUME_SAFE && target.blood_volume > BLOOD_VOLUME_OKAY)
		// 	ADD_WARNING("LOW blood level [blood_percent]%.")
		// 	ADD_INFO("LOW blood level [blood_percent]%, [target.blood_volume] cl, type: [blood_type]")
		// else if(target.blood_volume <= BLOOD_VOLUME_OKAY)
		// 	ADD_FATAL("CRITICAL blood level [blood_percent]%.")
		// 	ADD_INFO("CRITICAL blood level [blood_percent] %, [target.blood_volume] cl, type: [blood_type]")
		// else
		// 	ADD_INFO_COLOR("Blood level [blood_percent] %, [target.blood_volume] cl, type: [blood_type]", "grey")

	data["cyber_mods"] = list()
	for(var/obj/item/organ/internal/O in target.internal_organs)
		if(O.is_robotic())
			data["cyber_mods"] += "[O.name]"

	if(target.gene_stability < 40)
		ADD_WARNING("Subject's genes are quickly breaking down!")
	else if(target.gene_stability < 70)
		ADD_WARNING("Subject's genes are showing signs of spontaneous breakdown.")
	else if(target.gene_stability < 85)
		ADD_INFO("Subject's genes are showing minor signs of instability.")
	else
		ADD_INFO_COLOR("Subject's genes are stable.", "grey")

	if(HAS_TRAIT(target, TRAIT_HUSK))
		ADD_FATAL("Subject is husked.")
		ADD_WARNING("Subject is husked. Application of synthflesh is recommended.")

	if(target.radiation > RAD_MOB_SAFE)
		ADD_INFO_COLOR("Subject is irradiated.", "green")

	data["local_dam"] = list()
	var/list/damaged = target.get_damaged_organs(TRUE, TRUE)
	for(var/obj/item/organ/external/org in damaged)
		data["local_dam"] += list(list("name" = capitalize(org.name), "brute" = org.brute_dam, "burn" = org.burn_dam))

	data["world_time"] = world.time
	hard_data = data
	return hard_data

/datum/ui_module/health_scan/proc/register_patient(mob/living/new_target)
	target = new_target
	hard_data = null
	update_data()
	SStgui.update_uis(src)

/datum/ui_module/health_scan/human
/datum/ui_module/health_scan/cyborg

#undef ADD_WARNING
#undef ADD_INFO
