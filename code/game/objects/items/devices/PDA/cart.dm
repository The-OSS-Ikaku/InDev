/obj/item/weapon/cartridge
	name = "generic cartridge"
	desc = "A data cartridge for portable microcomputers."
	icon = 'icons/obj/pda.dmi'
	icon_state = "cart"
	item_state = "electronic"
	w_class = 1

	var/obj/item/radio/integrated/radio = null
	var/access_security = 0
	var/access_engine = 0
	var/access_atmos = 0
	var/access_medical = 0
	var/access_manifest = 0
	var/access_clown = 0
	var/access_mime = 0
	var/access_janitor = 0
//	var/access_flora = 0
	var/access_reagent_scanner = 0
	var/access_remote_door = 0 //Control some blast doors remotely!!
	var/remote_door_id = ""
	var/access_status_display = 0
	var/access_quartermaster = 0
	var/access_hydroponics = 0
	var/mode = null
	var/menu
	var/datum/data/record/active1 = null //General
	var/datum/data/record/active2 = null //Medical
	var/datum/data/record/active3 = null //Security
	var/obj/machinery/computer/monitor/powmonitor = null // Power Monitor
	var/list/powermonitors = list()
	var/message1	// used for status_displays
	var/message2
	var/list/stored_data = list()

/obj/item/weapon/cartridge/engineering
	name = "\improper Power-ON cartridge"
	icon_state = "cart-e"
	access_engine = 1

	/obj/item/weapon/cartridge/engineering/New()
		..()
		radio = new /obj/item/radio/integrated/floorbot(src)

/obj/item/weapon/cartridge/atmos
	name = "\improper BreatheDeep cartridge"
	icon_state = "cart-a"
	access_atmos = 1

	/obj/item/weapon/cartridge/atmos/New()
		..()
		radio = new /obj/item/radio/integrated/floorbot(src)

/obj/item/weapon/cartridge/medical
	name = "\improper Med-U cartridge"
	icon_state = "cart-m"
	access_medical = 1

	/obj/item/weapon/cartridge/medical/New()
		..()
		radio = new /obj/item/radio/integrated/medbot(src)

/obj/item/weapon/cartridge/chemistry
	name = "\improper ChemWhiz cartridge"
	icon_state = "cart-chem"
	access_reagent_scanner = 1

	/obj/item/weapon/cartridge/chemistry/New()
		..()
		radio = new /obj/item/radio/integrated/medbot(src)

/obj/item/weapon/cartridge/security
	name = "\improper R.O.B.U.S.T. cartridge"
	icon_state = "cart-s"
	access_security = 1

/obj/item/weapon/cartridge/security/New()
	..()
	radio = new /obj/item/radio/integrated/beepsky(src)

/obj/item/weapon/cartridge/detective
	name = "\improper D.E.T.E.C.T. cartridge"
	icon_state = "cart-s"
	access_security = 1
	access_medical = 1
	access_manifest = 1

/obj/item/weapon/cartridge/detective/New()
	..()
	radio = new /obj/item/radio/integrated/beepsky(src)

/obj/item/weapon/cartridge/janitor
	name = "\improper CustodiPRO cartridge"
	desc = "The ultimate in clean-room design."
	icon_state = "cart-j"
	access_janitor = 1

/obj/item/weapon/cartridge/janitor/New()
	..()
	radio = new /obj/item/radio/integrated/cleanbot(src)

/obj/item/weapon/cartridge/lawyer
	name = "\improper P.R.O.V.E. cartridge"
	icon_state = "cart-s"
	access_security = 1

/obj/item/weapon/cartridge/clown
	name = "\improper Honkworks 5.0 cartridge"
	icon_state = "cart-clown"
	access_clown = 1
	var/honk_charges = 5

/obj/item/weapon/cartridge/mime
	name = "\improper Gestur-O 1000 cartridge"
	icon_state = "cart-mi"
	access_mime = 1
	var/mime_charges = 5
/*
/obj/item/weapon/cartridge/botanist
	name = "\improper Green Thumb v4.20 cartridge"
	icon_state = "cart-b"
	access_flora = 1
*/

/obj/item/weapon/cartridge/signal
	name = "generic signaler cartridge"
	desc = "A data cartridge with an integrated radio signaler module."

/obj/item/weapon/cartridge/signal/toxins
	name = "\improper Signal Ace 2 cartridge"
	desc = "Complete with integrated radio signaler!"
	icon_state = "cart-tox"
	access_reagent_scanner = 1
	access_atmos = 1

/obj/item/weapon/cartridge/signal/New()
	..()
	radio = new /obj/item/radio/integrated/signal(src)



/obj/item/weapon/cartridge/quartermaster
	name = "space parts & space vendors cartridge"
	desc = "Perfect for the Quartermaster on the go!"
	icon_state = "cart-q"
	access_quartermaster = 1

/obj/item/weapon/cartridge/quartermaster/New()
	..()
	radio = new /obj/item/radio/integrated/mule(src)

/obj/item/weapon/cartridge/head
	name = "\improper Easy-Record DELUXE cartridge"
	icon_state = "cart-h"
	access_manifest = 1
	access_status_display = 1

/obj/item/weapon/cartridge/hop
	name = "\improper HumanResources9001 cartridge"
	icon_state = "cart-h"
	access_manifest = 1
	access_status_display = 1
	access_quartermaster = 1
	access_janitor = 1
	access_security = 1

/obj/item/weapon/cartridge/hop/New()
	..()
	radio = new /obj/item/radio/integrated/mule(src)

/obj/item/weapon/cartridge/hos
	name = "\improper R.O.B.U.S.T. DELUXE cartridge"
	icon_state = "cart-hos"
	access_manifest = 1
	access_status_display = 1
	access_security = 1

/obj/item/weapon/cartridge/hos/New()
	..()
	radio = new /obj/item/radio/integrated/beepsky(src)

/obj/item/weapon/cartridge/ce
	name = "\improper Power-On DELUXE cartridge"
	icon_state = "cart-ce"
	access_manifest = 1
	access_status_display = 1
	access_engine = 1
	access_atmos = 1

/obj/item/weapon/cartridge/ce/New()
	..()
	radio = new /obj/item/radio/integrated/floorbot(src)

/obj/item/weapon/cartridge/cmo
	name = "\improper Med-U DELUXE cartridge"
	icon_state = "cart-cmo"
	access_manifest = 1
	access_status_display = 1
	access_reagent_scanner = 1
	access_medical = 1

/obj/item/weapon/cartridge/cmo/New()
	..()
	radio = new /obj/item/radio/integrated/medbot(src)

/obj/item/weapon/cartridge/rd
	name = "\improper Signal Ace DELUXE cartridge"
	icon_state = "cart-rd"
	access_manifest = 1
	access_status_display = 1
	access_reagent_scanner = 1
	access_atmos = 1

/obj/item/weapon/cartridge/rd/New()
	..()
	radio = new /obj/item/radio/integrated/signal(src)

/obj/item/weapon/cartridge/captain
	name = "\improper Value-PAK cartridge"
	desc = "Now with 200% more value!"
	icon_state = "cart-c"
	access_manifest = 1
	access_engine = 1
	access_security = 1
	access_medical = 1
	access_reagent_scanner = 1
	access_status_display = 1
	access_atmos = 1

/obj/item/weapon/cartridge/captain/New()
	..()
	radio = new /obj/item/radio/integrated/beepsky(src)

/obj/item/weapon/cartridge/syndicate
	name = "\improper Detomatix cartridge"
	icon_state = "cart"
	access_remote_door = 1
	remote_door_id = "smindicate" //Make sure this matches the syndicate shuttle's shield/door id!!	//don't ask about the name, testing.
	var/shock_charges = 4

/obj/item/weapon/cartridge/proc/unlock()
	if (!istype(loc, /obj/item/device/pda))
		return

	generate_menu()
	print_to_host(menu)
	return

/obj/item/weapon/cartridge/proc/print_to_host(var/text)
	if (!istype(loc, /obj/item/device/pda))
		return
	loc:cart = text

	for (var/mob/M in viewers(1, loc.loc))
		if (M.client && M.machine == loc)
			loc:attack_self(M)

	return

/obj/item/weapon/cartridge/proc/post_status(var/command, var/data1, var/data2)

	var/datum/radio_frequency/frequency = radio_controller.return_frequency(1435)

	if(!frequency) return

	var/datum/signal/status_signal = new
	status_signal.source = src
	status_signal.transmission_method = 1
	status_signal.data["command"] = command

	switch(command)
		if("message")
			status_signal.data["msg1"] = data1
			status_signal.data["msg2"] = data2
		if("alert")
			status_signal.data["picture_state"] = data1

	frequency.post_signal(src, status_signal)

/obj/item/weapon/cartridge/proc/bot_control(var/obj/item/radio/integrated/SC)


	if(!SC)
		menu = "Interlink Error - Please reinsert cartridge."
		return

	if(!SC.active)
		// list of bots
		if(!SC.botlist || (SC.botlist && SC.botlist.len==0))
			menu += "No bots found.<BR>"

		else
			for(var/obj/machinery/bot/B in SC.botlist)
				menu += "<A href='byond://?src=\ref[SC];op=control;bot=\ref[B]'>[B] at [get_area(B)]</A><BR>"

		menu += "<BR><A href='byond://?src=\ref[SC];op=scanbots'><img src=pda_scanner.png> Scan for active bots</A><BR>"

	else	// bot selected, control it

		menu += "<B>[SC.active]</B><BR> Status: (<A href='byond://?src=\ref[SC];op=control;bot=\ref[SC.active]'><img src=pda_refresh.png><i>refresh</i></A>)<BR>"

		if(!SC.botstatus)
			menu += "Waiting for response...<BR>"
		else

			menu += "Location: [SC.botstatus["loca"] ]<BR>"
			menu += "Mode: "

			switch(SC.botstatus["mode"])
				if(BOT_IDLE)
					menu += "Ready"
				if(BOT_HUNT)
					menu += "Apprehending target"
				if(BOT_PREP_ARREST,BOT_ARREST)
					menu += "Arresting target"
				if(BOT_START_PATROL)
					menu += "Starting patrol"
				if(BOT_PATROL)
					menu += "On patrol"
				if(BOT_SUMMON)
					menu += "Responding to summons"
				if(BOT_CLEANING)
					menu += "Cleaning"
				if(BOT_MOVING)
					menu += "Proceeding to work site"
				if(BOT_REPAIRING)
					menu += "Performing repairs"
				if(BOT_HEALING)
					menu += "Medicating patient"
				if(BOT_RESPONDING)
					menu += "Proceeding to AI waypoint"

			menu += "<BR>\[<A href='byond://?src=\ref[SC];op=stop'>Stop Patrol</A>\] "
			menu += "\[<A href='byond://?src=\ref[SC];op=go'>Start Patrol</A>\] "
			menu += "\[<A href='byond://?src=\ref[SC];op=summon'>Summon Bot</A>\]<BR>"
			menu += "<HR><A href='byond://?src=\ref[SC];op=botlist'><img src=pda_back.png>Return to bot list</A><BR>"
			menu += "Keep an ID inserted to upload access codes upon summoning."
	return menu


/obj/item/weapon/cartridge/proc/generate_menu()
	switch(mode)
		if(40) //signaller
			menu = "<h4><img src=pda_signaler.png> Remote Signaling System</h4>"

			menu += {"
<a href='byond://?src=\ref[src];choice=Send Signal'>Send Signal</A><BR>
Frequency:
<a href='byond://?src=\ref[src];choice=Signal Frequency;sfreq=-10'>-</a>
<a href='byond://?src=\ref[src];choice=Signal Frequency;sfreq=-2'>-</a>
[format_frequency(radio:frequency)]
<a href='byond://?src=\ref[src];choice=Signal Frequency;sfreq=2'>+</a>
<a href='byond://?src=\ref[src];choice=Signal Frequency;sfreq=10'>+</a><br>
<br>
Code:
<a href='byond://?src=\ref[src];choice=Signal Code;scode=-5'>-</a>
<a href='byond://?src=\ref[src];choice=Signal Code;scode=-1'>-</a>
[radio:code]
<a href='byond://?src=\ref[src];choice=Signal Code;scode=1'>+</a>
<a href='byond://?src=\ref[src];choice=Signal Code;scode=5'>+</a><br>"}
		if (41) //crew manifest

			menu = "<h4><img src=pda_notes.png> Crew Manifest</h4>"
			menu += "Entries cannot be modified from this terminal.<br><br>"
			if(data_core.general)
				for (var/datum/data/record/t in sortRecord(data_core.general))
					menu += "[t.fields["name"]] - [t.fields["rank"]]<br>"
			menu += "<br>"


		if (42) //status displays
			menu = "<h4><img src=pda_status.png> Station Status Display Interlink</h4>"

			menu += "\[ <A HREF='?src=\ref[src];choice=Status;statdisp=blank'>Clear</A> \]<BR>"
			menu += "\[ <A HREF='?src=\ref[src];choice=Status;statdisp=shuttle'>Shuttle ETA</A> \]<BR>"
			menu += "\[ <A HREF='?src=\ref[src];choice=Status;statdisp=message'>Message</A> \]"
			menu += "<ul><li> Line 1: <A HREF='?src=\ref[src];choice=Status;statdisp=setmsg1'>[ message1 ? message1 : "(none)"]</A>"
			menu += "<li> Line 2: <A HREF='?src=\ref[src];choice=Status;statdisp=setmsg2'>[ message2 ? message2 : "(none)"]</A></ul><br>"
			menu += "\[ Alert: <A HREF='?src=\ref[src];choice=Status;statdisp=alert;alert=default'>None</A> |"
			menu += " <A HREF='?src=\ref[src];choice=Status;statdisp=alert;alert=redalert'>Red Alert</A> |"
			menu += " <A HREF='?src=\ref[src];choice=Status;statdisp=alert;alert=lockdown'>Lockdown</A> |"
			menu += " <A HREF='?src=\ref[src];choice=Status;statdisp=alert;alert=biohazard'>Biohazard</A> \]<BR>"

		if (43)
			menu = "<h4><img src=pda_power.png> Power Monitors - Please select one</h4><BR>"
			powmonitor = null
			powermonitors = list()
			var/powercount = 0



			for(var/obj/machinery/computer/monitor/pMon in world)
				if(!(pMon.stat & (NOPOWER|BROKEN)) )
					powercount++
					powermonitors += pMon


			if(!powercount)
				menu += "<span class='danger'>No connection<BR></span>"
			else

				menu += "<FONT SIZE=-1>"
				var/count = 0
				for(var/obj/machinery/computer/monitor/pMon in powermonitors)
					count++
					menu += "<a href='byond://?src=\ref[src];choice=Power Select;target=[count]'> [pMon] </a><BR>"

				menu += "</FONT>"

		if (433)
			menu = "<h4><img src=pda_power.png> Power Monitor </h4><BR>"
			if(!powmonitor)
				menu += "<span class='danger'>No connection<BR></span>"
			else
				var/list/L = list()
				for(var/obj/machinery/power/terminal/term in powmonitor.powernet.nodes)
					if(istype(term.master, /obj/machinery/power/apc))
						var/obj/machinery/power/apc/A = term.master
						L += A

				menu += "<PRE>Total power: [powmonitor.powernet.avail] W<BR>Total load:  [num2text(powmonitor.powernet.viewload,10)] W<BR>"

				menu += "<FONT SIZE=-1>"

				if(L.len > 0)
					menu += "Area                           Eqp./Lgt./Env.  Load   Cell<HR>"

					var/list/S = list(" Off","AOff","  On", " AOn")
					var/list/chg = list("N","C","F")

					for(var/obj/machinery/power/apc/A in L)
						menu += copytext(add_tspace(A.area.name, 30), 1, 30)
						menu += " [S[A.equipment+1]] [S[A.lighting+1]] [S[A.environ+1]] [add_lspace(A.lastused_total, 6)]  [A.cell ? "[add_lspace(round(A.cell.percent()), 3)]% [chg[A.charging+1]]" : "  N/C"]<BR>"

				menu += "</FONT></PRE>"

		if (44) //medical records //This thing only displays a single screen so it's hard to really get the sub-menu stuff working.
			menu = "<h4><img src=pda_medical.png> Medical Record List</h4>"
			if(data_core.general)
				for(var/datum/data/record/R in sortRecord(data_core.general))
					menu += "<a href='byond://?src=\ref[src];choice=Medical Records;target=[R.fields["id"]]'>[R.fields["id"]]: [R.fields["name"]]<br>"
			menu += "<br>"
		if(441)
			menu = "<h4><img src=pda_medical.png> Medical Record</h4>"

			if(active1 in data_core.general)
				menu += "Name: [active1.fields["name"]] ID: [active1.fields["id"]]<br>"
				menu += "Sex: [active1.fields["sex"]]<br>"
				menu += "Age: [active1.fields["age"]]<br>"
				menu += "Rank: [active1.fields["rank"]]<br>"
				menu += "Fingerprint: [active1.fields["fingerprint"]]<br>"
				menu += "Physical Status: [active1.fields["p_stat"]]<br>"
				menu += "Mental Status: [active1.fields["m_stat"]]<br>"
			else
				menu += "<b>Record Lost!</b><br>"

			menu += "<br>"

			menu += "<h4><img src=pda_medical.png> Medical Data</h4>"
			if(active2 in data_core.medical)
				menu += "Blood Type: [active2.fields["blood_type"]]<br><br>"

				menu += "Minor Disabilities: [active2.fields["mi_dis"]]<br>"
				menu += "Details: [active2.fields["mi_dis_d"]]<br><br>"

				menu += "Major Disabilities: [active2.fields["ma_dis"]]<br>"
				menu += "Details: [active2.fields["ma_dis_d"]]<br><br>"

				menu += "Allergies: [active2.fields["alg"]]<br>"
				menu += "Details: [active2.fields["alg_d"]]<br><br>"

				menu += "Current Diseases: [active2.fields["cdi"]]<br>"
				menu += "Details: [active2.fields["cdi_d"]]<br><br>"

				menu += "Important Notes: [active2.fields["notes"]]<br>"
			else
				menu += "<b>Record Lost!</b><br>"

			menu += "<br>"
		if (45) //security records
			menu = "<h4><img src=pda_cuffs.png> Security Record List</h4>"
			if(data_core.general)
				for (var/datum/data/record/R in sortRecord(data_core.general))
					menu += "<a href='byond://?src=\ref[src];choice=Security Records;target=[R.fields["id"]]'>[R.fields["id"]]: [R.fields["name"]]<br>"

			menu += "<br>"
		if(451)
			menu = "<h4><img src=pda_cuffs.png> Security Record</h4>"

			if(active1 in data_core.general)
				menu += "Name: [active1.fields["name"]] ID: [active1.fields["id"]]<br>"
				menu += "Sex: [active1.fields["sex"]]<br>"
				menu += "Age: [active1.fields["age"]]<br>"
				menu += "Rank: [active1.fields["rank"]]<br>"
				menu += "Fingerprint: [active1.fields["fingerprint"]]<br>"
				menu += "Physical Status: [active1.fields["p_stat"]]<br>"
				menu += "Mental Status: [active1.fields["m_stat"]]<br>"
			else
				menu += "<b>Record Lost!</b><br>"

			menu += "<br>"

			menu += "<h4><img src=pda_cuffs.png> Security Data</h4>"
			if(active3 in data_core.security)
				menu += "Criminal Status: [active3.fields["criminal"]]<br>"

				menu += text("<BR>\nMinor Crimes:")

				menu +={"<table style="text-align:center;" border="1" cellspacing="0" width="100%">
<tr>
<th>Crime</th>
<th>Details</th>
<th>Author</th>
<th>Time Added</th>
</tr>"}
				for(var/datum/data/crime/c in active3.fields["mi_crim"])
					menu += "<tr><td>[c.crimeName]</td>"
					menu += "<td>[c.crimeDetails]</td>"
					menu += "<td>[c.author]</td>"
					menu += "<td>[c.time]</td>"
					menu += "</tr>"
				menu += "</table>"

				menu += text("<BR>\nMajor Crimes:")

				menu +={"<table style="text-align:center;" border="1" cellspacing="0" width="100%">
<tr>
<th>Crime</th>
<th>Details</th>
<th>Author</th>
<th>Time Added</th>
</tr>"}
				for(var/datum/data/crime/c in active3.fields["ma_crim"])
					menu += "<tr><td>[c.crimeName]</td>"
					menu += "<td>[c.crimeDetails]</td>"
					menu += "<td>[c.author]</td>"
					menu += "<td>[c.time]</td>"
					menu += "</tr>"
				menu += "</table>"

				menu += "<BR>\nImportant Notes:<br>"
				menu += "[active3.fields["notes"]]"
			else
				menu += "<b>Record Lost!</b><br>"

			menu += "<br>"
		if (46) //beepsky control
			var/obj/item/radio/integrated/beepsky/SC = radio
			menu = "<h4><img src=pda_cuffs.png> Securitron Interlink</h4>"
			bot_control(SC)

		if (47) //quartermaster order records
			menu = "<h4><img src=pda_crate.png> Supply Record Interlink</h4>"

			menu += "<BR><B>Supply shuttle</B><BR>"
			menu += "Location: [supply_shuttle.moving ? "Moving to station ([supply_shuttle.eta] Mins.)":supply_shuttle.at_station ? "Station":"Dock"]<BR>"
			menu += "Current approved orders: <BR><ol>"
			for(var/S in supply_shuttle.shoppinglist)
				var/datum/supply_order/SO = S
				menu += "<li>#[SO.ordernum] - [SO.object.name] approved by [SO.orderedby] [SO.comment ? "([SO.comment])":""]</li>"
			menu += "</ol>"

			menu += "Current requests: <BR><ol>"
			for(var/S in supply_shuttle.requestlist)
				var/datum/supply_order/SO = S
				menu += "<li>#[SO.ordernum] - [SO.object.name] requested by [SO.orderedby]</li>"
			menu += "</ol><font size=\"-3\">Upgrade NOW to Space Parts & Space Vendors PLUS for full remote order control and inventory management."

		if (48) //mulebot control
			var/obj/item/radio/integrated/mule/QC = radio
			if(!QC)
				menu = "Interlink Error - Please reinsert cartridge."
				return
			menu = "<h4><img src=pda_mule.png> M.U.L.E. bot Interlink V0.8</h4>"

			if(!QC.active)
				// list of bots
				if(!QC.botlist || (QC.botlist && QC.botlist.len==0))
					menu += "No bots found.<BR>"

				else
					for(var/obj/machinery/bot/mulebot/B in QC.botlist)
						menu += "<A href='byond://?src=\ref[QC];op=control;bot=\ref[B]'>[B] at [get_area(B)]</A><BR>"

				menu += "<BR><A href='byond://?src=\ref[QC];op=scanbots'><img src=pda_scanner.png> Scan for active bots</A><BR>"

			else	// bot selected, control it

				menu += "<B>[QC.active]</B><BR> Status: (<A href='byond://?src=\ref[QC];op=control;bot=\ref[QC.active]'><img src=pda_refresh.png><i>refresh</i></A>)<BR>"

				if(!QC.botstatus)
					menu += "Waiting for response...<BR>"
				else

					menu += "Location: [QC.botstatus["loca"] ]<BR>"
					menu += "Mode: "

					switch(QC.botstatus["mode"])
						if(BOT_IDLE)
							menu += "Ready"
						if(BOT_LOADING)
							menu += "Loading/Unloading"
						if(BOT_DELIVER)
							menu += "Navigating to Delivery Location"
						if(BOT_GO_HOME)
							menu += "Navigating to Home"
						if(BOT_BLOCKED)
							menu += "Waiting for clear path"
						if(BOT_NAV,BOT_WAIT_FOR_NAV)
							menu += "Calculating navigation path"
						if(BOT_NO_ROUTE)
							menu += "Unable to locate destination"
					var/obj/structure/closet/crate/C = QC.botstatus["load"]
					menu += "<BR>Current Load: [ !C ? "<i>none</i>" : "[C.name] (<A href='byond://?src=\ref[QC];op=unload'><i>unload</i></A>)" ]<BR>"
					menu += "Destination: [!QC.botstatus["dest"] ? "<i>none</i>" : QC.botstatus["dest"] ] (<A href='byond://?src=\ref[QC];op=setdest'><i>set</i></A>)<BR>"
					menu += "Power: [QC.botstatus["powr"]]%<BR>"
					menu += "Home: [!QC.botstatus["home"] ? "<i>none</i>" : QC.botstatus["home"] ]<BR>"
					menu += "Auto Return Home: [QC.botstatus["retn"] ? "<B>On</B> <A href='byond://?src=\ref[QC];op=retoff'>Off</A>" : "(<A href='byond://?src=\ref[QC];op=reton'><i>On</i></A>) <B>Off</B>"]<BR>"
					menu += "Auto Pickup Crate: [QC.botstatus["pick"] ? "<B>On</B> <A href='byond://?src=\ref[QC];op=pickoff'>Off</A>" : "(<A href='byond://?src=\ref[QC];op=pickon'><i>On</i></A>) <B>Off</B>"]<BR><BR>"

					menu += "\[<A href='byond://?src=\ref[QC];op=stop'>Stop</A>\] "
					menu += "\[<A href='byond://?src=\ref[QC];op=go'>Proceed</A>\] "
					menu += "\[<A href='byond://?src=\ref[QC];op=home'>Return Home</A>\]<BR>"
					menu += "<HR><A href='byond://?src=\ref[QC];op=botlist'><img src=pda_back.png>Return to bot list</A>"

		if (49) //janitorial locator
			menu = "<h4><img src=pda_bucket.png> Persistent Custodial Object Locator</h4>"

			var/turf/cl = get_turf(src)
			if (cl)
				menu += "Current Orbital Location: <b>\[[cl.x],[cl.y]\]</b>"

				menu += "<h4>Located Mops:</h4>"

				var/ldat
				for (var/obj/item/weapon/mop/M in world)
					var/turf/ml = get_turf(M)

					if(ml)
						if (ml.z != cl.z)
							continue
						var/direction = get_dir(src, M)
						ldat += "Mop - <b>\[[ml.x],[ml.y] ([uppertext(dir2text(direction))])\]</b> - [M.reagents.total_volume ? "Wet" : "Dry"]<br>"

				if (!ldat)
					menu += "None"
				else
					menu += "[ldat]"

				menu += "<h4>Located Janitorial Cart:</h4>"

				ldat = null
				for (var/obj/structure/janitorialcart/B in world)
					var/turf/bl = get_turf(B)

					if(bl)
						if (bl.z != cl.z)
							continue
						var/direction = get_dir(src, B)
						ldat += "Cart - <b>\[[bl.x],[bl.y] ([uppertext(dir2text(direction))])\]</b> - Water level: [B.reagents.total_volume]/100<br>"

				if (!ldat)
					menu += "None"
				else
					menu += "[ldat]"

				menu += "<h4>Located Cleanbots:</h4>"

				ldat = null
				for (var/obj/machinery/bot/cleanbot/B in world)
					var/turf/bl = get_turf(B)

					if(bl)
						if (bl.z != cl.z)
							continue
						var/direction = get_dir(src, B)
						ldat += "Cleanbot - <b>\[[bl.x],[bl.y] ([uppertext(dir2text(direction))])\]</b> - [B.on ? "Online" : "Offline"]<br>"

				if (!ldat)
					menu += "None"
				else
					menu += "[ldat]"

			else
				menu += "ERROR: Unable to determine current location."
			menu += "<br><br><A href='byond://?src=\ref[src];choice=49'>Refresh GPS Locator</a>"

		if (50) //Cleanbot control
			menu = "<br><h4><img src=pda_cleanbot.png> Cleanbot Interlink</h4>"
			var/obj/item/radio/integrated/cleanbot/SC = radio
			bot_control(SC)

		if (51) //floorbot control
			menu = "<h4><img src=pda_floorbot.png> Floorbot Interlink</h4>"
			var/obj/item/radio/integrated/floorbot/SC = radio
			bot_control(SC)

		if (52) //Medibot control
			menu = "<h4><img src=pda_medbot.png> Medibot Interlink</h4>"
			var/obj/item/radio/integrated/medbot/SC = radio
			bot_control(SC)

/obj/item/weapon/cartridge/Topic(href, href_list)
	..()

	if (!usr.canmove || usr.stat || usr.restrained() || !in_range(loc, usr))
		usr.unset_machine()
		usr << browse(null, "window=pda")
		return

	switch(href_list["choice"])
		if("Medical Records")
			active1 = find_record("id", href_list["target"], data_core.general)
			if(active1)
				active2 = find_record("id", href_list["target"], data_core.medical)
			loc:mode = 441
			mode = 441
			if(!active2)
				active1 = null

		if("Security Records")
			active1 = find_record("id", href_list["target"], data_core.general)
			if(active1)
				active3 = find_record("id", href_list["target"], data_core.security)
			loc:mode = 451
			mode = 451
			if(!active3)
				active1 = null

		if("Send Signal")
			spawn( 0 )
				radio:send_signal("ACTIVATE")
				return

		if("Signal Frequency")
			var/new_frequency = sanitize_frequency(radio:frequency + text2num(href_list["sfreq"]))
			radio:set_frequency(new_frequency)

		if("Signal Code")
			radio:code += text2num(href_list["scode"])
			radio:code = round(radio:code)
			radio:code = min(100, radio:code)
			radio:code = max(1, radio:code)

		if("Status")
			switch(href_list["statdisp"])
				if("message")
					post_status("message", message1, message2)
				if("alert")
					post_status("alert", href_list["alert"])
				if("setmsg1")
					message1 = reject_bad_text(input("Line 1", "Enter Message Text", message1) as text|null, 40)
					updateSelfDialog()
				if("setmsg2")
					message2 = reject_bad_text(input("Line 2", "Enter Message Text", message2) as text|null, 40)
					updateSelfDialog()
				else
					post_status(href_list["statdisp"])
		if("Power Select")
			var/pnum = text2num(href_list["target"])
			powmonitor = powermonitors[pnum]
			loc:mode = 433
			mode = 433

	generate_menu()
	print_to_host(menu)
