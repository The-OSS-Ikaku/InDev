/obj/machinery/door/airlock/alarmlock

	name = "glass alarm airlock"
	icon = 'icons/obj/doors/Doorglass.dmi'
	opacity = 0
	doortype = /obj/structure/door_assembly/door_assembly_glass
	glass = 1

	var/datum/radio_frequency/air_connection
	var/air_frequency = 1437
	autoclose = 0

/obj/machinery/door/airlock/alarmlock/New()
	..()
	air_connection = new

/obj/machinery/door/airlock/alarmlock/initialize()
	..()
	radio_controller.remove_object(src, air_frequency)
	air_connection = radio_controller.add_object(src, air_frequency, RADIO_TO_AIRALARM)
	open()


/obj/machinery/door/airlock/alarmlock/receive_signal(datum/signal/signal)
	..()
	if(stat & (NOPOWER|BROKEN))
		return

	var/alarm_area = signal.data["zone"]
	var/alert = signal.data["alert"]

	var/area/our_area = get_area(src)
	if (our_area.master)
		our_area = our_area.master

	if(alarm_area == our_area.name)
		switch(alert)
			if("severe")
				autoclose = 1
				close()
			if("minor", "clear")
				autoclose = 0
				open()