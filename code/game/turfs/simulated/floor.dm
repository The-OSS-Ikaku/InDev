//This is so damaged or burnt tiles or platings don't get remembered as the default tile
var/list/icons_to_ignore_at_floor_init = list("damaged1","damaged2","damaged3","damaged4",
				"damaged5","panelscorched","floorscorched1","floorscorched2","platingdmg1","platingdmg2",
				"platingdmg3","plating","light_on","light_on_flicker1","light_on_flicker2",
				"light_on_clicker3","light_on_clicker4","light_on_clicker5","light_broken",
				"light_on_broken","light_off","wall_thermite","grass1","grass2","grass3","grass4",
				"asteroid","asteroid_dug",
				"asteroid0","asteroid1","asteroid2","asteroid3","asteroid4",
				"asteroid5","asteroid6","asteroid7","asteroid8","asteroid9","asteroid10","asteroid11","asteroid12",
				"oldburning","light-on-r","light-on-y","light-on-g","light-on-b", "wood", "wood-broken",
				"carpetcorner", "carpetside", "carpet", "ironsand1", "ironsand2", "ironsand3", "ironsand4", "ironsand5",
				"ironsand6", "ironsand7", "ironsand8", "ironsand9", "ironsand10", "ironsand11",
				"ironsand12", "ironsand13", "ironsand14", "ironsand15")

/turf/simulated/floor
	//NOTE: Floor code has been refactored, many procs were removed
	//using intact should be safe, you can also use istype
	//also worhy of note: floor_tile is now a path, and not a tile obj
	//future improvements:
	//- move fancy_update() to a new /turf/simulated/floor/fancy
	//- move the default floor to /turf/simulated/floor/plasteel
	//- unsnowflake the light floors somehow
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "floor"

	var/icon_regular_floor = "floor" //used to remember what icon the tile should have by default
	var/icon_plating = "plating"
	thermal_conductivity = 0.040
	heat_capacity = 10000
	intact = 1
	var/lava = 0
	var/broken = 0
	var/burnt = 0
	var/floor_tile = /obj/item/stack/tile/plasteel
	var/obj/item/stack/tile/builtin_tile = null //needed for performance reasons when the singularity rips off floor tiles
	var/list/broken_states = list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5")
	var/list/burnt_states = list()

/turf/simulated/floor/New()
	..()
	if(icon_state in icons_to_ignore_at_floor_init) //so damaged/burned tiles or plating icons aren't saved as the default
		icon_regular_floor = "floor"
	else
		icon_regular_floor = icon_state
	if(floor_tile)
		builtin_tile = new floor_tile

//turf/simulated/floor/CanPass(atom/movable/mover, turf/target, height=0)
//	if ((istype(mover, /obj/machinery/vehicle) && !(src.burnt)))
//		if (!( locate(/obj/machinery/mass_driver, src) ))
//			return 0
//	return ..()

/turf/simulated/floor/ex_act(severity)
	switch(severity)
		if(1.0)
			src.ChangeTurf(/turf/space)
		if(2.0)
			switch(pick(1,2;75,3))
				if (1)
					src.ReplaceWithLattice()
					if(prob(33)) new /obj/item/stack/sheet/metal(src)
				if(2)
					src.ChangeTurf(/turf/space)
				if(3)
					if(prob(80))
						src.break_tile_to_plating()
					else
						src.break_tile()
					src.hotspot_expose(1000,CELL_VOLUME)
					if(prob(33)) new /obj/item/stack/sheet/metal(src)
		if(3.0)
			if (prob(50))
				src.break_tile()
				src.hotspot_expose(1000,CELL_VOLUME)
	return

/turf/simulated/floor/blob_act()
	return

/turf/simulated/floor/proc/update_icon()
	if(lava)
		return 0
	else if(is_plasteel_floor())
		if(!broken && !burnt)
			icon_state = icon_regular_floor
		return 0
	if(air)
		update_visuals(air)
	return 1

/turf/simulated/floor/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/turf/simulated/floor/proc/gets_drilled()
	return

/turf/simulated/floor/is_plasteel_floor()
	if(ispath(floor_tile, /obj/item/stack/tile/plasteel))
		return 1
	else
		return 0

//updates neighboring carpet & grass
/turf/simulated/floor/proc/fancy_update(fancy_type)
	for(var/direction in list(1,2,4,8,5,6,9,10))
		if(istype(get_step(src,direction), fancy_type))
			var/turf/simulated/floor/FF = get_step(src,direction)
			FF.update_icon()

/turf/simulated/floor/proc/break_tile_to_plating()
	var/turf/simulated/floor/plating/T = make_plating()
	T.break_tile()

/turf/simulated/floor/proc/break_tile()
	if(broken)
		return
	icon_state = pick(broken_states)
	broken = 1

/turf/simulated/floor/proc/burn_tile()
	if(broken || burnt)
		return
	if(is_plasteel_floor())
		icon_state = "floorscorched[pick(1,2)]"
	else if(!burnt_states.len)
		icon_state = pick(burnt_states)
	else
		icon_state = pick(broken_states)
	burnt = 1

/turf/simulated/floor/proc/make_plating()
	return make_floor(/turf/simulated/floor/plating)

//wrapper for ChangeTurf that handles flooring properly
/turf/simulated/floor/proc/make_floor(turf/simulated/floor/T as turf)
	SetLuminosity(0)
	var/old_type = type
	var/old_icon = icon_regular_floor
	var/old_dir = dir
	var/turf/simulated/floor/W = ChangeTurf(T)
	W.icon_regular_floor = old_icon
	W.dir = old_dir
	W.update_icon()
	W.fancy_update(old_type)
	return W

/turf/simulated/floor/attackby(obj/item/C as obj, mob/user as mob)
	if(!C || !user)
		return 1
	if(istype(C, /obj/item/weapon/crowbar))
		if(broken || burnt)
			broken = 0
			burnt = 0
			user << "<span class='danger'>You remove the broken plating.</span>"
		else
			if(istype(src, /turf/simulated/floor/wood))
				user << "<span class='danger'>You forcefully pry off the planks, destroying them in the process.</span>"
			else
				user << "<span class='danger'>You remove the floor tile.</span>"
				var/obj/item/stack/tile/T = new floor_tile(src)
				if(istype(T, /obj/item/stack/tile/light))
					var/obj/item/stack/tile/light/L = T
					var/turf/simulated/floor/light/F = src
					L.state = F.state
		make_plating()
		playsound(src, 'sound/items/Crowbar.ogg', 80, 1)
		return 1
	return 0

/turf/simulated/floor/singularity_pull(S, current_size)
	if(current_size == STAGE_THREE)
		if(prob(30))
			if(builtin_tile)
				builtin_tile.loc = src
				make_plating()
	else if(current_size == STAGE_FOUR)
		if(prob(50))
			if(builtin_tile)
				builtin_tile.loc = src
				make_plating()
	else if(current_size >= STAGE_FIVE)
		if(builtin_tile)
			if(prob(70))
				builtin_tile.loc = src
				make_plating()
		else if(prob(50))
			ReplaceWithLattice()