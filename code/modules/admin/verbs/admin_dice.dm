/client/proc/roll_dices()
	if(!check_rights(R_EVENT))
		return

	var/sum = input("How many times should we throw?") as num
	var/side = input("Select the number of sides.") as num
	if(!side)
		side = 6
	if(!sum)
		sum = 2

	var/dice = num2text(sum) + "d" + num2text(side)

	if(alert("Do you want to inform the world about your game?", null,"Yes", "No") == "Yes")
		to_chat(world, "<h2 style=\"color:#A50400\">The dice have been rolled by Gods!</h2>")

	var/result = roll(dice)

	if(alert("Do you want to inform the world about the result?", null,"Yes", "No") == "Yes")
		to_chat(world, "<h2 style=\"color:#A50400\">Gods rolled [dice], result is [result]</h2>")

	message_admins("[key_name_admin(src)] rolled dice [dice], result is [result]", 1)
