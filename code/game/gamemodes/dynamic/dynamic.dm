GLOBAL_LIST_EMPTY(dynamic_forced_rulesets)

/datum/game_mode/dynamic
	name = "Dynamic"
	config_tag = "dynamic"
	secondary_restricted_jobs = list("AI")
	required_players = 10
	var/list/forced_rulesets = list()
	var/list/datum/ruleset/rulesets = list()
	var/list/datum/ruleset/implied_rulesets = list()

/datum/game_mode/dynamic/announce()
	to_chat(world, "<b>The current game mode is - Dynamic</b>")
	var/list/possible_rulesets = list()
	for(var/datum/ruleset/ruleset as anything in subtypesof(/datum/ruleset))
		if(ruleset.ruleset_weight <= 0)
			continue
		possible_rulesets |= ruleset.name
		if(ruleset.implied_ruleset)
			possible_rulesets |= ruleset.implied_ruleset.name
	to_chat(world, "<b>Possible Rulesets:</b> [english_list(possible_rulesets)]")

/datum/game_mode/dynamic/proc/allocate_ruleset_budget()
	var/ruleset_budget = text2num(GLOB.dynamic_forced_rulesets["budget"] || pickweight(list("0" = 3, "1" = 5, "2" = 12, "3" = 3))) // more likely to or 2
	log_dynamic("Allocated gamemode budget: [ruleset_budget]")
	var/list/possible_rulesets = list()
	for(var/datum/ruleset/ruleset as anything in subtypesof(/datum/ruleset))
		if(ruleset.ruleset_weight <= 0)
			continue
		if(GLOB.dynamic_forced_rulesets[ruleset] == DYNAMIC_RULESET_BANNED)
			continue
		var/datum/ruleset/new_ruleset = new ruleset()
		possible_rulesets[new_ruleset] = new_ruleset.ruleset_weight

	log_dynamic("Available rulesets: [english_list(possible_rulesets)]")

	for(var/datum/ruleset/ruleset as anything in GLOB.dynamic_forced_rulesets)
		if(ruleset == "budget")
			continue
		if(GLOB.dynamic_forced_rulesets[ruleset] != DYNAMIC_RULESET_FORCED)
			continue
		if(!ispath(ruleset, /datum/ruleset))
			stack_trace("Non-ruleset in GLOB.dynamic_forced_rulesets: \"[ruleset]\" ([ruleset?.type])")
			continue
		log_dynamic("Forcing ruleset: [ruleset.name]")
		ruleset_budget -= pick_ruleset(new ruleset, ruleset_budget, force = TRUE)
		for(var/datum/ruleset/old_ruleset in possible_rulesets)
			if(old_ruleset.type == ruleset)
				possible_rulesets -= old_ruleset
				qdel(old_ruleset)

	while(ruleset_budget >= 0)
		var/datum/ruleset/ruleset = pickweight(possible_rulesets)
		if(!ruleset)
			log_dynamic("No more available rulesets")
			return
		ruleset_budget -= pick_ruleset(ruleset, ruleset_budget)
		possible_rulesets -= ruleset
		qdel(ruleset)
	log_dynamic("No more ruleset budget")

/datum/game_mode/dynamic/proc/pick_ruleset(datum/ruleset/ruleset, ruleset_budget, force)
	if(!ruleset)
		return
	if(!force)
		var/failure_reason = ruleset.ruleset_possible(ruleset_budget, rulesets)
		if(failure_reason)
			log_dynamic("Failed [ruleset.name] ruleset: [failure_reason]")
			return
		log_dynamic("Rolled ruleset: [ruleset.name]")
	rulesets[ruleset] = ruleset.weight
	. = ruleset.ruleset_cost // return the ruleset cost to be subtracted from the gamemode budget
	if(!ruleset.implied_ruleset)
		return

	var/datum/ruleset/implied/implied = locate(ruleset.implied_ruleset) in implied_rulesets
	if(!implied)
		log_dynamic("Adding implied ruleset: [ruleset.implied_ruleset.name]")
		implied = new ruleset.implied_ruleset
		implied_rulesets += implied
	implied.RegisterSignal(ruleset, implied.target_signal, TYPE_PROC_REF(/datum/ruleset/implied, handle_signal))
	// ruleset.RegisterSignal(implied, implied.target_signal, TYPE_PROC_REF(/datum/ruleset/implied, handle_signal)) // ctodo remove this line?

/datum/game_mode/dynamic/proc/allocate_antagonist_budget()
	if(!length(rulesets))
		log_dynamic("No rulesets in play.")
		return
	var/budget = num_players()
	log_dynamic("Allocated antagonist budget: [budget].")

	for(var/datum/ruleset/ruleset in rulesets)
		ruleset.antag_amount = 1
		budget -= ruleset.cost
		log_dynamic("Automatic deduction: +1 [ruleset.name]. Remaining budget: [budget].")

	log_dynamic("Rulesets in play: [english_list((rulesets + implied_rulesets))]")

	apply_antag_budget(budget)

/datum/game_mode/dynamic/proc/apply_antag_budget(budget) // ctodo, can be called later in the game to apply more budget. That also means there has to be shit done for latejoins.
	var/list/temp_rulesets = rulesets.Copy()
	while(budget >= 0)
		var/datum/ruleset/ruleset = pickweight(temp_rulesets)
		if(!ruleset)
			log_dynamic("No rulesets remaining. Remaining budget: [budget].")
			return
		if(!ruleset.antagonist_possible(budget))
			log_dynamic("Rolled [ruleset.name]: failed, removing [ruleset.name] ruleset.")
			temp_rulesets -= ruleset
			continue
		log_dynamic("Rolled [ruleset.name]: success, +1 [ruleset.name]. Remaining budget: [budget].")
		ruleset.antag_amount++
		budget -= ruleset.cost
	log_dynamic("No more antagonist budget remaining.")

/datum/game_mode/dynamic/pre_setup()
	var/watch = start_watch()
	log_dynamic("Starting dynamic setup.")
	allocate_ruleset_budget()
	log_dynamic("-=-=-=-=-=-=-=-=-=-=-=-=-")
	allocate_antagonist_budget()
	log_dynamic("=-=-=-=-=-=-=-=-=-=-=-=-=")
	var/budget_overflow = 0
	for(var/datum/ruleset/ruleset in (rulesets + implied_rulesets)) // rulesets first, then implied rulesets
		log_dynamic("Applying [ruleset.antag_amount] [ruleset.name]\s.")
		budget_overflow += ruleset.pre_setup()

	log_dynamic("Budget overflow: [budget_overflow].")
	// for the future, maybe try readding antagonists with apply_antag_budget(budget_overflow)
	log_dynamic("Finished dynamic setup in [stop_watch(watch)]s")
	return TRUE

/datum/game_mode/dynamic/post_setup()
	for(var/datum/ruleset/ruleset in (rulesets + implied_rulesets))
		if(length(ruleset.pre_antags))
			log_dynamic("Making antag datums for [ruleset.name] ruleset.")
		ruleset.post_setup()
	..()

// /datum/game_mode/dynamic/traitors_to_add()
// should probably implement this in some form
