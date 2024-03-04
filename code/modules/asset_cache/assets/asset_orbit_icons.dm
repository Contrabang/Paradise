/// Pill sprites for UIs
/datum/asset/spritesheet/orbit_job
	name = "orbit_job"

/datum/asset/spritesheet/orbit_job/create_spritesheets()
	var/list/states = GLOB.joblist + "prisoner" + "centcom" + "solgov" + "soviet" + "unknown"
	for(var/state in states)
		Insert("hud[state]", 'icons/mob/hud/job_assets.dmi', "hud[state]")

