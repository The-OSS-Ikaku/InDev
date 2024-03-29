/obj/machinery/door/window
	name = "interior door"
	desc = "A strong door."
	icon = 'icons/obj/doors/windoor.dmi'
	icon_state = "left"
	var/base_state = "left"
	var/health = 150.0 //If you change this, consider changing ../door/window/brigdoor/ health at the bottom of this .dm file
	visible = 0.0
	flags = ON_BORDER
	opacity = 0
	var/obj/item/weapon/airlock_electronics/electronics = null
	explosion_resistance = 5

/obj/machinery/door/window/New()
	..()

	if (src.req_access && src.req_access.len)
		src.icon_state = "[src.icon_state]"
		src.base_state = src.icon_state
	return

/obj/machinery/door/window/Destroy()
	density = 0
	if(health == 0)
		playsound(src, "shatter", 70, 1)
	..()


/obj/machinery/door/window/proc/open_and_close()
	open()
	if(src.check_access(null))
		sleep(50)
	else //secure doors close faster
		sleep(20)
	close()

/obj/machinery/door/window/Bumped(atom/movable/AM as mob|obj)
	if( operating || !src.density )
		return
	if (!( ismob(AM) ))
		var/obj/machinery/bot/bot = AM
		if(istype(bot))
			if(src.check_access(bot.botcard))
				open_and_close()
			else
				flick(text("[]deny", src.base_state), src)
		else if(istype(AM, /obj/mecha))
			var/obj/mecha/mecha = AM
			if(mecha.occupant && src.allowed(mecha.occupant))
				open_and_close()
			else
				flick(text("[]deny", src.base_state), src)
		return
	if (!( ticker ))
		return
	var/mob/M = AM
	if(!M.restrained())
		bumpopen(M)
	return

/obj/machinery/door/window/bumpopen(mob/user as mob)
	if( operating || !src.density )
		return
	src.add_fingerprint(user)
	if(!src.requiresID())
		user = null

	if(allowed(user))
		open_and_close()
	else
		flick(text("[]deny", src.base_state), src)
	return

/obj/machinery/door/window/CanPass(atom/movable/mover, turf/target, height=0)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	if(get_dir(loc, target) == dir) //Make sure looking at appropriate border
		return !density
	else
		return 1

/obj/machinery/door/window/CanAtmosPass(var/turf/T)
	if(get_dir(loc, T) == dir)
		return !density
	else
		return 1

//used in the AStar algorithm to determinate if the turf the door is on is passable
/obj/machinery/door/window/CanAStarPass(var/obj/item/weapon/card/id/ID, var/to_dir)
	return !density || (dir != to_dir) || check_access(ID)

/obj/machinery/door/window/CheckExit(atom/movable/mover as mob|obj, turf/target as turf)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	if(get_dir(loc, target) == dir)
		return !density
	else
		return 1

/obj/machinery/door/window/open(var/forced=0)
	if (src.operating == 1) //doors can still open when emag-disabled
		return 0
	if (!ticker)
		return 0
	if(!forced)
		if(!hasPower())
			return 0
	if(forced < 2)
		if(emagged)
			return 0
	if(!src.operating) //in case of emag
		src.operating = 1
	flick(text("[]opening", src.base_state), src)
	playsound(src.loc, 'sound/machines/windowdoor.ogg', 100, 1)
	src.icon_state = text("[]open", src.base_state)
	sleep(10)

	explosion_resistance = 0
	src.density = 0
//	src.sd_SetOpacity(0)	//TODO: why is this here? Opaque windoors? ~Carn
	air_update_turf(1)
	update_freelook_sight()

	if(operating == 1) //emag again
		src.operating = 0
	return 1

/obj/machinery/door/window/close(var/forced=0)
	if (src.operating)
		return 0
	if(!forced)
		if(!hasPower())
			return 0
	if(forced < 2)
		if(emagged)
			return 0
	src.operating = 1
	flick(text("[]closing", src.base_state), src)
	playsound(src.loc, 'sound/machines/windowdoor.ogg', 100, 1)
	src.icon_state = src.base_state

	src.density = 1
	explosion_resistance = initial(explosion_resistance)
//	if(src.visible)
//		SetOpacity(1)	//TODO: why is this here? Opaque windoors? ~Carn
	air_update_turf(1)
	update_freelook_sight()
	sleep(10)

	src.operating = 0
	return 1

/obj/machinery/door/window/proc/take_damage(var/damage)
	src.health = max(0, src.health - damage)
	if (src.health <= 0)
		var/debris = list(
			new /obj/item/weapon/shard(src.loc),
			new /obj/item/weapon/shard(src.loc),
			new /obj/item/stack/rods(src.loc, 2),
			new /obj/item/stack/cable_coil(src.loc, 2)
			)
		for(var/obj/fragment in debris)
			transfer_fingerprints_to(fragment)
		src.density = 0
		qdel(src)
		return

/obj/machinery/door/window/bullet_act(var/obj/item/projectile/Proj)
	if(Proj.damage)
		if((Proj.damage_type == BRUTE || Proj.damage_type == BURN))
			take_damage(round(Proj.damage / 2))
	..()

//When an object is thrown at the window
/obj/machinery/door/window/hitby(AM as mob|obj)

	..()
	visible_message("<span class='danger'>\The [src] was hit by \the [AM].</span>")
	var/tforce = 0
	if(ismob(AM))
		tforce = 40
	else
		tforce = AM:throwforce
	playsound(src.loc, 'sound/effects/Glasshit.ogg', 100, 1)
	take_damage(tforce)
	//..() //Does this really need to be here twice? The parent proc doesn't even do anything yet. - Nodrak
	return


/obj/machinery/door/window/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/door/window/proc/attack_generic(mob/user as mob, damage = 0)
	if(src.operating)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	playsound(src.loc, 'sound/effects/Glasshit.ogg', 75, 1)
	user.visible_message("<span class='danger'>[user] smashes against the [src.name].</span>", \
				"<span class='userdanger'>[user] smashes against the [src.name].</span>")
	take_damage(damage)

/obj/machinery/door/window/attack_alien(mob/user as mob)
	if(islarva(user))
		return
	attack_generic(user, 25)

/obj/machinery/door/window/attack_animal(mob/user as mob)
	if(!isanimal(user))
		return
	var/mob/living/simple_animal/M = user
	if(M.melee_damage_upper <= 0)
		return
	attack_generic(M, M.melee_damage_upper)


/obj/machinery/door/window/attack_slime(mob/living/carbon/slime/user as mob)
	if(!user.is_adult)
		return
	attack_generic(user, 25)

/obj/machinery/door/window/attack_paw(mob/user as mob)
		return src.attack_hand(user)

/obj/machinery/door/window/attack_hand(mob/user as mob)
	return src.attackby(user, user)

/obj/machinery/door/window/attackby(obj/item/weapon/I as obj, mob/user as mob)

	//If it's in the process of opening/closing, ignore the click
	if (src.operating)
		return

	add_fingerprint(user)

	//Emags and ninja swords? You may pass.
	if (src.density && (istype(I, /obj/item/weapon/card/emag)||istype(I, /obj/item/weapon/melee/energy/blade)))
		src.operating = -1
		flick("[src.base_state]spark", src)
		sleep(6)
		desc += "<BR><span class='warning'>Its access panel is smoking slightly.</span>"
		if(istype(I, /obj/item/weapon/melee/energy/blade))
			var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
			spark_system.set_up(5, 0, src.loc)
			spark_system.start()
			playsound(src.loc, "sparks", 50, 1)
			playsound(src.loc, 'sound/weapons/blade1.ogg', 50, 1)
			visible_message("<span class='warning'> The glass door was sliced open by [user]!</span>")
			open(2)
			emagged = 1
			return 1
		open()
		emagged = 1
		return 1

	if(istype(I, /obj/item/weapon/screwdriver))
		if(src.density || src.operating)
			user << "<span class='warning'>You need to open the door to access the maintenance panel.</span>"
			return
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
		src.p_open = !( src.p_open )
		user << "<span class='notice'>You [p_open ? "open":"close"] the maintenance panel of the [src.name].</span>"
		return

	if(istype(I, /obj/item/weapon/crowbar))
		if(p_open && !src.density && !src.operating)
			playsound(src.loc, 'sound/items/Crowbar.ogg', 100, 1)
			user.visible_message("<span class='warning'>[user] removes the electronics from the [src.name].</span>", \
								 "You start to remove electronics from the [src.name].")
			if(do_after(user,40))
				if(src.p_open && !src.density && !src.operating && src.loc)
					var/obj/structure/windoor_assembly/WA = new /obj/structure/windoor_assembly(src.loc)
					switch(base_state)
						if("left")
							WA.facing = "l"
						if("right")
							WA.facing = "r"
						if("leftsecure")
							WA.facing = "l"
							WA.secure = 1
						if("rightsecure")
							WA.facing = "r"
							WA.secure = 1
					WA.anchored = 1
					WA.state= "02"
					WA.dir = src.dir
					WA.ini_dir = src.dir
					WA.update_icon()
					WA.created_name = src.name

					if(emagged)
						user << "<span class='warning'>You discard the damaged electronics.</span>"
						qdel(src)
						return

					user << "<span class='notice'>You removed the airlock electronics!</span>"

					var/obj/item/weapon/airlock_electronics/ae
					if(!electronics)
						ae = new/obj/item/weapon/airlock_electronics( src.loc )
						if(req_one_access)
							ae.use_one_access = 1
							ae.conf_access = src.req_one_access
						else
							ae.conf_access = src.req_access
					else
						ae = electronics
						electronics = null
						ae.loc = src.loc

					qdel(src)
			return


	//If windoor is unpowered, crowbar, fireaxe and armblade can force it.
	if(istype(I, /obj/item/weapon/crowbar) || istype(I, /obj/item/weapon/twohanded/fireaxe) || istype(I, /obj/item/weapon/melee/arm_blade) )
		if(!hasPower())
			if(src.density)
				open(2)
			else
				close(2)
			return

	//If it's a weapon, smash windoor. Unless it's an id card, agent card, ect.. then ignore it (Cards really shouldnt damage a door anyway)
	if(src.density && istype(I, /obj/item/weapon) && !istype(I, /obj/item/weapon/card) )
		user.changeNext_move(CLICK_CD_MELEE)
		if( (I.flags&NOBLUDGEON) || !I.force )
			return
		var/aforce = I.force
		playsound(src.loc, 'sound/effects/Glasshit.ogg', 75, 1)
		visible_message("<span class='danger'>\The [src] has been hit by [user] with [I].</span>")
		if(I.damtype == BURN || I.damtype == BRUTE)
			take_damage(aforce)
		return

	if (!src.requiresID())
		//don't care who they are or what they have, act as if they're NOTHING
		user = null

	if (src.allowed(user))
		if (src.density)
			open()
		else
			close()

	else if (src.density)
		flick(text("[]deny", src.base_state), src)

	return



/obj/machinery/door/window/brigdoor
	name = "secure door"
	icon = 'icons/obj/doors/windoor.dmi'
	icon_state = "leftsecure"
	base_state = "leftsecure"
	var/id = null
	health = 300.0 //Stronger doors for prison (regular window door health is 200)


/obj/machinery/door/window/northleft
	dir = NORTH

/obj/machinery/door/window/eastleft
	dir = EAST

/obj/machinery/door/window/westleft
	dir = WEST

/obj/machinery/door/window/southleft
	dir = SOUTH

/obj/machinery/door/window/northright
	dir = NORTH
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/eastright
	dir = EAST
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/westright
	dir = WEST
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/southright
	dir = SOUTH
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/brigdoor/northleft
	dir = NORTH

/obj/machinery/door/window/brigdoor/eastleft
	dir = EAST

/obj/machinery/door/window/brigdoor/westleft
	dir = WEST

/obj/machinery/door/window/brigdoor/southleft
	dir = SOUTH

/obj/machinery/door/window/brigdoor/northright
	dir = NORTH
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/eastright
	dir = EAST
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/westright
	dir = WEST
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/southright
	dir = SOUTH
	icon_state = "rightsecure"
	base_state = "rightsecure"
