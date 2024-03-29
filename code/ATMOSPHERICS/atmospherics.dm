/*
Quick overview:

Pipes combine to form pipelines
Pipelines and other atmospheric objects combine to form pipe_networks
	Note: A single pipe_network represents a completely open space

Pipes -> Pipelines
Pipelines + Other Objects -> Pipe network

*/

/obj/machinery/atmospherics
	anchored = 1
	idle_power_usage = 0
	active_power_usage = 0
	power_channel = ENVIRON
	var/nodealert = 0
	var/can_unwrench = 0
	var/initialize_directions = 0
	var/pipe_color
	var/obj/item/pipe/stored

	var/global/list/iconsetids = list()
	var/global/list/pipeimages = list()

/*
/obj/machinery/atmospherics/process()
	//build_network()
*/

/obj/machinery/atmospherics/New()
	..()
	if(can_unwrench)
		stored = new(src, make_from=src)

/obj/machinery/atmospherics/proc/network_expand(datum/pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)
	// Check to see if should be added to network. Add self if so and adjust variables appropriately.
	// Note don't forget to have neighbors look as well!

	return null

/obj/machinery/atmospherics/proc/build_network()
	// Called to build a network from this node

	return null

/obj/machinery/atmospherics/proc/return_network(obj/machinery/atmospherics/reference)
	// Returns pipe_network associated with connection to reference
	// Notes: should create network if necessary
	// Should never return null

	return null

/obj/machinery/atmospherics/proc/reassign_network(datum/pipe_network/old_network, datum/pipe_network/new_network)
	// Used when two pipe_networks are combining

/obj/machinery/atmospherics/proc/return_network_air(datum/network/reference)
	// Return a list of gas_mixture(s) in the object
	//		associated with reference pipe_network for use in rebuilding the networks gases list
	// Is permitted to return null

/obj/machinery/atmospherics/proc/disconnect(obj/machinery/atmospherics/reference)

/obj/machinery/atmospherics/proc/icon_addintact(var/obj/machinery/atmospherics/node, var/connected)
	var/image/img = getpipeimage('icons/obj/atmospherics/binary_devices.dmi', "pipe_intact", get_dir(src,node), node.pipe_color)
	underlays += img

	return connected | img.dir

/obj/machinery/atmospherics/proc/icon_addbroken(var/connected)
	var/unconnected = (~connected) & initialize_directions
	for(var/direction in cardinal)
		if(unconnected & direction)
			underlays += getpipeimage('icons/obj/atmospherics/binary_devices.dmi', "pipe_exposed", direction)

/obj/machinery/atmospherics/update_icon()
	return null

/obj/machinery/atmospherics/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	if(can_unwrench && istype(W, /obj/item/weapon/wrench))
		var/turf/T = src.loc
		if (level==1 && isturf(T) && T.intact)
			user << "<span class='danger'>You must remove the plating first.</span>"
			return 1
		var/datum/gas_mixture/int_air = return_air()
		var/datum/gas_mixture/env_air = loc.return_air()
		if ((int_air.return_pressure()-env_air.return_pressure()) > 2*ONE_ATMOSPHERE)
			user << "<span class='danger'>You cannot unwrench this [src], it is too exerted due to internal pressure.</span>"
			add_fingerprint(user)
			return 1
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		user << "<span class='notice'>You begin to unfasten \the [src]...</span>"
		add_fingerprint(user)
		if (do_after(user, 40))
			user.visible_message( \
				"[user] unfastens \the [src].", \
				"<span class='notice'>You have unfastened \the [src].</span>", \
				"You hear ratchet.")
			Deconstruct()
	else
		return ..()

/obj/machinery/atmospherics/Deconstruct()
	if(can_unwrench)
		var/turf/T = loc
		stored.loc = T
		transfer_fingerprints_to(stored)
		if(istype(src, /obj/machinery/atmospherics/pipe))
			for(var/obj/machinery/meter/meter in T)
				if(meter.target == src)
					new /obj/item/pipe_meter(T)
					qdel(meter)
		qdel(src)

/obj/machinery/atmospherics/proc/nullifyPipenetwork()
	return

/obj/machinery/atmospherics/proc/getpipeimage(var/iconset, var/iconstate, var/direction, var/col=rgb(255,255,255))

	//Add identifiers for the iconset
	if(iconsetids[iconset] == null)
		iconsetids[iconset] = num2text(iconsetids.len + 1)

	//Generate a unique identifier for this image combination
	var/identifier = iconsetids[iconset] + "_[iconstate]_[direction]_[col]"

	var/image/img
	if(pipeimages[identifier] == null)
		img = image(iconset, icon_state=iconstate, dir=direction)
		img.color = col

		pipeimages[identifier] = img

	else
		img = pipeimages[identifier]

	return img

/obj/machinery/atmospherics/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		Deconstruct()