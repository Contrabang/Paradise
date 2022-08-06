// the light switch
// can have multiple per area
// can also operate on non-loc area through "otherarea" var

/obj/machinery/light_switch
	name = "light switch"
	desc = "Low power, cost effective wireless light switch. Prone to interference."
	icon = 'icons/obj/power.dmi'
	icon_state = "light1"
	anchored = TRUE
	var/on = TRUE
	var/area/area = null
	var/otherarea = null
	//	luminosity = 1
	settagwhitelist = list("logic_id_tag")
	var/light_connect = TRUE						//Allows the switch to control lights in its associated areas. When set to FALSE, using the switch won't affect the lights.
	var/logic_id_tag = "default"					//Defines the ID tag to send logic signals to.
	var/logic_connect = FALSE						//Set this to allow the switch to send out logic signals.

/obj/machinery/light_switch/New(turf/loc, w_dir=null)
	..()
	switch(w_dir)
		if(NORTH)
			pixel_y = 25
			dir = NORTH
		if(SOUTH)
			pixel_y = -25
			dir = SOUTH
		if(EAST)
			pixel_x = 25
			dir = EAST
		if(WEST)
			pixel_x = -25
			dir = WEST
	if(SSradio)
		set_frequency(frequency)
	spawn(5)
		src.area = get_area(src)

		if(otherarea)
			src.area = locate(text2path("/area/[otherarea]"))

		if(!name)
			name = "light switch([area.name])"

		src.on = src.area.lightswitch
		update_icon(UPDATE_ICON_STATE)

/obj/machinery/light_switch/Initialize()
	..()
	set_frequency(frequency)
	name = "light switch"

/obj/machinery/light_switch/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = SSradio.add_object(src, frequency, RADIO_LOGIC)
	return

/obj/machinery/light_switch/Destroy()
	if(SSradio)
		SSradio.remove_object(src, frequency)
	radio_connection = null
	return ..()

/obj/machinery/light_switch/update_icon_state()
	if(stat & NOPOWER)
		icon_state = "light-p"
		return
	icon_state = "light[on]"

/obj/machinery/light_switch/update_overlays()
	. = ..()
	underlays.Cut()

	if(stat & NOPOWER)
		return

	underlays += emissive_appearance(icon, "light_lightmask")

/obj/machinery/light_switch/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It is turned [on ? "on" : "off"].</span>"
	. += "<span class='notice'>It is turned <b>bolted</b> to the wall.</span>"

/obj/machinery/light_switch/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		return attack_hand(user)

/obj/machinery/light_switch/attack_hand(mob/user)
	on = !on
	playsound(src, 'sound/machines/lightswitch.ogg', 10, TRUE)
	update_icon(UPDATE_ICON_STATE)

	if(light_connect)
		area.lightswitch = on
		area.update_icon(UPDATE_ICON_STATE)

	if(logic_connect && powered(LIGHT))		//Don't bother sending a signal if we aren't set to send them or we have no power to send with.
		handle_output()

	if(light_connect)
		for(var/obj/machinery/light_switch/L in area)
			L.on = on
			L.update_icon(UPDATE_ICON_STATE)

		area.power_change()

/obj/machinery/light_switch/proc/handle_output()
	if(!radio_connection)		//can't output without this
		return

	if(logic_id_tag == null)	//Don't output to an undefined id_tag
		return

	var/datum/signal/signal = new
	signal.transmission_method = 1	//radio signal
	signal.source = src

	//Light switches are continuous signal sources, since they register as ON or OFF and stay that way until adjusted again
	if(on)
		signal.data = list(
				"tag" = logic_id_tag,
				"sigtype" = "logic",
				"state" = LOGIC_ON,
		)
	else
		signal.data = list(
				"tag" = logic_id_tag,
				"sigtype" = "logic",
				"state" = LOGIC_OFF,
		)

	radio_connection.post_signal(src, signal, filter = RADIO_LOGIC)
	if(on)
		use_power(5, LIGHT)			//Use a tiny bit of power every time we send an ON signal. Draws from the local APC's lighting circuit, since this is a LIGHT switch.

/obj/machinery/light_switch/power_change()
	if(!otherarea)
		if(powered(LIGHT))
			stat &= ~NOPOWER
			set_light(1, LIGHTING_MINIMUM_POWER)
		else
			stat |= NOPOWER
			set_light(0)

		update_icon(UPDATE_ICON_STATE | UPDATE_OVERLAYS)

/obj/machinery/light_switch/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	power_change()
	..(severity)

/obj/machinery/light_switch/process()
	if(logic_connect && powered(LIGHT))		//We won't send signals while unpowered, but the last signal will remain valid for anything that received it before we went dark
		handle_output()

/obj/machinery/light_switch/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/detective_scanner))
		return
	return ..()

/obj/machinery/light_switch/multitool_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	update_multitool_menu(user)

/obj/machinery/light_switch/wrench_act(mob/user, obj/item/I)
	if(!I.tool_use_check(user, 0))
		return
	. = TRUE
	WRENCH_UNANCHOR_WALL_ATTEMPT_MESSAGE
	if(I.use_tool(src, user, 30, volume = I.tool_volume))
		WRENCH_UNANCHOR_WALL_SUCCESS_MESSAGE
		new/obj/item/mounted/frame/light_switch(loc)
		qdel(src)

/obj/machinery/light_switch/multitool_menu(mob/user, obj/item/multitool/P)
	return {"
	<ul>
	<li><b>Light Circuit Connection:</b> <a href='?src=[UID()];toggle_light_connect=1'>[light_connect ? "On" : "Off"]</a></li>
	<li><b>Logic Connection:</b> <a href='?src=[UID()];toggle_logic=1'>[logic_connect ? "On" : "Off"]</a></li>
	<li><b>Logic ID Tag:</b> [format_tag("Logic ID Tag", "logic_id_tag")]</li>
	</ul>"}

/obj/machinery/light_switch/multitool_topic(mob/user, list/href_list, obj/O)
	..()
	if("toggle_light_connect" in href_list)
		light_connect = !light_connect
	if("toggle_logic" in href_list)
		logic_connect = !logic_connect
