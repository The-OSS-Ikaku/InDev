/obj/machinery/atmospherics/unary/cryo_cell
	name = "cryo cell"
	icon = 'icons/obj/cryogenics.dmi'
	icon_state = "cell-off"
	density = 1
	anchored = 1.0
	interact_offline = 1
	layer = 4

	var/on = 0
	var/temperature_archived
	var/obj/item/weapon/reagent_containers/beaker = null
	var/next_trans = 0
	var/current_heat_capacity = 50
	state_open = 0
	var/efficiency

/obj/machinery/atmospherics/unary/cryo_cell/New()
	..()
	initialize_directions = dir
	initialize()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/cryo_tube(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	RefreshParts()

/obj/machinery/atmospherics/unary/cryo_cell/RefreshParts()
	var/C
	for(var/obj/item/weapon/stock_parts/matter_bin/M in component_parts)
		C += M.rating
	current_heat_capacity = 50 * C
	efficiency = C

/obj/machinery/atmospherics/unary/cryo_cell/Destroy()
	var/turf/T = loc
	T.contents += contents
	var/obj/item/weapon/reagent_containers/glass/B = beaker
	if(beaker)
		B.loc = get_step(loc, SOUTH) //Beaker is carefully ejected from the wreckage of the cryotube
	..()

/obj/machinery/atmospherics/unary/cryo_cell/process()
	..()
	if(!node || !is_operational())
		return
	if(!on)
		updateDialog()
		return

	if(air_contents)
		temperature_archived = air_contents.temperature
		heat_gas_contents()
		expel_gas()

		if(occupant)
			if(occupant.stat != 2)
				process_occupant()

	if(abs(temperature_archived-air_contents.temperature) > 1)
		network.update = 1

	updateDialog()
	return 1

/obj/machinery/atmospherics/unary/cryo_cell/MouseDrop_T(mob/target, mob/user)
	if(user.stat || user.lying || !Adjacent(user) || !target.Adjacent(user) || !iscarbon(target))
		return
	close_machine(target)

/obj/machinery/atmospherics/unary/cryo_cell/allow_drop()
	return 0

/obj/machinery/atmospherics/unary/cryo_cell/relaymove(var/mob/user)
	..()
	open_machine()

/obj/machinery/atmospherics/unary/cryo_cell/container_resist()
	if(stat & DEAD)
		return
	sleep(usr.stat * 1200)
	open_machine()
	return

/obj/machinery/atmospherics/unary/cryo_cell/examine(mob/user)
	..()

	var/list/otherstuff = contents - beaker
	if(otherstuff.len > 0)
		user << "You can just about make out some loose objects floating in the murk:"
		for(var/atom/movable/floater in otherstuff)
			user << "\icon[floater] [floater.name]"
	else
		user << "Seems empty."

/obj/machinery/atmospherics/unary/cryo_cell/attack_hand(mob/user)
	if(..())
		return

	//powerless interaction
	if(!is_operational())
		user.unset_machine()//essential to prevent infinite loops of opening/closing the machine
		if(state_open)
			close_machine()
		else
			open_machine()

	else
		ui_interact(user)


 /**
  * The ui_interact proc is used to open and update Nano UIs
  * If ui_interact is not used then the UI will not update correctly
  * ui_interact is currently defined for /atom/movable
  *
  * @param user /mob The mob who is interacting with this ui
  * @param ui_key string A string key to use for this ui. Allows for multiple unique uis on one obj/mob (defaut value "main")
  *
  * @return nothing
  */
/obj/machinery/atmospherics/unary/cryo_cell/ui_interact(mob/user, ui_key = "main")
	if(user == occupant || user.stat || panel_open)
		return

	// this is the data which will be sent to the ui
	var/data[0]
	data["isOperating"] = on
	data["hasOccupant"] = occupant ? 1 : 0

	var/occupantData[0]
	if (!occupant)
		occupantData["name"] = null
		occupantData["stat"] = null
		occupantData["health"] = null
		occupantData["maxHealth"] = null
		occupantData["minHealth"] = null
		occupantData["bruteLoss"] = null
		occupantData["oxyLoss"] = null
		occupantData["toxLoss"] = null
		occupantData["fireLoss"] = null
		occupantData["bodyTemperature"] = null
	else
		occupantData["name"] = occupant.name
		occupantData["stat"] = occupant.stat
		occupantData["health"] = occupant.health
		occupantData["maxHealth"] = occupant.maxHealth
		occupantData["minHealth"] = config.health_threshold_dead
		occupantData["bruteLoss"] = occupant.getBruteLoss()
		occupantData["oxyLoss"] = occupant.getOxyLoss()
		occupantData["toxLoss"] = occupant.getToxLoss()
		occupantData["fireLoss"] = occupant.getFireLoss()
		occupantData["bodyTemperature"] = occupant.bodytemperature
	data["occupant"] = occupantData;

	data["isOpen"] = state_open
	data["cellTemperature"] = round(air_contents.temperature)
	data["cellTemperatureStatus"] = "good"
	if(air_contents.temperature > T0C) // if greater than 273.15 kelvin (0 celcius)
		data["cellTemperatureStatus"] = "bad"
	else if(air_contents.temperature > 225)
		data["cellTemperatureStatus"] = "average"

	data["isBeakerLoaded"] = beaker ? 1 : 0
	var beakerContents[0]
	if(beaker && beaker:reagents && beaker:reagents.reagent_list.len)
		for(var/datum/reagent/R in beaker:reagents.reagent_list)
			beakerContents.Add(list(list("name" = R.name, "volume" = R.volume))) // list in a list because Byond merges the first list...
	data["beakerContents"] = beakerContents

	var/datum/nanoui/ui = nanomanager.get_open_ui(user, src, ui_key)
	if (!ui)
		// the ui does not exist, so we'll create a new one
		ui = new(user, src, ui_key, "cryo.tmpl", "Cryo Cell Control System", 520, 410)
		// When the UI is first opened this is the data it will use
		ui.set_initial_data(data)
		ui.open()
		// Auto update every Master Controller tick
		ui.set_auto_update(1)
	else
		// The UI is already open so push the new data to it
		ui.push_data(data)
		return
	//user.set_machine(src)

/obj/machinery/atmospherics/unary/cryo_cell/Topic(href, href_list)
	if(usr == occupant || panel_open)
		return 0 // don't update UIs attached to this object

	if(..())
		return 0 // don't update UIs attached to this object

	if(href_list["switchOn"])
		if(!state_open)
			on = 1

	if(href_list["open"])
		open_machine()

	if(href_list["close"])
		if(close_machine() == usr)
			var/datum/nanoui/ui = nanomanager.get_open_ui(usr, src, "main")
			ui.close()
			on = 1
	if(href_list["switchOff"])
		on = 0

	if(href_list["ejectBeaker"])
		if(beaker)
			var/obj/item/weapon/reagent_containers/glass/B = beaker
			B.loc = get_step(loc, SOUTH)
			beaker = null
	update_icon()
	add_fingerprint(usr)
	return 1 // update UIs attached to this object

/obj/machinery/atmospherics/unary/cryo_cell/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/reagent_containers/glass))
		if(beaker)
			user << "<span class='notice'>A beaker is already loaded into [src].</span>"
			return

		beaker = I
		user.drop_item()
		I.loc = src
		user.visible_message("<span class='notice'>[user] places [I] in [src].</span>", \
							"<span class='notice'>You place [I] in [src].</span>")

	if(!(on || occupant || state_open))
		if(default_deconstruction_screwdriver(user, "cell-o", "cell-off", I))
			return

	if(default_change_direction_wrench(user, I))
		return

	if(exchange_parts(user, I))
		return

	default_deconstruction_crowbar(I)

/obj/machinery/atmospherics/unary/cryo_cell/open_machine()
	if(!state_open && !panel_open)
		on = 0
		layer = 3
		if(occupant)
			occupant.bodytemperature = Clamp(occupant.bodytemperature, 261, 360)
		..()
		if(beaker)
			beaker.loc = src

/obj/machinery/atmospherics/unary/cryo_cell/close_machine(mob/living/carbon/M)
	if(state_open && !panel_open)
		layer = 4
		..(M)
		return occupant

/obj/machinery/atmospherics/unary/cryo_cell/update_icon()
	if(panel_open)
		icon_state = "cell-o"
		return
	if(state_open)
		icon_state = "cell-open"
		return
	if(on && is_operational())
		if(occupant)
			icon_state = "cell-occupied"
		else
			icon_state = "cell-on"
	else
		icon_state = "cell-off"

/obj/machinery/atmospherics/unary/cryo_cell/power_change()
	..()
	update_icon()

/obj/machinery/atmospherics/unary/cryo_cell/proc/process_occupant()
	if(air_contents.total_moles() < 10)
		return
	if(occupant)
		if(occupant.stat == 2 || occupant.health >= 100)  //Why waste energy on dead or healthy people
			occupant.bodytemperature = T0C
			return
		occupant.bodytemperature += 2*(air_contents.temperature - occupant.bodytemperature) * current_heat_capacity / (current_heat_capacity + air_contents.heat_capacity())
		occupant.bodytemperature = max(occupant.bodytemperature, air_contents.temperature) // this is so ugly i'm sorry for doing it i'll fix it later i promise
		if(occupant.bodytemperature < T0C)
			occupant.sleeping = max(5/efficiency, (1 / occupant.bodytemperature)*2000/efficiency)
			occupant.Paralyse(max(5/efficiency, (1 / occupant.bodytemperature)*3000/efficiency))
			if(air_contents.oxygen > 2)
				if(occupant.getOxyLoss()) occupant.adjustOxyLoss(-1)
			else
				occupant.adjustOxyLoss(-1)
			//severe damage should heal waaay slower without proper chemicals
			if(occupant.bodytemperature < 225)
				if(occupant.getToxLoss())
					occupant.adjustToxLoss(max(-efficiency, (-20*(efficiency ** 2)) / occupant.getToxLoss()))
				var/heal_brute = occupant.getBruteLoss() ? min(efficiency, 20*(efficiency**2) / occupant.getBruteLoss()) : 0
				var/heal_fire = occupant.getFireLoss() ? min(efficiency, 20*(efficiency**2) / occupant.getFireLoss()) : 0
				occupant.heal_organ_damage(heal_brute,heal_fire)
		if(beaker && next_trans == 0)
			beaker.reagents.trans_to(occupant, 1, 10)
			beaker.reagents.reaction(occupant)
	next_trans++
	if(next_trans == 10)
		next_trans = 0


/obj/machinery/atmospherics/unary/cryo_cell/proc/heat_gas_contents()
	if(air_contents.total_moles() < 1)
		return
	var/air_heat_capacity = air_contents.heat_capacity()
	var/combined_heat_capacity = current_heat_capacity + air_heat_capacity
	if(combined_heat_capacity > 0)
		var/combined_energy = T20C * current_heat_capacity + air_heat_capacity * air_contents.temperature
		air_contents.temperature = combined_energy/combined_heat_capacity


/obj/machinery/atmospherics/unary/cryo_cell/proc/expel_gas()
	if(air_contents.total_moles() < 1)
		return
	var/datum/gas_mixture/expel_gas = new
	var/remove_amount = air_contents.total_moles() / 100
	expel_gas = air_contents.remove(remove_amount)
	expel_gas.temperature = T20C	//Lets expel hot gas and see if that helps people not die as they are removed
	loc.assume_air(expel_gas)
	air_update_turf()
