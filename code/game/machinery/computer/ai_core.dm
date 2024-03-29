/obj/structure/AIcore
	density = 1
	anchored = 0
	name = "\improper AI core"
	icon = 'icons/mob/AI.dmi'
	icon_state = "0"
	var/state = 0
	var/datum/ai_laws/laws = new()
	var/obj/item/weapon/circuitboard/circuit = null
	var/obj/item/device/mmi/brain = null


/obj/structure/AIcore/attackby(obj/item/P as obj, mob/user as mob)
	switch(state)
		if(0)
			if(istype(P, /obj/item/weapon/wrench))
				playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
				if(do_after(user, 20))
					user << "<span class='notice'>You wrench the frame into place.</span>"
					anchored = 1
					state = 1
			if(istype(P, /obj/item/weapon/weldingtool))
				var/obj/item/weapon/weldingtool/WT = P
				if(!WT.isOn())
					user << "<span class='warning'>The welder must be on for this task.</span>"
					return
				playsound(loc, 'sound/items/Welder.ogg', 50, 1)
				if(do_after(user, 20))
					if(!src || !WT.remove_fuel(0, user)) return
					user << "<span class='notice'>You deconstruct the frame.</span>"
					new /obj/item/stack/sheet/plasteel( loc, 4)
					qdel(src)
		if(1)
			if(istype(P, /obj/item/weapon/wrench))
				playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
				if(do_after(user, 20))
					user << "<span class='notice'>You unfasten the frame.</span>"
					anchored = 0
					state = 0
			if(istype(P, /obj/item/weapon/circuitboard/aicore) && !circuit)
				playsound(loc, 'sound/items/Deconstruct.ogg', 50, 1)
				user << "<span class='notice'>You place the circuit board inside the frame.</span>"
				icon_state = "1"
				circuit = P
				user.drop_item()
				P.loc = src
			if(istype(P, /obj/item/weapon/screwdriver) && circuit)
				playsound(loc, 'sound/items/Screwdriver.ogg', 50, 1)
				user << "<span class='notice'>You screw the circuit board into place.</span>"
				state = 2
				icon_state = "2"
			if(istype(P, /obj/item/weapon/crowbar) && circuit)
				playsound(loc, 'sound/items/Crowbar.ogg', 50, 1)
				user << "<span class='notice'>You remove the circuit board.</span>"
				state = 1
				icon_state = "0"
				circuit.loc = loc
				circuit = null
		if(2)
			if(istype(P, /obj/item/weapon/screwdriver) && circuit)
				playsound(loc, 'sound/items/Screwdriver.ogg', 50, 1)
				user << "<span class='notice'>You unfasten the circuit board.</span>"
				state = 1
				icon_state = "1"
			if(istype(P, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/C = P
				if(C.get_amount() >= 5)
					playsound(loc, 'sound/items/Deconstruct.ogg', 50, 1)
					if(do_after(user, 20))
						if (C.get_amount() >= 5 && state == 2)
							C.use(5)
							user << "<span class='notice'>You add cables to the frame.</span>"
							state = 3
							icon_state = "3"
				else
					user << "<span class='warning'>You need five lengths of cable to wire the AI core.</span>"
					return
		if(3)
			if(istype(P, /obj/item/weapon/wirecutters))
				if (brain)
					user << "<span class='warning'>Get that brain out of there first.</span>"
				else
					playsound(loc, 'sound/items/Wirecutter.ogg', 50, 1)
					user << "<span class='notice'>You remove the cables.</span>"
					state = 2
					icon_state = "2"
					var/obj/item/stack/cable_coil/A = new /obj/item/stack/cable_coil( loc )
					A.amount = 5

			if(istype(P, /obj/item/stack/sheet/rglass))
				var/obj/item/stack/sheet/rglass/G = P
				if(G.get_amount() >= 2)
					playsound(loc, 'sound/items/Deconstruct.ogg', 50, 1)
					if(do_after(user, 20))
						if (G.get_amount() >= 2 && state == 3)
							G.use(2)
							user << "<span class='notice'>You put in the glass panel.</span>"
							state = 4
							icon_state = "4"
				else
					user << "<span class='warning'>You need two sheets of reinforced glass to insert them into AI core.</span>"
					return

			if(istype(P, /obj/item/weapon/aiModule/core/full)) //Allows any full core boards to be applied to AI cores.
				var/obj/item/weapon/aiModule/core/M = P
				laws.clear_inherent_laws()
				for(var/templaw in M.laws)
					laws.add_inherent_law(templaw)
				usr << "<span class='notice'>Law module applied.</span>"

			if(istype(P, /obj/item/weapon/aiModule/reset/purge))
				laws.clear_inherent_laws()
				usr << "<span class='notice'>Laws cleared applied.</span>"


			if(istype(P, /obj/item/weapon/aiModule/supplied/freeform) || istype(P, /obj/item/weapon/aiModule/core/freeformcore))
				var/obj/item/weapon/aiModule/supplied/freeform/M = P
				if(M.laws[1] == "")
					return
				laws.add_inherent_law(M.laws[1])
				usr << "<span class='notice'>Added a freeform law.</span>"

			if(istype(P, /obj/item/device/mmi))
				var/obj/item/device/mmi/M = P
				if(!M.brainmob)
					user << "<span class='warning'>Sticking an empty MMI into the frame would sort of defeat the purpose.</span>"
					return
				if(M.brainmob.stat == 2)
					user << "<span class='warning'>Sticking a dead brain into the frame would sort of defeat the purpose.</span>"
					return

				if((config) && (!config.allow_ai))
					user << "<span class='warning'>This MMI does not seem to fit.</span>"
					return

				if(jobban_isbanned(M.brainmob, "AI"))
					user << "<span class='warning'>This MMI does not seem to fit.</span>"
					return

				if(!M.brainmob.mind)
					user << "<span class='warning'>This MMI is mindless.</span>"
					return

				ticker.mode.remove_cultist(M.brainmob.mind, 1)
				ticker.mode.remove_revolutionary(M.brainmob.mind, 1)
				ticker.mode.remove_gangster(M.brainmob.mind, 1)

				user.drop_item()
				M.loc = src
				brain = M
				usr << "<span class='notice'>Added a brain.</span>"
				icon_state = "3b"

			if(istype(P, /obj/item/weapon/crowbar) && brain)
				playsound(loc, 'sound/items/Crowbar.ogg', 50, 1)
				user << "<span class='notice'>You remove the brain.</span>"
				brain.loc = loc
				brain = null
				icon_state = "3"

		if(4)
			if(istype(P, /obj/item/weapon/crowbar))
				playsound(loc, 'sound/items/Crowbar.ogg', 50, 1)
				user << "<span class='notice'>You remove the glass panel.</span>"
				state = 3
				if (brain)
					icon_state = "3b"
				else
					icon_state = "3"
				new /obj/item/stack/sheet/rglass(loc, 2)
				return

			if(istype(P, /obj/item/weapon/screwdriver))
				playsound(loc, 'sound/items/Screwdriver.ogg', 50, 1)
				user << "<span class='notice'>You connect the monitor.</span>"
				if(!laws.inherent.len) //If laws isn't set to null but nobody supplied a board, the AI would normally be created lawless. We don't want that.
					laws = null
				var/mob/living/silicon/ai/A = new /mob/living/silicon/ai (loc, laws, brain)
				if(A) //if there's no brain, the mob is deleted and a structure/AIcore is created
					A.rename_self("ai", 1)
				feedback_inc("cyborg_ais_created",1)
				qdel(src)

/obj/structure/AIcore/deactivated
	name = "inactive AI"
	icon = 'icons/mob/AI.dmi'
	icon_state = "ai-empty"
	anchored = 1
	state = 20//So it doesn't interact based on the above. Not really necessary.

/obj/structure/AIcore/deactivated/attackby(var/obj/item/A as obj, var/mob/user as mob)
	if(istype(A, /obj/item/device/aicard))//Is it?
		A.transfer_ai("INACTIVE","AICARD",src,user)
	if(istype(A, /obj/item/weapon/wrench))
		playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
		switch(anchored)
			if(0)
				if(do_after(user, 20))
					user << "<span class='notice'>You wrench the core into place.</span>"
					anchored = 1
			if(1)
				if(do_after(user, 20))
					user << "<span class='notice'>You unfasten the core.</span>"
					anchored = 0
	return

/*
This is a good place for AI-related object verbs so I'm sticking it here.
If adding stuff to this, don't forget that an AI need to cancel_camera() whenever it physically moves to a different location.
That prevents a few funky behaviors.
*/
//What operation to perform based on target, what ineraction to perform based on object used, target itself, user. The object used is src and calls this proc.
/obj/item/proc/transfer_ai(var/choice as text, var/interaction as text, var/target, var/mob/U as mob)
	if(!src:flush)
		switch(choice)
			if("AICORE")//AI mob.
				var/mob/living/silicon/ai/T = target
				if(!T.mind)
					U << "<span class='warning'>No intelligence patterns detected.</span>"    //No more magical carding of empty cores, AI RETURN TO BODY!!!11
					return
				switch(interaction)
					if("AICARD")
						var/obj/item/device/aicard/C = src
						if(C.contents.len)//If there is an AI on card.
							U << "<span class='userdanger'>Transfer failed</span>: \black Existing AI found on this terminal. Remove existing AI to install a new one."
						else
							if (ticker.mode.name == "AI malfunction")
								var/datum/game_mode/malfunction/malf = ticker.mode
								for (var/datum/mind/malfai in malf.malf_ai)
									if (T.mind == malfai)
										U << "<span class='userdanger'>ERROR</span>: \black Remote transfer interface disabled."//Do ho ho ho~
										return
							new /obj/structure/AIcore/deactivated(T.loc)//Spawns a deactivated terminal at AI location.
							T.aiRestorePowerRoutine = 0//So the AI initially has power.
							T.control_disabled = 1//Can't control things remotely if you're stuck in a card!
							T.radio_enabled = 0 	//No talking on the built-in radio for you either!
							T.loc = C//Throw AI into the card.
							C.name = "inteliCard - [T.name]"
							if (T.stat == 2)
								C.icon_state = "aicard-404"
							else
								C.icon_state = "aicard-full"
							T.cancel_camera()
							T << "You have been downloaded to a mobile storage device. Remote device connection severed."
							U << "<span class='boldnotice'>Transfer successful</span>: \black [T.name] ([rand(1000,9999)].exe) removed from host terminal and stored within local memory."
					if("NINJASUIT")
						var/obj/item/clothing/suit/space/space_ninja/C = src
						if(C.AI)//If there is an AI on card.
							U << "<span class='userdanger'>Transfer failed</span>: \black Existing AI found on this terminal. Remove existing AI to install a new one."
						else
							if (ticker.mode.name == "AI malfunction")
								var/datum/game_mode/malfunction/malf = ticker.mode
								for (var/datum/mind/malfai in malf.malf_ai)
									if (T.mind == malfai)
										U << "<span class='userdanger'>ERROR</span>: \black Remote transfer interface disabled."
										return
							if(T.stat)//If the ai is dead/dying.
								U << "<span class='userdanger'>ERROR</span>: \black [T.name] data core is corrupted. Unable to install."
							else
								new /obj/structure/AIcore/deactivated(T.loc)
								T.aiRestorePowerRoutine = 0
								T.control_disabled = 1
								T.radio_enabled = 0
								T.loc = C
								C.AI = T
								T.cancel_camera()
								T << "You have been downloaded to a mobile storage device. Remote device connection severed."
								U << "<span class='boldnotice'>Transfer successful</span>: \black [T.name] ([rand(1000,9999)].exe) removed from host terminal and stored within local memory."

			if("INACTIVE")//Inactive AI object.
				var/obj/structure/AIcore/deactivated/T = target
				switch(interaction)
					if("AICARD")
						var/obj/item/device/aicard/C = src
						var/mob/living/silicon/ai/A = locate() in C//I love locate(). Best proc ever.
						if(A)//If AI exists on the card. Else nothing since both are empty.
							A.control_disabled = 0
							A.radio_enabled = 1
							A.loc = T.loc//To replace the terminal.
							C.icon_state = "aicard"
							C.name = "inteliCard"
							C.overlays.Cut()
							A.cancel_camera()
							A << "You have been uploaded to a stationary terminal. Remote device connection restored."
							U << "<span class='boldnotice'>Transfer successful</span>: \black [A.name] ([rand(1000,9999)].exe) installed and executed successfully. Local copy has been removed."
							qdel(T)
					if("NINJASUIT")
						var/obj/item/clothing/suit/space/space_ninja/C = src
						var/mob/living/silicon/ai/A = C.AI
						if(A)
							A.control_disabled = 0
							A.radio_enabled = 1
							C.AI = null
							A.loc = T.loc
							A.cancel_camera()
							A << "You have been uploaded to a stationary terminal. Remote device connection restored."
							U << "<span class='boldnotice'>Transfer successful</span>: \black [A.name] ([rand(1000,9999)].exe) installed and executed successfully. Local copy has been removed."
							qdel(T)
			if("AIFIXER")//AI Fixer terminal.
				var/obj/machinery/computer/aifixer/T = target
				switch(interaction)
					if("AICARD")
						var/obj/item/device/aicard/C = src
						if(!T.contents.len)
							if (!C.contents.len)
								U << "No AI to copy over!"//Well duh
							else for(var/mob/living/silicon/ai/A in C)
								C.icon_state = "aicard"
								C.name = "inteliCard"
								C.overlays.Cut()
								A.loc = T
								T.occupier = A
								A.control_disabled = 1
								A.radio_enabled = 0
								if (A.stat == 2)
									T.overlays += image('icons/obj/computer.dmi', "ai-fixer-404")
								else
									T.overlays += image('icons/obj/computer.dmi', "ai-fixer-full")
								T.overlays -= image('icons/obj/computer.dmi', "ai-fixer-empty")
								A.cancel_camera()
								A << "You have been uploaded to a stationary terminal. Sadly, there is no remote access from here."
								U << "<span class='boldnotice'>Transfer successful</span>: \black [A.name] ([rand(1000,9999)].exe) installed and executed successfully. Local copy has been removed."
						else
							if(!C.contents.len && T.occupier && !T.active)
								C.name = "inteliCard - [T.occupier.name]"
								T.overlays += image('icons/obj/computer.dmi', "ai-fixer-empty")
								if (T.occupier.stat == 2)
									C.icon_state = "aicard-404"
									T.overlays -= image('icons/obj/computer.dmi', "ai-fixer-404")
								else
									C.icon_state = "aicard-full"
									T.overlays -= image('icons/obj/computer.dmi', "ai-fixer-full")
								T.occupier << "You have been downloaded to a mobile storage device. Still no remote access."
								U << "<span class='boldnotice'>Transfer successful</span>: \black [T.occupier.name] ([rand(1000,9999)].exe) removed from host terminal and stored within local memory."
								T.occupier.loc = C
								T.occupier.cancel_camera()
								T.occupier = null
							else if (C.contents.len)
								U << "<span class='userdanger'>ERROR</span>: \black Artificial intelligence detected on terminal."
							else if (T.active)
								U << "<span class='userdanger'>ERROR</span>: \black Reconstruction in progress."
							else if (!T.occupier)
								U << "<span class='userdanger'>ERROR</span>: \black Unable to locate artificial intelligence."
					if("NINJASUIT")
						var/obj/item/clothing/suit/space/space_ninja/C = src
						if(!T.contents.len)
							if (!C.AI)
								U << "No AI to copy over!"
							else
								var/mob/living/silicon/ai/A = C.AI
								A.loc = T
								T.occupier = A
								C.AI = null
								A.control_disabled = 1
								A.radio_enabled = 0
								T.overlays += image('icons/obj/computer.dmi', "ai-fixer-full")
								T.overlays -= image('icons/obj/computer.dmi', "ai-fixer-empty")
								A.cancel_camera()
								A << "You have been uploaded to a stationary terminal. Sadly, there is no remote access from here."
								U << "<span class='boldnotice'>Transfer successful</span>: \black [A.name] ([rand(1000,9999)].exe) installed and executed successfully. Local copy has been removed."
						else
							if(!C.AI && T.occupier && !T.active)
								if (T.occupier.stat)
									U << "<span class='userdanger'>ERROR</span>: \black [T.occupier.name] data core is corrupted. Unable to install."
								else
									T.overlays += image('icons/obj/computer.dmi', "ai-fixer-empty")
									T.overlays -= image('icons/obj/computer.dmi', "ai-fixer-full")
									T.occupier << "You have been downloaded to a mobile storage device. Still no remote access."
									U << "<span class='boldnotice'>Transfer successful</span>: \black [T.occupier.name] ([rand(1000,9999)].exe) removed from host terminal and stored within local memory."
									T.occupier.loc = C
									T.occupier.cancel_camera()
									T.occupier = null
							else if (C.AI)
								U << "<span class='userdanger'>ERROR</span>: \black Artificial intelligence detected on terminal."
							else if (T.active)
								U << "<span class='userdanger'>ERROR</span>: \black Reconstruction in progress."
							else if (!T.occupier)
								U << "<span class='userdanger'>ERROR</span>: \black Unable to locate artificial intelligence."
			if("NINJASUIT")//Ninjasuit
				var/obj/item/clothing/suit/space/space_ninja/T = target
				switch(interaction)
					if("AICARD")
						var/obj/item/device/aicard/C = src
						if(T.s_initialized&&U==T.affecting)//If the suit is initialized and the actor is the user.

							var/mob/living/silicon/ai/A_T = locate() in C//Determine if there is an AI on target card. Saves time when checking later.
							var/mob/living/silicon/ai/A = T.AI//Deterine if there is an AI in suit.

							if(A)//If the host AI card is not empty.
								if(A_T)//If there is an AI on the target card.
									U << "<span class='userdanger'>ERROR</span>: \black [A_T.name] already installed. Remove [A_T.name] to install a new one."
								else
									A.loc = C//Throw them into the target card. Since they are already on a card, transfer is easy.
									C.name = "inteliCard - [A.name]"
									C.icon_state = "aicard-full"
									T.AI = null
									A.cancel_camera()
									A << "You have been uploaded to a mobile storage device."
									U << "<span class='boldnotice'>SUCCESS</span>: \black [A.name] ([rand(1000,9999)].exe) removed from host and stored within local memory."
							else//If host AI is empty.
								if(C.flush)//If the other card is flushing.
									U << "<span class='userdanger'>ERROR</span>: \black AI flush is in progress, cannot execute transfer protocol."
								else
									if(A_T&&!A_T.stat)//If there is an AI on the target card and it's not inactive.
										A_T.loc = T//Throw them into suit.
										C.icon_state = "aicard"
										C.name = "inteliCard"
										C.overlays.Cut()
										T.AI = A_T
										A_T.cancel_camera()
										A_T << "You have been uploaded to a mobile storage device."
										U << "<span class='boldnotice'>SUCCESS</span>: \black [A_T.name] ([rand(1000,9999)].exe) removed from local memory and installed to host."
									else if(A_T)//If the target AI is dead. Else just go to return since nothing would happen if both are empty.
										U << "<span class='userdanger'>ERROR</span>: \black [A_T.name] data core is corrupted. Unable to install."
	else
		U << "<span class='userdanger'>ERROR</span>: \black AI flush is in progress, cannot execute transfer protocol."
	return