/datum/disease/beesease
	name = "Beesease"
	form = "Infection"
	max_stages = 4
	spread_text = "On contact"
	spread_flags = CONTACT_GENERAL
	cure_text = "Sugar"
	cures = list("sugar")
	agent = "Apidae Infection"
	viable_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/human/monkey)
	desc = "If left untreated subject will regurgitate bees."
	severity = DANGEROUS

/datum/disease/beesease/stage_act()
	..()
	switch(stage)
		if(2) //also changes say, see say.dm // no it doesn't, that's horrifyingly snowflakey
			if(MAYBE)
				to_chat(affected_mob, "<span class='notice'>You taste honey in your mouth.</span>")
		if(3)
			if(MAYBE)
				to_chat(affected_mob, "<span class='notice'>Your stomach rumbles.</span>")
			if(MAYBE)
				to_chat(affected_mob, "<span class='danger'>Your stomach stings painfully.</span>")
				if(MAYBE)
					affected_mob.adjustToxLoss(2)
		if(4)
			if(MAYBE)
				affected_mob.visible_message("<span class='danger'>[affected_mob] buzzes.</span>", \
												"<span class='userdanger'>Your stomach buzzes violently!</span>")
			if(MAYBE)
				to_chat(affected_mob, "<span class='danger'>You feel something moving in your throat.</span>")
			if(MAYBE)
				affected_mob.visible_message("<span class='danger'>[affected_mob] coughs up a swarm of bees!</span>", \
													"<span class='userdanger'>You cough up a swarm of bees!</span>")
				new /mob/living/simple_animal/hostile/poison/bees(affected_mob.loc)
		//if(5)
		//Plus if you die, you explode into bees
	return
