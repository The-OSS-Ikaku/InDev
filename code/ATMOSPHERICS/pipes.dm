/obj/machinery/atmospherics/pipe
	var/datum/gas_mixture/air_temporary //used when reconstructing a pipeline that broke
	var/datum/pipeline/parent
	var/volume = 0
	layer = 2.4 //under wires with their 2.44
	use_power = 0
	can_unwrench = 1
	var/alert_pressure = 80*ONE_ATMOSPHERE
		//minimum pressure before check_pressure(...) should be called

/obj/machinery/atmospherics/pipe/proc/pipeline_expansion()
	return null

/obj/machinery/atmospherics/pipe/proc/check_pressure(pressure)
	//Return 1 if parent should continue checking other pipes
	//Return null if parent should stop checking other pipes. Recall: del(src) will by default return null
	return 1

/obj/machinery/atmospherics/pipe/proc/releaseAirToTurf()
	if(air_temporary)
		var/turf/T = loc
		T.assume_air(air_temporary)
		air_update_turf()

/obj/machinery/atmospherics/pipe/return_air()
	if(!parent)
		parent = new /datum/pipeline()
		parent.build_pipeline(src)
	return parent.air

/obj/machinery/atmospherics/pipe/build_network()
	if(!parent)
		parent = new /datum/pipeline()
		parent.build_pipeline(src)
	return parent.return_network()

/obj/machinery/atmospherics/pipe/network_expand(datum/pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)
	if(!parent)
		parent = new /datum/pipeline()
		parent.build_pipeline(src)
	return parent.network_expand(new_network, reference)

/obj/machinery/atmospherics/pipe/return_network(obj/machinery/atmospherics/reference)
	if(!parent)
		parent = new /datum/pipeline()
		parent.build_pipeline(src)
	return parent.return_network(reference)

/obj/machinery/atmospherics/pipe/Destroy()
	del(parent)
	..()

/obj/machinery/atmospherics/pipe/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/device/analyzer))
		atmosanalyzer_scan(parent.air, user)

	if(istype(W,/obj/item/device/pipe_painter))
		return

	return ..()
