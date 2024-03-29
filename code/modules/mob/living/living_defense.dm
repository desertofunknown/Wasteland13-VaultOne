
/mob/living/proc/run_armor_check(def_zone = null, attack_flag = "melee", absorb_text = null, soften_text = null, armour_penetration, penetrated_text)
	var/armor = getarmor(def_zone, attack_flag)

	//the if "armor" check is because this is used for everything on /living, including humans
	if(armor && armour_penetration)
		armor = max(0, armor - armour_penetration)
		if(penetrated_text)
			src << "<span class='userdanger'>[penetrated_text]</span>"
		else
			src << "<span class='userdanger'>Your armor was penetrated!</span>"
	else if(armor >= 100)
		if(absorb_text)
			src << "<span class='userdanger'>[absorb_text]</span>"
		else
			src << "<span class='userdanger'>Your armor absorbs the blow!</span>"
	else if(armor > 0)
		if(soften_text)
			src << "<span class='userdanger'>[soften_text]</span>"
		else
			src << "<span class='userdanger'>Your armor softens the blow!</span>"
	return armor


/mob/living/proc/getarmor(def_zone, type)
	return 0

//this returns the mob's protection against eye damage (number between -1 and 2)
/mob/living/proc/get_eye_protection()
	return 0

//this returns the mob's protection against ear damage (0:no protection; 1: some ear protection; 2: has no ears)
/mob/living/proc/get_ear_protection()
	return 0

/mob/living/proc/on_hit(obj/item/projectile/P)
	return

/mob/living/bullet_act(obj/item/projectile/P, def_zone)
	var/armor = run_armor_check(def_zone, P.flag, "","",P.armour_penetration)
	if(!P.nodamage)
		apply_damage(P.damage, P.damage_type, def_zone, armor)
		if(P.dismemberment)
			check_projectile_dismemberment(P, def_zone)
	return P.on_hit(src, armor)

/mob/living/proc/check_projectile_dismemberment(obj/item/projectile/P, def_zone)
	return 0

/obj/item/proc/get_volume_by_throwforce_and_or_w_class()
		if(throwforce && w_class)
				return Clamp((throwforce + w_class) * 5, 30, 100)// Add the item's throwforce to its weight class and multiply by 5, then clamp the value between 30 and 100
		else if(w_class)
				return Clamp(w_class * 8, 20, 100) // Multiply the item's weight class by 8, then clamp the value between 20 and 100
		else
				return 0

/mob/living/hitby(atom/movable/AM, skipcatch, hitpush = 1, blocked = 0)
	if(istype(AM, /obj/item))
		var/obj/item/I = AM
		var/zone = ran_zone("chest", 65)//Hits a random part of the body, geared towards the chest
		var/dtype = BRUTE
		var/volume = I.get_volume_by_throwforce_and_or_w_class()
		if(istype(I,/obj/item/weapon)) //If the item is a weapon...
			var/obj/item/weapon/W = I
			dtype = W.damtype

			if (W.throwforce > 0) //If the weapon's throwforce is greater than zero...
				if (W.throwhitsound) //...and throwhitsound is defined...
					playsound(loc, W.throwhitsound, volume, 1, -1) //...play the weapon's throwhitsound.
				else if(W.hitsound) //Otherwise, if the weapon's hitsound is defined...
					playsound(loc, W.hitsound, volume, 1, -1) //...play the weapon's hitsound.
				else if(!W.throwhitsound) //Otherwise, if throwhitsound isn't defined...
					playsound(loc, 'sound/weapons/genhit.ogg',volume, 1, -1) //...play genhit.ogg.

		else if(!I.throwhitsound && I.throwforce > 0) //Otherwise, if the item doesn't have a throwhitsound and has a throwforce greater than zero...
			playsound(loc, 'sound/weapons/genhit.ogg', volume, 1, -1)//...play genhit.ogg
		if(!I.throwforce)// Otherwise, if the item's throwforce is 0...
			playsound(loc, 'sound/weapons/throwtap.ogg', 1, volume, -1)//...play throwtap.ogg.
		if(!blocked)
			visible_message("<span class='danger'>[src] has been hit by [I].</span>", \
							"<span class='userdanger'>[src] has been hit by [I].</span>")
			var/armor = run_armor_check(zone, "melee", "Your armor has protected your [parse_zone(zone)].", "Your armor has softened hit to your [parse_zone(zone)].",I.armour_penetration)
			apply_damage(I.throwforce, dtype, zone, armor)
			if(I.thrownby)
				add_logs(I.thrownby, src, "hit", I)
		else
			return 1
	else
		playsound(loc, 'sound/weapons/genhit.ogg', 50, 1, -1)
	..()


/mob/living/mech_melee_attack(obj/mecha/M)
	if(M.occupant.a_intent == INTENT_HARM)
		M.do_attack_animation(src)
		if(M.damtype == "brute")
			step_away(src,M,15)
		switch(M.damtype)
			if(BRUTE)
				Paralyse(1)
				take_overall_damage(rand(M.force/2, M.force))
				playsound(src, 'sound/weapons/punch4.ogg', 50, 1)
			if(BURN)
				take_overall_damage(0, rand(M.force/2, M.force))
				playsound(src, 'sound/items/Welder.ogg', 50, 1)
			if(TOX)
				M.mech_toxin_damage(src)
			else
				return
		updatehealth()
		visible_message("<span class='danger'>[M.name] has hit [src]!</span>", \
						"<span class='userdanger'>[M.name] has hit [src]!</span>", null, COMBAT_MESSAGE_RANGE)
		add_logs(M.occupant, src, "attacked", M, "(INTENT: [uppertext(M.occupant.a_intent)]) (DAMTYPE: [uppertext(M.damtype)])")
	else
		step_away(src,M)
		add_logs(M.occupant, src, "pushed", M)
		visible_message("<span class='warning'>[M] pushes [src] out of the way.</span>", null, null, 5)

/mob/living/fire_act()
	adjust_fire_stacks(3)
	IgniteMob()

/mob/living/proc/grabbedby(mob/living/carbon/user, supress_message = 0)
	if(user == src || anchored)
		return 0
	if(!user.pulling || user.pulling != src)
		user.start_pulling(src, supress_message)
		return

	if(!(status_flags & CANPUSH))
		user << "<span class='warning'>[src] can't be grabbed more aggressively!</span>"
		return 0
	grippedby(user)

//proc to upgrade a simple pull into a more aggressive grab.
/mob/living/proc/grippedby(mob/living/carbon/user)
	if(user.grab_state < GRAB_KILL)
		user.changeNext_move(CLICK_CD_GRABBING)
		playsound(src.loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)

		if(user.grab_state) //only the first upgrade is instantaneous
			var/old_grab_state = user.grab_state
			var/grab_upgrade_time = 30
			visible_message("<span class='danger'>[user] starts to tighten [user.p_their()] grip on [src]!</span>", \
				"<span class='userdanger'>[user] starts to tighten [user.p_their()] grip on you!</span>")
			if(!do_mob(user, src, grab_upgrade_time))
				return 0
			if(!user.pulling || user.pulling != src || user.grab_state != old_grab_state || user.a_intent != INTENT_GRAB)
				return 0
		user.grab_state++
		switch(user.grab_state)
			if(GRAB_AGGRESSIVE)
				add_logs(user, src, "grabbed", addition="aggressively")
				visible_message("<span class='danger'>[user] has grabbed [src] aggressively!</span>", \
								"<span class='userdanger'>[user] has grabbed [src] aggressively!</span>")
				drop_all_held_items()
				stop_pulling()
			if(GRAB_NECK)
				visible_message("<span class='danger'>[user] has grabbed [src] by the neck!</span>",\
								"<span class='userdanger'>[user] has grabbed you by the neck!</span>")
				update_canmove() //we fall down
				if(!buckled && !density)
					Move(user.loc)
			if(GRAB_KILL)
				visible_message("<span class='danger'>[user] is strangling [src]!</span>", \
								"<span class='userdanger'>[user] is strangling you!</span>")
				update_canmove() //we fall down
				if(!buckled && !density)
					Move(user.loc)
		return 1


/mob/living/attack_slime(mob/living/simple_animal/slime/M)
	if(!ticker || !ticker.mode)
		M << "You cannot attack people before the game has started."
		return

	if(M.buckled)
		if(M in buckled_mobs)
			M.Feedstop()
		return // can't attack while eating!

	if (stat != DEAD)
		add_logs(M, src, "attacked")
		M.do_attack_animation(src)
		visible_message("<span class='danger'>The [M.name] glomps [src]!</span>", \
				"<span class='userdanger'>The [M.name] glomps [src]!</span>", null, COMBAT_MESSAGE_RANGE)
		return 1

/mob/living/attack_animal(mob/living/simple_animal/M)
	M.face_atom(src)
	if(M.melee_damage_upper == 0)
		M.visible_message("<span class='notice'>\The [M] [M.friendly] [src]!</span>")
		return 0
	else
		if(M.attack_sound)
			playsound(loc, M.attack_sound, 50, 1, 1)
		M.do_attack_animation(src)
		visible_message("<span class='danger'>\The [M] [M.attacktext] [src]!</span>", \
						"<span class='userdanger'>\The [M] [M.attacktext] [src]!</span>", null, COMBAT_MESSAGE_RANGE)
		add_logs(M, src, "attacked")
		return 1


/mob/living/attack_paw(mob/living/carbon/monkey/M)
	if(isturf(loc) && istype(loc.loc, /area/start))
		M << "No attacking people at spawn, you jackass."
		return 0

	if (M.a_intent == INTENT_HARM)
		if(M.is_muzzled() || (M.wear_mask && M.wear_mask.flags_cover & MASKCOVERSMOUTH))
			M << "<span class='warning'>You can't bite with your mouth covered!</span>"
			return 0
		M.do_attack_animation(src, ATTACK_EFFECT_BITE)
		if (prob(75))
			add_logs(M, src, "attacked")
			playsound(loc, 'sound/weapons/bite.ogg', 50, 1, -1)
			visible_message("<span class='danger'>[M.name] bites [src]!</span>", \
					"<span class='userdanger'>[M.name] bites [src]!</span>", null, COMBAT_MESSAGE_RANGE)
			return 1
		else
			visible_message("<span class='danger'>[M.name] has attempted to bite [src]!</span>", \
				"<span class='userdanger'>[M.name] has attempted to bite [src]!</span>", null, COMBAT_MESSAGE_RANGE)
	return 0

/mob/living/attack_larva(mob/living/carbon/alien/larva/L)
	switch(L.a_intent)
		if("help")
			visible_message("<span class='notice'>[L.name] rubs its head against [src].</span>")
			return 0

		else
			L.do_attack_animation(src)
			if(prob(90))
				add_logs(L, src, "attacked")
				visible_message("<span class='danger'>[L.name] bites [src]!</span>", \
					"<span class='userdanger'>[L.name] bites [src]!</span>", null, COMBAT_MESSAGE_RANGE)
				playsound(loc, 'sound/weapons/bite.ogg', 50, 1, -1)
				return 1
			else
				visible_message("<span class='danger'>[L.name] has attempted to bite [src]!</span>", \
					"<span class='userdanger'>[L.name] has attempted to bite [src]!</span>", null, COMBAT_MESSAGE_RANGE)
	return 0

/mob/living/attack_alien(mob/living/carbon/alien/humanoid/M)
	if(isturf(loc) && istype(loc.loc, /area/start))
		M << "No attacking people at spawn, you jackass."
		return 0

	switch(M.a_intent)
		if ("help")
			visible_message("<span class='notice'>[M] caresses [src] with its scythe like arm.</span>")
			return 0

		if ("grab")
			grabbedby(M)
			return 0
		if("harm")
			M.do_attack_animation(src)
			return 1
		if("disarm")
			M.do_attack_animation(src, ATTACK_EFFECT_DISARM)
			return 1

/mob/living/ex_act(severity, target, origin)
	if(origin && istype(origin, /datum/spacevine_mutation) && isvineimmune(src))
		return
	..()

//Looking for irradiate()? It's been moved to radiation.dm under the rad_act() for mobs.

/mob/living/acid_act(acidpwr, acid_volume)
	take_bodypart_damage(acidpwr * min(1, acid_volume * 0.1))
	return 1


/mob/living/proc/electrocute_act(shock_damage, obj/source, siemens_coeff = 1, safety = 0, tesla_shock = 0, illusion = 0)
	if(shock_damage > 0)
		if(!illusion)
			adjustFireLoss(shock_damage)
		visible_message(
			"<span class='danger'>[src] was shocked by \the [source]!</span>", \
			"<span class='userdanger'>You feel a powerful shock coursing through your body!</span>", \
			"<span class='italics'>You hear a heavy electrical crack.</span>" \
		)
		return shock_damage

/mob/living/emp_act(severity)
	var/list/L = src.get_contents()
	for(var/obj/O in L)
		O.emp_act(severity)
	..()

/mob/living/singularity_act()
	var/gain = 20
	investigate_log("([key_name(src)]) has been consumed by the singularity.","singulo") //Oh that's where the clown ended up!
	gib()
	return(gain)

/mob/living/narsie_act()
	if(is_servant_of_ratvar(src) && !stat)
		src << "<span class='userdanger'>You resist Nar-Sie's influence... but not all of it. <i>Run!</i></span>"
		adjustBruteLoss(35)
		if(src && reagents)
			reagents.add_reagent("heparin", 5)
		return FALSE
	if(client)
		makeNewConstruct(/mob/living/simple_animal/hostile/construct/harvester, src, null, 0)
	else
		switch(rand(1, 10))
			if(1)
				new /mob/living/simple_animal/hostile/construct/armored/hostile(get_turf(src))
			if(2)
				new /mob/living/simple_animal/hostile/construct/wraith/hostile(get_turf(src))
			if(3 to 6)
				new /mob/living/simple_animal/hostile/construct/builder/hostile(get_turf(src))
			if(6 to 10)
				new /mob/living/simple_animal/hostile/construct/harvester/hostile(get_turf(src))
	spawn_dust()
	gib()
	return TRUE


/mob/living/ratvar_act()
	if(stat != DEAD && !is_servant_of_ratvar(src) && !add_servant_of_ratvar(src))
		src << "<span class='userdanger'>A blinding light boils you alive! <i>Run!</i></span>"
		adjustFireLoss(35)
		if(src)
			adjust_fire_stacks(1)
			IgniteMob()
		return FALSE
	return TRUE


//called when the mob receives a bright flash
/mob/living/proc/flash_act(intensity = 1, override_blindness_check = 0, affect_silicon = 0, visual = 0, type = /obj/screen/fullscreen/flash)
	if(get_eye_protection() < intensity && (override_blindness_check || !(disabilities & BLIND)))
		overlay_fullscreen("flash", type)
		addtimer(CALLBACK(src, .proc/clear_fullscreen, "flash", 25), 25)
		return 1

//called when the mob receives a loud bang
/mob/living/proc/soundbang_act()
	return 0

//to damage the clothes worn by a mob
/mob/living/proc/damage_clothes(damage_amount, damage_type = BRUTE, damage_flag = 0, def_zone)
	return


/mob/living/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect, end_pixel_y)
	if(A != src)
		end_pixel_y = get_standard_pixel_y_offset(lying)
	used_item = get_active_held_item()
	..()
	floating = 0 // If we were without gravity, the bouncing animation got stopped, so we make sure we restart the bouncing after the next movement.
