/obj/item/device/flash
	name = "flash"
	desc = "A powerful and versatile flashbulb device, with applications ranging from disorienting attackers to acting as visual receptors in robot production."
	icon_state = "flash"
	item_state = "flashbang"	//looks exactly like a flash (and nothing like a flashbang)
	throwforce = 0
	w_class = 1
	throw_speed = 3
	throw_range = 7
	flags = CONDUCT
	origin_tech = "magnets=2;combat=1"

	var/times_used = 0 //Number of times it's been used.
	var/broken = 0     //Is the flash burnt out?
	var/last_used = 0 //last world.time it was used.


/obj/item/device/flash/proc/clown_check(mob/user)
	if(user && (CLUMSY in user.mutations) && prob(50))
		flash_carbon(user, user, 15, 0)
		user.visible_message("<span class='disarm'>[user] blinds [user] with the flash!</span>")
		return 0
	return 1


/obj/item/device/flash/proc/burn_out() //Made so you can override it if you want to have an invincible flash from R&D or something.
	broken = 1
	icon_state = "[initial(icon_state)]burnt"
	visible_message("<span class='notice'>The [src.name] burns out!</span>")


/obj/item/device/flash/proc/flash_recharge(var/mob/user)
	if(prob(times_used * 2))	//if you use it 5 times in a minute it has a 10% chance to break!
		burn_out()
		return 0

	var/deciseconds_passed = world.time - last_used
	for(var/seconds = deciseconds_passed/10, seconds>=10, seconds-=10) //get 1 charge every 10 seconds
		times_used--

	last_used = world.time
	times_used = max(0, times_used) //sanity


/obj/item/device/flash/proc/try_use_flash(var/mob/user)
	flash_recharge(user)

	if(broken)
		return 0

	playsound(src.loc, 'sound/weapons/flash.ogg', 100, 1)
	flick("[initial(icon_state)]2", src)
	times_used++

	if(user && !clown_check(user))
		return 0

	return 1


/obj/item/device/flash/proc/flash_carbon(var/mob/living/carbon/M, var/mob/user = null, var/power = 5, convert = 1)
	add_logs(user, M, "flashed", object="[src.name]")
	var/safety = M:eyecheck()
	if(safety <= 0)
		M.confused += power
		flick("e_flash", M.flash)
		if(user && convert)
			terrible_conversion_proc(M, user)


/obj/item/device/flash/attack(mob/living/M, mob/user)
	if(!try_use_flash(user))
		return 0

	if(iscarbon(M))
		flash_carbon(M, user, 5, 1)
		user.visible_message("<span class='disarm'>[user] blinds [M] with the flash!</span>")
		return 1

	else if(issilicon(M))
		M.Weaken(rand(5,10))
		add_logs(user, M, "flashed", object="[src.name]")
		user.visible_message("<span class='disarm'>[user] overloads [M]'s sensors with the flash!</span>")
		return 1

	user.visible_message("<span class='notice'>[user] fails to blind [M] with the flash!</span>")


/obj/item/device/flash/attack_self(mob/living/carbon/user, flag = 0, emp = 0)
	if(!try_use_flash(user))
		return 0
	for(var/mob/living/carbon/M in oviewers(3, null))
		flash_carbon(M, user, 3, 0)


/obj/item/device/flash/emp_act(severity)
	if(!try_use_flash())
		return 0
	for(var/mob/living/carbon/M in viewers(3, null))
		flash_carbon(M, null, 10, 0)
	burn_out()
	..()


/obj/item/device/flash/proc/terrible_conversion_proc(var/mob/M, var/mob/user)
	if(ishuman(M) && ishuman(user) && M.stat != DEAD)
		if(user.mind && ((user.mind in ticker.mode.head_revolutionaries) || (user.mind in ticker.mode.A_bosses) || (user.mind in ticker.mode.B_bosses)))
			if(M.client)
				if(M.stat == CONSCIOUS)
					M.mind_initialize() //give them a mind datum if they don't have one.
					var/resisted
					if(!isloyal(M))
						if(user.mind in ticker.mode.head_revolutionaries)
							if(!ticker.mode.add_revolutionary(M.mind))
								resisted = 1
						if(user.mind in ticker.mode.A_bosses)
							if(!ticker.mode.add_gangster(M.mind,"A"))
								resisted = 1
						if(user.mind in ticker.mode.B_bosses)
							if(!ticker.mode.add_gangster(M.mind,"B"))
								resisted = 1
					else
						resisted = 1

					if(resisted)
						user << "<span class='warning'>This mind seems resistant to the flash!</span>"
				else
					user << "<span class='warning'>They must be conscious before you can convert them!</span>"
			else
				user << "<span class='warning'>This mind is so vacant that it is not susceptible to influence!</span>"


/obj/item/device/flash/cyborg
	origin_tech = null

/obj/item/device/flash/cyborg/attack(mob/living/M, mob/user)
	..()
	cyborg_flash_animation(user)

/obj/item/device/flash/cyborg/attack_self(mob/user)
	..()
	cyborg_flash_animation(user)

/obj/item/device/flash/cyborg/proc/cyborg_flash_animation(var/mob/living/user)
	var/atom/movable/overlay/animation = new(user.loc)
	animation.layer = user.layer + 1
	animation.icon_state = "blank"
	animation.icon = 'icons/mob/mob.dmi'
	animation.master = user
	flick("blspell", animation)
	sleep(5)
	qdel(animation)


/obj/item/device/flash/memorizer
	name = "memorizer"
	desc = "If you see this, you're not likely to remember it any time soon."
	icon_state = "memorizer"
	item_state = "nullrod"

/obj/item/device/flash/handheld //this is now the regular pocket flashes