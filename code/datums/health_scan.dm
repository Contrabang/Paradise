#define ADD_WARNING(text) data["warnings"] += list("text" = text)
#define ADD_INFO(text) data["info"] += list("text" = text)

/datum/health_scan
	var/mob/our_user
	var/mob/living/target
	var/list/hard_data
	var/has_chem_scan = FALSE

/datum/health_scan/New(mob/dead/observer/new_owner)
	// Todo

/datum/health_scan/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/ui_state/state = GLOB.observer_state, datum/tgui/master_ui = null)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "Healthscan", "Spawners Menu", 700, 600, master_ui, state = state) // todo rename menu
		ui.open()

/datum/health_scan/ui_data(mob/user)
	. = ..()
	var/list/data = list()
	data["time"] // todo
	data["tdelta"] = round(world.time - target.timeofdeath)
	return data

/datum/health_scan/ui_static_data(mob/user)
	. = ..()
	// todo remove this message later
	// gets rid of pulse measuring
	// gets rid of getStaminaLoss
	if(length(hard_data))
		return hard_data

	return update_data()

/datum/health_scan/proc/update_data()

	var/list/data = update_data()
	data["name"] = target.name

	var/oxy = target.getOxyLoss()
	if(HAS_TRAIT(target, TRAIT_FAKEDEATH))
		oxy = max(rand(1,40), target.getOxyLoss(), (300 - (target.getToxLoss() + target.getFireLoss() + target.getBruteLoss())))
	data["oxygen"] = OX
	data["toxin"] = target.getToxLoss()
	data["burn"] = target.getFireLoss()
	data["brute"] = target.getBruteLoss()

	var/status = "Dead"
	if(target.stat == DEAD)
		if(!target.ghost_can_reenter())
			status = "Dead \[DNR\]"
	else if(!HAS_TRAIT(H, TRAIT_FAKEDEATH)) // status still shows as "Dead"
			status = "[target.health]"

	data["health"] = target.health
	data["maxHealth"] = target.maxHealth
	var/stat = target.stat
	if(HAS_TRAIT(H, TRAIT_FAKEDEATH))
		stat = DEAD
	data["stat"] = stat
	data["dnr"] = target.ghost_can_reenter()
	data["bodytemp"]
	if(target.timeofdeath && (target.stat == DEAD || (HAS_TRAIT(target, TRAIT_FAKEDEATH))))
		data["timeofdeath"] = station_time_timestamp("hh:mm:ss", target.timeofdeath)

	list-data["localized_damage"] // todo

	// require immediate medical attention for revival
	data["warnings"] = list()
	// less important, but still necessary data
	data["info"] = list()

	data["viruses"] = list()
	for(var/datum/disease/D in target.viruses)
		if(D.visibility_flags & HIDDEN_SCANNER)
			continue
		var/list/virus_data = list("form" = D.form, "name" = D.name, "stage" = D.stage, "max_stages" = D.max_stages, "cure_text" = D.cure_text)
		// Snowflaking heart problems, because they are special (and common).
		if(istype(D, /datum/disease/critical))
			data["crit_alert"] = virus_data
			continue
		data["viruses"] += virus_data

	if(target.undergoing_cardiac_arrest())
		var/obj/item/organ/internal/heart/heart = target.get_int_organ(/obj/item/organ/internal/heart)
		if(!heart)
			ADD_WARNING("Subject has no heart.")
		if(!(heart.status & ORGAN_DEAD))
			ADD_WARNING("Subject's heart has stopped. Possible Cure: Electric Shock")
		else
			ADD_WARNING("Subject's heart is necrotic.")

	if(!target.get_int_organ(/obj/item/organ/internal/brain))
		ADD_WARNING("Subject has no brain.")
	else
		if(H.getBrainLoss() >= 100)
			ADD_WARNING("Subject is brain dead.")
		else if(H.getBrainLoss() >= 60)
			ADD_INFO("Severe brain damage detected. Subject likely to have dementia.")
		else if(H.getBrainLoss() >= 10)
			ADD_INFO("Significant brain damage detected. Subject may have had a concussion.")

	var/broken_bone = FALSE
	var/internal_bleed = FALSE
	var/burn_wound = FALSE
	for(var/name in H.bodyparts_by_name)
		var/obj/item/organ/external/e = H.bodyparts_by_name[name]
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
		ADD_INFO("Bone fractures detected. Advanced scanner required for location.")
	if(internal_bleed)
		ADD_INFO("Internal bleeding detected. Advanced scanner required for location.")
	if(burn_wound)
		ADD_INFO("Critical burn detected. Examine patient's body for location.")

	var/blood_id = H.get_blood_id()
	if(blood_id)
		if(H.bleed_rate)
			ADD_INFO("Subject is bleeding!")
		var/blood_percent =  round((H.blood_volume / BLOOD_VOLUME_NORMAL)*100)
		var/blood_type = H.dna.blood_type
		if(blood_id != "blood")//special blood substance
			var/datum/reagent/R = GLOB.chemical_reagents_list[blood_id]
			if(R)
				blood_type = R.name
			else
				blood_type = blood_id
		if(H.blood_volume <= BLOOD_VOLUME_SAFE && H.blood_volume > BLOOD_VOLUME_OKAY)
			ADD_WARNING("LOW blood level [blood_percent]%.")
			ADD_INFO("LOW blood level [blood_percent]%, [H.blood_volume] cl, type: [blood_type]")
		else if(H.blood_volume <= BLOOD_VOLUME_OKAY)
			ADD_WARNING("CRITICAL blood level [blood_percent]%.")
			ADD_INFO("CRITICAL blood level [blood_percent] %, [H.blood_volume] cl, type: [blood_type]")
		else
			ADD_INFO("Blood level [blood_percent] %, [H.blood_volume] cl, type: [blood_type]")

	data["cyber_mods"] = list()
	for(var/obj/item/organ/internal/O in H.internal_organs)
		if(O.is_robotic())
			data["cyber_mods"] += "[O.name]"

	if(H.gene_stability < 40)
		ADD_WARNING("Subject's genes are quickly breaking down!")
	else if(H.gene_stability < 70)
		ADD_WARNING("Subject's genes are showing signs of spontaneous breakdown.")
	else if(H.gene_stability < 85)
		ADD_INFO("Subject's genes are showing minor signs of instability.")
	else
		ADD_INFO("Subject's genes are stable.")

	if(HAS_TRAIT(H, TRAIT_HUSK))
		ADD_WARNING("Subject is husked.")
		ADD_INFO("Subject is husked. Application of synthflesh is recommended.")

	if(H.radiation > RAD_MOB_SAFE)
		ADD_INFO("Subject is irradiated.")

	hard_data = data
	return data

/datum/health_scan/human

/datum/health_scan/cyborg

#undef ADD_WARNING
#undef ADD_INFO
