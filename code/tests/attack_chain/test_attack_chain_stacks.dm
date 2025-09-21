/datum/game_test/room_test/attack_chain_stacks/Run()
	var/datum/test_puppeteer/player = new(src)
	player.puppet.name = "Player"
	var/datum/test_puppeteer/victim = player.spawn_puppet_nearby()
	victim.puppet.name = "Victim"

	// Taping up someone's mouth
	player.spawn_obj_in_hand(/obj/item/stack/tape_roll)
	// player.puppet.zone_selected = BODY_ZONE_PRECISE_MOUTH
	player.click_on(victim)
	// TEST_ASSERT_LAST_CHATLOG(player, "You try to tape Victim's mouth shut!")
	TEST_ASSERT(istype(victim.puppet.mask, /obj/item/clothing/mask/muzzle/tapegag))
	player.drop_held_item()

	// Healing
	var/obj/item/organ/external/chest = victim.puppet.get_organ(BODY_ZONE_CHEST)
	chest.receive_damage(10)
	TEST_ASSERT_NOTEQUAL(target.puppet.health, target.puppet.getMaxHealth(), "Victim did not recieve damage before being healed.")
	player.spawn_obj_in_hand(/obj/item/stack/medical/bruise_pack/advanced)
	TEST_ASSERT_EQUAL(target.puppet.health, target.puppet.getMaxHealth(), "Advanced trauma kit didn't heal all damage.")


