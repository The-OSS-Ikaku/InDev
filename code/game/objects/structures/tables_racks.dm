/* Tables and Racks
 * Contains:
 *		Tables
 *		Wooden tables
 *		Reinforced tables
 *		Racks
 */


/*
 * Tables
 */

/obj/structure/table
	name = "table"
	desc = "A square piece of metal standing on four metal legs. It can not move."
	icon = 'icons/obj/structures.dmi'
	icon_state = "table"
	density = 1
	anchored = 1.0
	layer = 2.8
	throwpass = 1	//You can throw objects over this, despite it's density.")
	var/parts = /obj/item/weapon/table_parts
	var/busy = 0

/obj/structure/table/New()
	..()
	for(var/obj/structure/table/T in src.loc)
		if(T != src)
			qdel(T)
	update_icon()
	for(var/direction in list(1,2,4,8,5,6,9,10))
		if(locate(/obj/structure/table,get_step(src,direction)))
			var/obj/structure/table/T = locate(/obj/structure/table,get_step(src,direction))
			T.update_icon()

/obj/structure/table/Destroy()
	for(var/direction in list(1,2,4,8,5,6,9,10))
		if(locate(/obj/structure/table,get_step(src,direction)))
			var/obj/structure/table/T = locate(/obj/structure/table,get_step(src,direction))
			T.update_icon()
	..()

/obj/structure/table/update_icon()
	spawn(2) //So it properly updates when deleting
		var/dir_sum = 0
		for(var/direction in list(1,2,4,8,5,6,9,10))
			var/skip_sum = 0
			for(var/obj/structure/window/W in src.loc)
				if(W.dir == direction) //So smooth tables don't go smooth through windows
					skip_sum = 1
					continue
			var/inv_direction //inverse direction
			switch(direction)
				if(1)
					inv_direction = 2
				if(2)
					inv_direction = 1
				if(4)
					inv_direction = 8
				if(8)
					inv_direction = 4
				if(5)
					inv_direction = 10
				if(6)
					inv_direction = 9
				if(9)
					inv_direction = 6
				if(10)
					inv_direction = 5
			for(var/obj/structure/window/W in get_step(src,direction))
				if(W.dir == inv_direction) //So smooth tables don't go smooth through windows when the window is on the other table's tile
					skip_sum = 1
					continue
			if(!skip_sum) //means there is a window between the two tiles in this direction
				if(locate(/obj/structure/table,get_step(src,direction)))
					if(direction <5)
						dir_sum += direction
					else
						if(direction == 5)	//This permits the use of all table directions. (Set up so clockwise around the central table is a higher value, from north)
							dir_sum += 16
						if(direction == 6)
							dir_sum += 32
						if(direction == 8)	//Aherp and Aderp.  Jezes I am stupid.  -- SkyMarshal
							dir_sum += 8
						if(direction == 10)
							dir_sum += 64
						if(direction == 9)
							dir_sum += 128

		var/table_type = 0 //stand_alone table
		if(dir_sum%16 in cardinal)
			table_type = 1 //endtable
			dir_sum %= 16
		if(dir_sum%16 in list(3,12))
			table_type = 2 //1 tile thick, streight table
			if(dir_sum%16 == 3) //3 doesn't exist as a dir
				dir_sum = 2
			if(dir_sum%16 == 12) //12 doesn't exist as a dir.
				dir_sum = 4
		if(dir_sum%16 in list(5,6,9,10))
			if(locate(/obj/structure/table,get_step(src.loc,dir_sum%16)))
				table_type = 3 //full table (not the 1 tile thick one, but one of the 'tabledir' tables)
			else
				table_type = 2 //1 tile thick, corner table (treated the same as streight tables in code later on)
			dir_sum %= 16
		if(dir_sum%16 in list(13,14,7,11)) //Three-way intersection
			table_type = 5 //full table as three-way intersections are not sprited, would require 64 sprites to handle all combinations.  TOO BAD -- SkyMarshal
			switch(dir_sum%16)	//Begin computation of the special type tables.  --SkyMarshal
				if(7)
					if(dir_sum == 23)
						table_type = 6
						dir_sum = 8
					else if(dir_sum == 39)
						dir_sum = 4
						table_type = 6
					else if(dir_sum == 55 || dir_sum == 119 || dir_sum == 247 || dir_sum == 183)
						dir_sum = 4
						table_type = 3
					else
						dir_sum = 4
				if(11)
					if(dir_sum == 75)
						dir_sum = 5
						table_type = 6
					else if(dir_sum == 139)
						dir_sum = 9
						table_type = 6
					else if(dir_sum == 203 || dir_sum == 219 || dir_sum == 251 || dir_sum == 235)
						dir_sum = 8
						table_type = 3
					else
						dir_sum = 8
				if(13)
					if(dir_sum == 29)
						dir_sum = 10
						table_type = 6
					else if(dir_sum == 141)
						dir_sum = 6
						table_type = 6
					else if(dir_sum == 189 || dir_sum == 221 || dir_sum == 253 || dir_sum == 157)
						dir_sum = 1
						table_type = 3
					else
						dir_sum = 1
				if(14)
					if(dir_sum == 46)
						dir_sum = 1
						table_type = 6
					else if(dir_sum == 78)
						dir_sum = 2
						table_type = 6
					else if(dir_sum == 110 || dir_sum == 254 || dir_sum == 238 || dir_sum == 126)
						dir_sum = 2
						table_type = 3
					else
						dir_sum = 2 //These translate the dir_sum to the correct dirs from the 'tabledir' icon_state.
		if(dir_sum%16 == 15)
			table_type = 4 //4-way intersection, the 'middle' table sprites will be used.
		switch(table_type)
			if(0)
				icon_state = "[initial(icon_state)]"
			if(1)
				icon_state = "[initial(icon_state)]_1tileendtable"
			if(2)
				icon_state = "[initial(icon_state)]_1tilethick"
			if(3)
				icon_state = "[initial(icon_state)]_dir"
			if(4)
				icon_state = "[initial(icon_state)]_middle"
			if(5)
				icon_state = "[initial(icon_state)]_dir2"
			if(6)
				icon_state = "[initial(icon_state)]_dir3"
		if (dir_sum in list(1,2,4,8,5,6,9,10))
			dir = dir_sum
		else
			dir = 2

/obj/structure/table/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				qdel(src)
				return
		if(3.0)
			if (prob(25))
				src.density = 0
		else
	return


/obj/structure/table/blob_act()
	if(prob(75))
		if(istype(src, /obj/structure/table/woodentable))
			new /obj/item/weapon/table_parts/wood( src.loc )
			qdel(src)
			return
		new /obj/item/weapon/table_parts( src.loc )
		qdel(src)
		return

/obj/structure/table/attack_paw(mob/user)
	if(HULK in user.mutations)
		user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
		visible_message("<span class='danger'>[user] smashes the table apart!</span>")
		if(istype(src, /obj/structure/table/reinforced))
			new /obj/item/weapon/table_parts/reinforced(loc)
		else if(istype(src, /obj/structure/table/woodentable))
			new/obj/item/weapon/table_parts/wood(loc)
		else
			new /obj/item/weapon/table_parts(loc)
		density = 0
		qdel(src)


/obj/structure/table/attack_alien(mob/user)
	visible_message("<span class='danger'>[user] slices [src] apart!</span>")
	if(istype(src, /obj/structure/table/reinforced))
		new /obj/item/weapon/table_parts/reinforced(loc)
	else if(istype(src, /obj/structure/table/woodentable))
		new/obj/item/weapon/table_parts/wood(loc)
	else
		new /obj/item/weapon/table_parts(loc)
	density = 0
	qdel(src)


/obj/structure/table/attack_animal(mob/living/simple_animal/user)
	if(user.environment_smash)
		visible_message("<span class='danger'>[user] smashes [src] apart!</span>")
		if(istype(src, /obj/structure/table/reinforced))
			new /obj/item/weapon/table_parts/reinforced(loc)
		else if(istype(src, /obj/structure/table/woodentable))
			new/obj/item/weapon/table_parts/wood(loc)
		else
			new /obj/item/weapon/table_parts(loc)
		density = 0
		qdel(src)




/obj/structure/table/attack_hand(mob/user)
	if(HULK in user.mutations)
		visible_message("<span class='danger'>[user] smashes [src] apart!</span>")
		user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
		if(istype(src, /obj/structure/table/reinforced))
			new /obj/item/weapon/table_parts/reinforced(loc)
		else if(istype(src, /obj/structure/table/woodentable))
			new/obj/item/weapon/table_parts/wood(loc)
		else
			new /obj/item/weapon/table_parts(loc)
		density = 0
		qdel(src)
	else
		..()

/obj/structure/table/attack_tk() // no telehulk sorry
	return

/obj/structure/table/CanPass(atom/movable/mover, turf/target, height=0)
	if(height==0) return 1

	if(istype(mover) && mover.checkpass(PASSTABLE))
		return 1
	if(locate(/obj/structure/table) in get_turf(mover))
		return 1
	else
		return 0


/obj/structure/table/MouseDrop_T(obj/O, mob/user)
	if ((!( istype(O, /obj/item/weapon) ) || user.get_active_hand() != O))
		return
	if(isrobot(user))
		return
	if(!user.drop_item())
		return
	if (O.loc != src.loc)
		step(O, get_dir(O, src))
	return


/obj/structure/table/attackby(obj/item/I, mob/user)
	if (istype(I, /obj/item/weapon/grab))
		if(get_dist(src, user) < 2)
			var/obj/item/weapon/grab/G = I
			if(G.affecting.buckled)
				user << "<span class='notice'>[G.affecting] is buckled to [G.affecting.buckled]!</span>"
				return
			if(G.state < GRAB_AGGRESSIVE)
				user << "<span class='notice'>You need a better grip to do that!</span>"
				return
			if(!G.confirm())
				return
			G.affecting.loc = src.loc
			G.affecting.Weaken(5)
			G.affecting.visible_message("<span class='danger'>[G.assailant] pushes [G.affecting] onto [src].</span>", \
										"<span class='userdanger'>[G.assailant] pushes [G.affecting] onto [src].</span>")
		qdel(I)
		return

	if (istype(I, /obj/item/weapon/wrench))
		if(istype(src, /obj/structure/table/reinforced))
			var/obj/structure/table/reinforced/RT = src
			if(RT.status == 1)
				table_destroy(2, user)
				return
		else
			table_destroy(2, user)
			return

	if (istype(I, /obj/item/weapon/storage/bag/tray))
		var/obj/item/weapon/storage/bag/tray/T = I
		if(T.contents.len > 0) // If the tray isn't empty
			var/list/obj/item/oldContents = T.contents.Copy()
			T.quick_empty()

			for(var/obj/item/C in oldContents)
				C.loc = src.loc

			user.visible_message("<span class='notice'>[user] empties [I] on [src].</span>")
			return
		// If the tray IS empty, continue on (tray will be placed on the table like other items)

	if(isrobot(user))
		return

	if(istype(I, /obj/item/weapon/melee/energy/blade))
		var/datum/effect/effect/system/spark_spread/SS = new /datum/effect/effect/system/spark_spread()
		SS.set_up(5, 0, src.loc)
		SS.start()
		playsound(src.loc, 'sound/weapons/blade1.ogg', 50, 1)
		playsound(src.loc, "sparks", 50, 1)
		table_destroy(1, user)
		return

	if(!(I.flags & ABSTRACT)) //rip more parems rip in peace ;_;
		if(user.drop_item())
			I.Move(loc)

/obj/structure/table/proc/table_destroy(var/destroy_type, var/mob/user as mob)

/*
Destroy type values:
1 = Destruction, Actually destroyed
2 = Deconstruction.
*/

	if(destroy_type == 1)
		user.visible_message("<span class='notice'>The table was sliced apart by [user]!</span>")
		new parts( src.loc )
		qdel(src)
		return

	if(destroy_type == 2)
		user << "<span class='notice'>Now disassembling the [src.name]</span>"
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		if (do_after(user, 50))
			new parts( src.loc )
			playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
			qdel(src)
		return



/*
 * Wooden tables
 */
/obj/structure/table/woodentable
	name = "wooden table"
	desc = "Do not apply fire to this. Rumour says it burns easily."
	icon_state = "woodtable"
	parts = /obj/item/weapon/table_parts/wood


/obj/structure/table/woodentable/poker //No specialties, Just a mapping object.
	name = "gambling table"
	desc = "A seedy table for seedy dealings in seedy places."
	icon_state = "pokertable"
	parts = /obj/item/weapon/table_parts/wood/poker

/*
 * Reinforced tables
 */
/obj/structure/table/reinforced
	name = "reinforced table"
	desc = "A version of the four legged table. It is stronger."
	icon_state = "reinftable"
	parts = /obj/item/weapon/table_parts/reinforced
	var/status = 2


/obj/structure/table/reinforced/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.remove_fuel(0, user))
			if(src.status == 2)
				user << "<span class='notice'>Now weakening the reinforced table</span>"
				playsound(src.loc, 'sound/items/Welder.ogg', 50, 1)
				if (do_after(user, 50))
					if(!src || !WT.isOn()) return
					user << "<span class='notice'>Table weakened</span>"
					src.status = 1
			else
				user << "<span class='notice'>Now strengthening the reinforced table</span>"
				playsound(src.loc, 'sound/items/Welder.ogg', 50, 1)
				if (do_after(user, 50))
					if(!src || !WT.isOn()) return
					user << "<span class='notice'>Table strengthened</span>"
					src.status = 2
			return
	..()

/obj/structure/table/MouseDrop_T(mob/target, mob/living/carbon/human/user)
	if(istype(target) && user == target && istype(user))
		if(user.canmove)
			climb_table(user)

/obj/structure/table/proc/climb_table(mob/user)
	src.add_fingerprint(user)
	user.visible_message("<span class='warning'>[user] starts climbing onto [src].</span>", \
								"<span class='notice'>[user] starts climbing onto [src].</span>")
	if(do_mob(user, user, 20))
		user.pass_flags += PASSTABLE
		step(user,get_dir(user,src.loc))
		user.pass_flags -= PASSTABLE
		user.visible_message("<span class='warning'>[user] climbs onto [src].</span>", \
									"<span class='notice'>[user] climbs onto [src].</span>")
		add_logs(user, src, "climbed onto")
		user.Stun(2)

/*
 * Racks
 */
/obj/structure/rack
	name = "rack"
	desc = "Different from the Middle Ages version."
	icon = 'icons/obj/objects.dmi'
	icon_state = "rack"
	density = 1
	anchored = 1.0
	throwpass = 1	//You can throw objects over this, despite it's density.

/obj/structure/rack/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
		if(2.0)
			qdel(src)
			if(prob(50))
				new /obj/item/weapon/rack_parts(src.loc)
		if(3.0)
			if(prob(25))
				qdel(src)
				new /obj/item/weapon/rack_parts(src.loc)

/obj/structure/rack/blob_act()
	if(prob(75))
		qdel(src)
		return
	else if(prob(50))
		new /obj/item/weapon/rack_parts(src.loc)
		qdel(src)
		return

/obj/structure/rack/CanPass(atom/movable/mover, turf/target, height=0)
	if(height==0) return 1
	if(src.density == 0) //Because broken racks -Agouri |TODO: SPRITE!|
		return 1
	if(istype(mover) && mover.checkpass(PASSTABLE))
		return 1
	else
		return 0

/obj/structure/rack/MouseDrop_T(obj/O as obj, mob/user as mob)
	if ((!( istype(O, /obj/item/weapon) ) || user.get_active_hand() != O))
		return
	if(isrobot(user))
		return
	if(!user.drop_item())
		user << "<span class='notice'>\The [O] is stuck to your hand, you cannot put it in the rack!</span>"
		return
	if (O.loc != src.loc)
		step(O, get_dir(O, src))
	return

/obj/structure/rack/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/wrench))
		new /obj/item/weapon/rack_parts( src.loc )
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		qdel(src)
		return

	if(isrobot(user))
		return
	if(!user.drop_item())
		user << "<span class='notice'>\The [W] is stuck to your hand, you cannot put it in the rack!</span>"
		return
	if(W && W.loc)	W.loc = src.loc
	return 1


/obj/structure/rack/attack_hand(mob/user)
	if(HULK in user.mutations)
		visible_message("<span class='danger'>[user] smashes [src] apart!</span>")
		user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
		new /obj/item/weapon/rack_parts(loc)
		density = 0
		qdel(src)


/obj/structure/rack/attack_paw(mob/user)
	if(HULK in user.mutations)
		user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
		visible_message("<span class='danger'>[user] smashes [src] apart!</span>")
		new /obj/item/weapon/rack_parts(loc)
		density = 0
		qdel(src)


/obj/structure/rack/attack_alien(mob/user)
	visible_message("<span class='danger'>[user] slices [src] apart!</span>")
	new /obj/item/weapon/rack_parts(loc)
	density = 0
	qdel(src)


/obj/structure/rack/attack_animal(mob/living/simple_animal/user)
	if(user.environment_smash)
		visible_message("<span class='danger'>[user] smashes [src] apart!</span>")
		new /obj/item/weapon/rack_parts(loc)
		density = 0
		qdel(src)
/obj/structure/rack/attack_tk() // no telehulk sorry
	return
