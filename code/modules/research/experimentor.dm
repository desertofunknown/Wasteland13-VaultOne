//this is designed to replace the destructive analyzer

#define SCANTYPE_POKE 1
#define SCANTYPE_IRRADIATE 2
#define SCANTYPE_GAS 3
#define SCANTYPE_HEAT 4
#define SCANTYPE_COLD 5
#define SCANTYPE_OBLITERATE 6
#define SCANTYPE_DISCOVER 7

#define EFFECT_PROB_VERYLOW 20
#define EFFECT_PROB_LOW 35
#define EFFECT_PROB_MEDIUM 50
#define EFFECT_PROB_HIGH 75
#define EFFECT_PROB_VERYHIGH 95

#define FAIL 8
/obj/machinery/r_n_d/experimentor
	name = "E.X.P.E.R.I-MENTOR"
	icon = 'icons/obj/machines/heavy_lathe.dmi'
	icon_state = "h_lathe"
	density = 1
	anchored = 1
	use_power = 1
	var/recentlyExperimented = 0
	var/mob/trackedIan
	var/mob/trackedRuntime
	var/badThingCoeff = 0
	var/resetTime = 15
	var/cloneMode = FALSE
	var/cloneCount = 0
	var/list/item_reactions = list()
	var/list/valid_items = list() //valid items for special reactions like transforming
	var/list/critical_items = list() //items that can cause critical reactions

/obj/machinery/r_n_d/experimentor/proc/ConvertReqString2List(list/source_list)
	var/list/temp_list = params2list(source_list)
	for(var/O in temp_list)
		temp_list[O] = text2num(temp_list[O])
	return temp_list

/* //uncomment to enable forced reactions.
/obj/machinery/r_n_d/experimentor/verb/forceReaction()
	set name = "Force Experimentor Reaction"
	set category = "Debug"
	set src in oview(1)
	var/reaction = input(usr,"What reaction?") in list(SCANTYPE_POKE,SCANTYPE_IRRADIATE,SCANTYPE_GAS,SCANTYPE_HEAT,SCANTYPE_COLD,SCANTYPE_OBLITERATE)
	var/oldReaction = item_reactions["[loaded_item.type]"]
	item_reactions["[loaded_item.type]"] = reaction
	experiment(item_reactions["[loaded_item.type]"],loaded_item)
	spawn(10)
		if(loaded_item)
			item_reactions["[loaded_item.type]"] = oldReaction
*/

/obj/machinery/r_n_d/experimentor/proc/SetTypeReactions()
	var/probWeight = 0
	for(var/I in typesof(/obj/item))
		if(istype(I,/obj/item/weapon/relic))
			item_reactions["[I]"] = SCANTYPE_DISCOVER
		else
			item_reactions["[I]"] = pick(SCANTYPE_POKE,SCANTYPE_IRRADIATE,SCANTYPE_GAS,SCANTYPE_HEAT,SCANTYPE_COLD,SCANTYPE_OBLITERATE)
		if(ispath(I,/obj/item/weapon/stock_parts) || ispath(I,/obj/item/weapon/grenade/chem_grenade) || ispath(I,/obj/item/weapon/kitchen))
			var/obj/item/tempCheck = I
			if(initial(tempCheck.icon_state) != null) //check it's an actual usable item, in a hacky way
				valid_items += 15
				valid_items += I
				probWeight++

		if(ispath(I,/obj/item/weapon/reagent_containers/food))
			var/obj/item/tempCheck = I
			if(initial(tempCheck.icon_state) != null) //check it's an actual usable item, in a hacky way
				valid_items += rand(1,max(2,35-probWeight))
				valid_items += I

		if(ispath(I,/obj/item/weapon/rcd) || ispath(I,/obj/item/weapon/grenade) || ispath(I,/obj/item/device/aicard) || ispath(I,/obj/item/weapon/storage/backpack/holding) || ispath(I,/obj/item/slime_extract) || ispath(I,/obj/item/device/onetankbomb) || ispath(I,/obj/item/device/transfer_valve))
			var/obj/item/tempCheck = I
			if(initial(tempCheck.icon_state) != null)
				critical_items += I


/obj/machinery/r_n_d/experimentor/New()
	..()
	var/obj/item/weapon/circuitboard/machine/B = new /obj/item/weapon/circuitboard/machine/experimentor(null)
	B.apply_default_parts(src)

	trackedIan = locate(/mob/living/simple_animal/pet/dog/corgi/Ian) in mob_list
	trackedRuntime = locate(/mob/living/simple_animal/pet/cat/Runtime) in mob_list
	SetTypeReactions()

/obj/item/weapon/circuitboard/machine/experimentor
	name = "E.X.P.E.R.I-MENTOR (Machine Board)"
	build_path = /obj/machinery/r_n_d/experimentor
	origin_tech = "magnets=1;engineering=1;programming=1;biotech=1;bluespace=2"
	req_components = list(
							/obj/item/weapon/stock_parts/scanning_module = 1,
							/obj/item/weapon/stock_parts/manipulator = 2,
							/obj/item/weapon/stock_parts/micro_laser = 2)

/obj/machinery/r_n_d/experimentor/RefreshParts()
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		if(resetTime > 0 && (resetTime - M.rating) >= 1)
			resetTime -= M.rating
	for(var/obj/item/weapon/stock_parts/scanning_module/M in component_parts)
		badThingCoeff += M.rating*2
	for(var/obj/item/weapon/stock_parts/micro_laser/M in component_parts)
		badThingCoeff += M.rating

/obj/machinery/r_n_d/experimentor/proc/checkCircumstances(obj/item/O)
	//snowflake check to only take "made" bombs
	if(istype(O,/obj/item/device/transfer_valve))
		var/obj/item/device/transfer_valve/T = O
		if(!T.tank_one || !T.tank_two || !T.attached_device)
			return FALSE
	return TRUE

/obj/machinery/r_n_d/experimentor/Insert_Item(obj/item/O, mob/user)
	if(user.a_intent != INTENT_HARM)
		. = 1
		if(!is_insertion_ready(user))
			return
		if(!checkCircumstances(O))
			user << "<span class='warning'>The [O] is not yet valid for the [src] and must be completed!</span>"
			return
		if(!O.origin_tech)
			user << "<span class='warning'>This doesn't seem to have a tech origin!</span>"
			return
		var/list/temp_tech = ConvertReqString2List(O.origin_tech)
		if (temp_tech.len == 0)
			user << "<span class='warning'>You cannot experiment on this item!</span>"
			return
		if(!user.drop_item())
			return
		loaded_item = O
		O.loc = src
		user << "<span class='notice'>You add the [O.name] to the machine.</span>"
		flick("h_lathe_load", src)



/obj/machinery/r_n_d/experimentor/default_deconstruction_crowbar(obj/item/O)
	ejectItem()
	..(O)

/obj/machinery/r_n_d/experimentor/attack_hand(mob/user)
	user.set_machine(src)
	var/dat = "<center>"
	if(!linked_console)
		dat += "<b><a href='byond://?src=\ref[src];function=search'>Scan for R&D Console</A></b><br>"
	if(loaded_item)
		dat += "<b>Loaded Item:</b> [loaded_item]<br>"
		dat += "<b>Technology</b>:<br>"
		var/list/D = ConvertReqString2List(loaded_item.origin_tech)
		for(var/T in D)
			dat += "[T]<br>"
		dat += "<br><br>Available tests:"
		dat += "<br><b><a href='byond://?src=\ref[src];item=\ref[loaded_item];function=[SCANTYPE_POKE]'>Poke</A></b>"
		dat += "<br><b><a href='byond://?src=\ref[src];item=\ref[loaded_item];function=[SCANTYPE_IRRADIATE];'>Irradiate</A></b>"
		dat += "<br><b><a href='byond://?src=\ref[src];item=\ref[loaded_item];function=[SCANTYPE_GAS]'>Gas</A></b>"
		dat += "<br><b><a href='byond://?src=\ref[src];item=\ref[loaded_item];function=[SCANTYPE_HEAT]'>Burn</A></b>"
		dat += "<br><b><a href='byond://?src=\ref[src];item=\ref[loaded_item];function=[SCANTYPE_COLD]'>Freeze</A></b>"
		dat += "<br><b><a href='byond://?src=\ref[src];item=\ref[loaded_item];function=[SCANTYPE_OBLITERATE]'>Destroy</A></b><br>"
		if(istype(loaded_item,/obj/item/weapon/relic))
			dat += "<br><b><a href='byond://?src=\ref[src];item=\ref[loaded_item];function=[SCANTYPE_DISCOVER]'>Discover</A></b><br>"
		dat += "<br><b><a href='byond://?src=\ref[src];function=eject'>Eject</A>"
	else
		dat += "<b>Nothing loaded.</b>"
	dat += "<br><a href='byond://?src=\ref[src];function=refresh'>Refresh</A><br>"
	dat += "<br><a href='byond://?src=\ref[src];close=1'>Close</A><br></center>"
	var/datum/browser/popup = new(user, "experimentor","Experimentor", 700, 400, src)
	popup.set_content(dat)
	popup.open()
	onclose(user, "experimentor")


/obj/machinery/r_n_d/experimentor/proc/matchReaction(matching,reaction)
	var/obj/item/D = matching
	if(D)
		if(item_reactions.Find("[D.type]"))
			var/tor = item_reactions["[D.type]"]
			if(tor == text2num(reaction))
				return tor
			else
				return FAIL
		else
			return FAIL
	else
		return FAIL

/obj/machinery/r_n_d/experimentor/proc/ejectItem(delete=FALSE)
	if(loaded_item)
		if(cloneMode && cloneCount > 0)
			visible_message("<span class='notice'>A duplicate [loaded_item] pops out!</span>")
			var/type_to_make = loaded_item.type
			new type_to_make(get_turf(pick(oview(1,src))))
			--cloneCount
			if(cloneCount == 0)
				cloneMode = FALSE
			return
		var/turf/dropturf = get_turf(pick(view(1,src)))
		if(!dropturf) //Failsafe to prevent the object being lost in the void forever.
			dropturf = get_turf(src)
		loaded_item.loc = dropturf
		if(delete)
			qdel(loaded_item)
		loaded_item = null

/obj/machinery/r_n_d/experimentor/proc/throwSmoke(turf/where)
	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(0, where)
	smoke.start()

/obj/machinery/r_n_d/experimentor/proc/pickWeighted(list/from)
	var/result = FALSE
	var/counter = 1
	while(!result)
		var/probtocheck = from[counter]
		if(prob(probtocheck))
			result = TRUE
			return from[counter+1]
		if(counter + 2 < from.len)
			counter = counter + 2
		else
			counter = 1

/obj/machinery/r_n_d/experimentor/proc/experiment(exp,obj/item/exp_on)
	recentlyExperimented = 1
	icon_state = "h_lathe_wloop"
	var/chosenchem
	var/criticalReaction = (exp_on.type in critical_items) ? TRUE : FALSE
	////////////////////////////////////////////////////////////////////////////////////////////////
	if(exp == SCANTYPE_POKE)
		visible_message("[src] prods at [exp_on] with mechanical arms.")
		if(prob(EFFECT_PROB_LOW) && criticalReaction)
			visible_message("[exp_on] is gripped in just the right way, enhancing its focus.")
			badThingCoeff++
		else if(prob(EFFECT_PROB_VERYLOW-badThingCoeff))
			visible_message("<span class='danger'>[src] malfunctions and destroys [exp_on], lashing its arms out at nearby people!</span>")
			for(var/mob/living/m in oview(1, src))
				m.apply_damage(15, BRUTE, pick("head","chest","groin"))
				investigate_log("Experimentor dealt minor brute to [m].", "experimentor")
			ejectItem(TRUE)
		else if(prob(EFFECT_PROB_LOW-badThingCoeff))
			visible_message("<span class='warning'>[src] malfunctions!</span>")
			exp = SCANTYPE_OBLITERATE
		else if(prob(EFFECT_PROB_MEDIUM-badThingCoeff))
			visible_message("<span class='danger'>[src] malfunctions, throwing the [exp_on]!</span>")
			var/mob/living/target = locate(/mob/living) in oview(7,src)
			if(target)
				var/obj/item/throwing = loaded_item
				investigate_log("Experimentor has thrown [loaded_item] at [target]", "experimentor")
				ejectItem()
				if(throwing)
					throwing.throw_at(target, 10, 1)
	////////////////////////////////////////////////////////////////////////////////////////////////
	if(exp == SCANTYPE_IRRADIATE)
		visible_message("<span class='danger'>[src] reflects radioactive rays at [exp_on]!</span>")
		if(prob(EFFECT_PROB_LOW) && criticalReaction)
			visible_message("[exp_on] has activated an unknown subroutine!")
			cloneMode = TRUE
			cloneCount = badThingCoeff
			investigate_log("Experimentor has made a clone of [exp_on]", "experimentor")
			ejectItem()
		else if(prob(EFFECT_PROB_VERYLOW-badThingCoeff))
			visible_message("<span class='danger'>[src] malfunctions, melting [exp_on] and leaking radiation!</span>")
			radiation_pulse(get_turf(src), 1, 1, 25, 1)
			ejectItem(TRUE)
		else if(prob(EFFECT_PROB_LOW-badThingCoeff))
			visible_message("<span class='warning'>[src] malfunctions, spewing toxic waste!</span>")
			for(var/turf/T in oview(1, src))
				if(!T.density)
					if(prob(EFFECT_PROB_VERYHIGH))
						var/obj/effect/decal/cleanable/reagentdecal = new/obj/effect/decal/cleanable/greenglow(T)
						reagentdecal.reagents.add_reagent("radium", 7)
		else if(prob(EFFECT_PROB_MEDIUM-badThingCoeff))
			var/savedName = "[exp_on]"
			ejectItem(TRUE)
			var/newPath = pickWeighted(valid_items)
			loaded_item = new newPath(src)
			visible_message("<span class='warning'>[src] malfunctions, transforming [savedName] into [loaded_item]!</span>")
			investigate_log("Experimentor has transformed [savedName] into [loaded_item]", "experimentor")
			if(istype(loaded_item,/obj/item/weapon/grenade/chem_grenade))
				var/obj/item/weapon/grenade/chem_grenade/CG = loaded_item
				CG.prime()
			ejectItem()
	////////////////////////////////////////////////////////////////////////////////////////////////
	if(exp == SCANTYPE_GAS)
		visible_message("<span class='warning'>[src] fills its chamber with gas, [exp_on] included.</span>")
		if(prob(EFFECT_PROB_LOW) && criticalReaction)
			visible_message("[exp_on] achieves the perfect mix!")
			new /obj/item/stack/sheet/mineral/plasma(get_turf(pick(oview(1,src))))
		else if(prob(EFFECT_PROB_VERYLOW-badThingCoeff))
			visible_message("<span class='danger'>[src] destroys [exp_on], leaking dangerous gas!</span>")
			chosenchem = pick("carbon","radium","toxin","condensedcapsaicin","mushroomhallucinogen","space_drugs","ethanol","beepskysmash")
			var/datum/reagents/R = new/datum/reagents(50)
			R.my_atom = src
			R.add_reagent(chosenchem , 50)
			investigate_log("Experimentor has released [chosenchem] smoke.", "experimentor")
			var/datum/effect_system/smoke_spread/chem/smoke = new
			smoke.set_up(R, 0, src, silent = 1)
			playsound(src.loc, 'sound/effects/smoke.ogg', 50, 1, -3)
			smoke.start()
			qdel(R)
			ejectItem(TRUE)
		else if(prob(EFFECT_PROB_VERYLOW-badThingCoeff))
			visible_message("<span class='danger'>[src]'s chemical chamber has sprung a leak!</span>")
			chosenchem = pick("mutationtoxin","nanomachines","sacid")
			var/datum/reagents/R = new/datum/reagents(50)
			R.my_atom = src
			R.add_reagent(chosenchem , 50)
			var/datum/effect_system/smoke_spread/chem/smoke = new
			smoke.set_up(R, 0, src, silent = 1)
			playsound(src.loc, 'sound/effects/smoke.ogg', 50, 1, -3)
			smoke.start()
			qdel(R)
			ejectItem(TRUE)
			warn_admins(usr, "[chosenchem] smoke")
			investigate_log("Experimentor has released <font color='red'>[chosenchem]</font> smoke!", "experimentor")
		else if(prob(EFFECT_PROB_LOW-badThingCoeff))
			visible_message("[src] malfunctions, spewing harmless gas.")
			throwSmoke(src.loc)
		else if(prob(EFFECT_PROB_MEDIUM-badThingCoeff))
			visible_message("<span class='warning'>[src] melts [exp_on], ionizing the air around it!</span>")
			empulse(src.loc, 4, 6)
			investigate_log("Experimentor has generated an Electromagnetic Pulse.", "experimentor")
			ejectItem(TRUE)
	////////////////////////////////////////////////////////////////////////////////////////////////
	if(exp == SCANTYPE_HEAT)
		visible_message("[src] raises [exp_on]'s temperature.")
		if(prob(EFFECT_PROB_LOW) && criticalReaction)
			visible_message("<span class='warning'>[src]'s emergency coolant system gives off a small ding!</span>")
			playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
			var/obj/item/weapon/reagent_containers/food/drinks/coffee/C = new /obj/item/weapon/reagent_containers/food/drinks/coffee(get_turf(pick(oview(1,src))))
			chosenchem = pick("plasma","capsaicin","ethanol")
			C.reagents.remove_any(25)
			C.reagents.add_reagent(chosenchem , 50)
			C.name = "Cup of Suspicious Liquid"
			C.desc = "It has a large hazard symbol printed on the side in fading ink."
			investigate_log("Experimentor has made a cup of [chosenchem] coffee.", "experimentor")
		else if(prob(EFFECT_PROB_VERYLOW-badThingCoeff))
			var/turf/start = get_turf(src)
			var/mob/M = locate(/mob/living) in view(src, 3)
			var/turf/MT = get_turf(M)
			if(MT)
				visible_message("<span class='danger'>[src] dangerously overheats, launching a flaming fuel orb!</span>")
				investigate_log("Experimentor has launched a <font color='red'>fireball</font> at [M]!", "experimentor")
				var/obj/item/projectile/magic/fireball/FB = new /obj/item/projectile/magic/fireball(start)
				FB.original = MT
				FB.current = start
				FB.yo = MT.y - start.y
				FB.xo = MT.x - start.x
				FB.fire()
		else if(prob(EFFECT_PROB_LOW-badThingCoeff))
			visible_message("<span class='danger'>[src] malfunctions, melting [exp_on] and releasing a burst of flame!</span>")
			explosion(src.loc, -1, 0, 0, 0, 0, flame_range = 2)
			investigate_log("Experimentor started a fire.", "experimentor")
			ejectItem(TRUE)
		else if(prob(EFFECT_PROB_MEDIUM-badThingCoeff))
			visible_message("<span class='warning'>[src] malfunctions, melting [exp_on] and leaking hot air!</span>")
			var/datum/gas_mixture/env = src.loc.return_air()
			var/transfer_moles = 0.25 * env.total_moles()
			var/datum/gas_mixture/removed = env.remove(transfer_moles)
			if(removed)
				var/heat_capacity = removed.heat_capacity()
				if(heat_capacity == 0 || heat_capacity == null)
					heat_capacity = 1
				removed.temperature = min((removed.temperature*heat_capacity + 100000)/heat_capacity, 1000)
			env.merge(removed)
			air_update_turf()
			investigate_log("Experimentor has released hot air.", "experimentor")
			ejectItem(TRUE)
		else if(prob(EFFECT_PROB_MEDIUM-badThingCoeff))
			visible_message("<span class='warning'>[src] malfunctions, activating its emergency coolant systems!</span>")
			throwSmoke(src.loc)
			for(var/mob/living/m in oview(1, src))
				m.apply_damage(5, BURN, pick("head","chest","groin"))
				investigate_log("Experimentor has dealt minor burn damage to [m]", "experimentor")
			ejectItem()
	////////////////////////////////////////////////////////////////////////////////////////////////
	if(exp == SCANTYPE_COLD)
		visible_message("[src] lowers [exp_on]'s temperature.")
		if(prob(EFFECT_PROB_LOW) && criticalReaction)
			visible_message("<span class='warning'>[src]'s emergency coolant system gives off a small ding!</span>")
			var/obj/item/weapon/reagent_containers/food/drinks/coffee/C = new /obj/item/weapon/reagent_containers/food/drinks/coffee(get_turf(pick(oview(1,src))))
			playsound(src.loc, 'sound/machines/ding.ogg', 50, 1) //Ding! Your death coffee is ready!
			chosenchem = pick("uranium","frostoil","ephedrine")
			C.reagents.remove_any(25)
			C.reagents.add_reagent(chosenchem , 50)
			C.name = "Cup of Suspicious Liquid"
			C.desc = "It has a large hazard symbol printed on the side in fading ink."
			investigate_log("Experimentor has made a cup of [chosenchem] coffee.", "experimentor")
		else if(prob(EFFECT_PROB_VERYLOW-badThingCoeff))
			visible_message("<span class='danger'>[src] malfunctions, shattering [exp_on] and releasing a dangerous cloud of coolant!</span>")
			var/datum/reagents/R = new/datum/reagents(50)
			R.my_atom = src
			R.add_reagent("frostoil" , 50)
			investigate_log("Experimentor has released frostoil gas.", "experimentor")
			var/datum/effect_system/smoke_spread/chem/smoke = new
			smoke.set_up(R, 0, src, silent = 1)
			playsound(src.loc, 'sound/effects/smoke.ogg', 50, 1, -3)
			smoke.start()
			qdel(R)
			ejectItem(TRUE)
		else if(prob(EFFECT_PROB_LOW-badThingCoeff))
			visible_message("<span class='warning'>[src] malfunctions, shattering [exp_on] and leaking cold air!</span>")
			var/datum/gas_mixture/env = src.loc.return_air()
			var/transfer_moles = 0.25 * env.total_moles()
			var/datum/gas_mixture/removed = env.remove(transfer_moles)
			if(removed)
				var/heat_capacity = removed.heat_capacity()
				if(heat_capacity == 0 || heat_capacity == null)
					heat_capacity = 1
				removed.temperature = (removed.temperature*heat_capacity - 75000)/heat_capacity
			env.merge(removed)
			air_update_turf()
			investigate_log("Experimentor has released cold air.", "experimentor")
			ejectItem(TRUE)
		else if(prob(EFFECT_PROB_MEDIUM-badThingCoeff))
			visible_message("<span class='warning'>[src] malfunctions, releasing a flurry of chilly air as [exp_on] pops out!</span>")
			var/datum/effect_system/smoke_spread/smoke = new
			smoke.set_up(0, src.loc)
			smoke.start()
			ejectItem()
	////////////////////////////////////////////////////////////////////////////////////////////////
	if(exp == SCANTYPE_OBLITERATE)
		visible_message("<span class='warning'>[exp_on] activates the crushing mechanism, [exp_on] is destroyed!</span>")
		if(linked_console.linked_lathe)
			for(var/material in exp_on.materials)
				linked_console.linked_lathe.materials.insert_amount( min((linked_console.linked_lathe.materials.max_amount - linked_console.linked_lathe.materials.total_amount), (exp_on.materials[material])), material)
		if(prob(EFFECT_PROB_LOW) && criticalReaction)
			visible_message("<span class='warning'>[src]'s crushing mechanism slowly and smoothly descends, flattening the [exp_on]!</span>")
			new /obj/item/stack/sheet/plasteel(get_turf(pick(oview(1,src))))
		else if(prob(EFFECT_PROB_VERYLOW-badThingCoeff))
			visible_message("<span class='danger'>[src]'s crusher goes way too many levels too high, crushing right through space-time!</span>")
			playsound(src.loc, 'sound/effects/supermatter.ogg', 50, 1, -3)
			investigate_log("Experimentor has triggered the 'throw things' reaction.", "experimentor")
			for(var/atom/movable/AM in oview(7,src))
				if(!AM.anchored)
					AM.throw_at(src,10,1)
		else if(prob(EFFECT_PROB_LOW-badThingCoeff))
			visible_message("<span class='danger'>[src]'s crusher goes one level too high, crushing right into space-time!</span>")
			playsound(src.loc, 'sound/effects/supermatter.ogg', 50, 1, -3)
			investigate_log("Experimentor has triggered the 'minor throw things' reaction.", "experimentor")
			var/list/throwAt = list()
			for(var/atom/movable/AM in oview(7,src))
				if(!AM.anchored)
					throwAt.Add(AM)
			for(var/counter = 1, counter < throwAt.len, ++counter)
				var/atom/movable/cast = throwAt[counter]
				cast.throw_at(pick(throwAt),10,1)
		ejectItem(TRUE)
	////////////////////////////////////////////////////////////////////////////////////////////////
	if(exp == FAIL)
		var/a = pick("rumbles","shakes","vibrates","shudders")
		var/b = pick("crushes","spins","viscerates","smashes","insults")
		visible_message("<span class='warning'>[exp_on] [a], and [b], the experiment was a failure.</span>")

	if(exp == SCANTYPE_DISCOVER)
		visible_message("[src] scans the [exp_on], revealing its true nature!")
		playsound(src.loc, 'sound/effects/supermatter.ogg', 50, 3, -1)
		var/obj/item/weapon/relic/R = loaded_item
		R.reveal()
		investigate_log("Experimentor has revealed a relic with <span class='danger'>[R.realProc]</span> effect.", "experimentor")
		ejectItem()

	//Global reactions
	if(prob(EFFECT_PROB_VERYLOW-badThingCoeff) && loaded_item)
		var/globalMalf = rand(1,100)
		if(globalMalf < 15)
			visible_message("<span class='warning'>[src]'s onboard detection system has malfunctioned!</span>")
			item_reactions["[exp_on.type]"] = pick(SCANTYPE_POKE,SCANTYPE_IRRADIATE,SCANTYPE_GAS,SCANTYPE_HEAT,SCANTYPE_COLD,SCANTYPE_OBLITERATE)
			ejectItem()
		if(globalMalf > 16 && globalMalf < 35)
			visible_message("<span class='warning'>[src] melts [exp_on], ian-izing the air around it!</span>")
			throwSmoke(src.loc)
			if(trackedIan)
				throwSmoke(trackedIan.loc)
				trackedIan.loc = src.loc
				investigate_log("Experimentor has stolen Ian!", "experimentor") //...if anyone ever fixes it...
			else
				new /mob/living/simple_animal/pet/dog/corgi(src.loc)
				investigate_log("Experimentor has spawned a new corgi.", "experimentor")
			ejectItem(TRUE)
		if(globalMalf > 36 && globalMalf < 50)
			visible_message("<span class='warning'>Experimentor draws the life essence of those nearby!</span>")
			for(var/mob/living/m in view(4,src))
				m << "<span class='danger'>You feel your flesh being torn from you, mists of blood drifting to [src]!</span>"
				m.apply_damage(50, BRUTE, "chest")
				investigate_log("Experimentor has taken 50 brute a blood sacrifice from [m]", "experimentor")
		if(globalMalf > 51 && globalMalf < 75)
			visible_message("<span class='warning'>[src] encounters a run-time error!</span>")
			throwSmoke(src.loc)
			if(trackedRuntime)
				throwSmoke(trackedRuntime.loc)
				trackedRuntime.loc = src.loc
				investigate_log("Experimentor has stolen Runtime!", "experimentor")
			else
				new /mob/living/simple_animal/pet/cat(src.loc)
				investigate_log("Experimentor failed to steal runtime, and instead spawned a new cat.", "experimentor")
			ejectItem(TRUE)
		if(globalMalf > 76)
			visible_message("<span class='warning'>[src] begins to smoke and hiss, shaking violently!</span>")
			use_power(500000)
			investigate_log("Experimentor has drained power from its APC", "experimentor")

	spawn(resetTime)
		icon_state = "h_lathe"
		recentlyExperimented = 0

/obj/machinery/r_n_d/experimentor/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)

	var/scantype = href_list["function"]
	var/obj/item/process = locate(href_list["item"]) in src

	if(href_list["close"])
		usr << browse(null, "window=experimentor")
		return
	else if(scantype == "search")
		var/obj/machinery/computer/rdconsole/D = locate(/obj/machinery/computer/rdconsole) in oview(3,src)
		if(D)
			linked_console = D
	else if(scantype == "eject")
		ejectItem()
	else if(scantype == "refresh")
		src.updateUsrDialog()
	else
		if(recentlyExperimented)
			usr << "<span class='warning'>[src] has been used too recently!</span>"
			return
		else if(!loaded_item)
			updateUsrDialog() //Set the interface to unloaded mode
			usr << "<span class='warning'>[src] is not currently loaded!</span>"
			return
		else if(!process || process != loaded_item) //Interface exploit protection (such as hrefs or swapping items with interface set to old item)
			updateUsrDialog() //Refresh interface to update interface hrefs
			usr << "<span class='danger'>Interface failure detected in [src]. Please try again.</span>"
			return
		var/dotype
		if(text2num(scantype) == SCANTYPE_DISCOVER)
			dotype = SCANTYPE_DISCOVER
		else
			dotype = matchReaction(process,scantype)
		experiment(dotype,process)
		use_power(750)
		if(dotype != FAIL)
			if(process && process.origin_tech)
				var/list/temp_tech = ConvertReqString2List(process.origin_tech)
				for(var/T in temp_tech)
					linked_console.files.UpdateTech(T, temp_tech[T])
	src.updateUsrDialog()
	return

//~~~~~~~~Admin logging proc, aka the Powergamer Alarm~~~~~~~~
/obj/machinery/r_n_d/experimentor/proc/warn_admins(mob/user, ReactionName)
	var/turf/T = get_turf(src)
	message_admins("Experimentor reaction: [ReactionName] generated by [key_name_admin(user)](<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>) (<A HREF='?_src_=holder;adminplayerobservefollow=\ref[user]'>FLW</A>) at ([T.x],[T.y],[T.z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>JMP</a>)",0,1)
	log_game("Experimentor reaction: [ReactionName] generated by [key_name(user)] in ([T.x],[T.y],[T.z])")

#undef SCANTYPE_POKE
#undef SCANTYPE_IRRADIATE
#undef SCANTYPE_GAS
#undef SCANTYPE_HEAT
#undef SCANTYPE_COLD
#undef SCANTYPE_OBLITERATE
#undef SCANTYPE_DISCOVER

#undef EFFECT_PROB_VERYLOW
#undef EFFECT_PROB_LOW
#undef EFFECT_PROB_MEDIUM
#undef EFFECT_PROB_HIGH
#undef EFFECT_PROB_VERYHIGH

#undef FAIL


//////////////////////////////////SPECIAL ITEMS////////////////////////////////////////

/obj/item/weapon/relic
	name = "strange object"
	desc = "What mysteries could this hold?"
	icon = 'icons/obj/assemblies.dmi'
	origin_tech = "combat=1;plasmatech=1;powerstorage=1;materials=1"
	var/realName = "defined object"
	var/revealed = FALSE
	var/realProc
	var/cooldownMax = 60
	var/cooldown

/obj/item/weapon/relic/New()
	..()
	icon_state = pick("shock_kit","armor-igniter-analyzer","infra-igniter0","infra-igniter1","radio-multitool","prox-radio1","radio-radio","timer-multitool0","radio-igniter-tank")
	realName = "[pick("broken","twisted","spun","improved","silly","regular","badly made")] [pick("device","object","toy","illegal tech","weapon")]"


/obj/item/weapon/relic/proc/reveal()
	if(revealed) //Re-rolling your relics seems a bit overpowered, yes?
		return
	revealed = TRUE
	name = realName
	cooldownMax = rand(60,300)
	realProc = pick("teleport","explode","rapidDupe","petSpray","flash","clean","corgicannon")
	origin_tech = pick("engineering=[rand(2,5)]","magnets=[rand(2,5)]","plasmatech=[rand(2,5)]","programming=[rand(2,5)]","powerstorage=[rand(2,5)]")

/obj/item/weapon/relic/attack_self(mob/user)
	if(revealed)
		if(cooldown)
			user << "<span class='warning'>[src] does not react!</span>"
			return
		else if(src.loc == user)
			cooldown = TRUE
			call(src,realProc)(user)
			spawn(cooldownMax)
				cooldown = FALSE
	else
		user << "<span class='notice'>You aren't quite sure what to do with this yet.</span>"

//////////////// RELIC PROCS /////////////////////////////

/obj/item/weapon/relic/proc/throwSmoke(turf/where)
	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(0, get_turf(where))
	smoke.start()

/obj/item/weapon/relic/proc/corgicannon(mob/user)
	playsound(src.loc, "sparks", rand(25,50), 1)
	var/mob/living/simple_animal/pet/dog/corgi/C = new/mob/living/simple_animal/pet/dog/corgi(get_turf(user))
	C.throw_at(pick(oview(10,user)), 10, rand(3,8), callback = CALLBACK(src, .throwSmoke, C))
	warn_admins(user, "Corgi Cannon", 0)

/obj/item/weapon/relic/proc/clean(mob/user)
	playsound(src.loc, "sparks", rand(25,50), 1)
	var/obj/item/weapon/grenade/chem_grenade/cleaner/CL = new/obj/item/weapon/grenade/chem_grenade/cleaner(get_turf(user))
	CL.prime()
	warn_admins(user, "Smoke", 0)

/obj/item/weapon/relic/proc/flash(mob/user)
	playsound(src.loc, "sparks", rand(25,50), 1)
	var/obj/item/weapon/grenade/flashbang/CB = new/obj/item/weapon/grenade/flashbang(get_turf(user))
	CB.prime()
	warn_admins(user, "Flash")

/obj/item/weapon/relic/proc/petSpray(mob/user)
	var/message = "<span class='danger'>[src] begans to shake, and in the distance the sound of rampaging animals arises!</span>"
	visible_message(message)
	user << message
	var/animals = rand(1,25)
	var/counter
	var/list/valid_animals = list(/mob/living/simple_animal/parrot,/mob/living/simple_animal/butterfly,/mob/living/simple_animal/pet/cat,/mob/living/simple_animal/pet/dog/corgi,/mob/living/simple_animal/crab,/mob/living/simple_animal/pet/fox,/mob/living/simple_animal/hostile/lizard,/mob/living/simple_animal/mouse,/mob/living/simple_animal/pet/dog/pug,/mob/living/simple_animal/hostile/bear,/mob/living/simple_animal/hostile/poison/bees,/mob/living/simple_animal/hostile/carp)
	for(counter = 1; counter < animals; counter++)
		var/mobType = pick(valid_animals)
		new mobType(get_turf(src))
	warn_admins(user, "Mass Mob Spawn")
	if(prob(60))
		user << "<span class='warning'>[src] falls apart!</span>"
		qdel(src)

/obj/item/weapon/relic/proc/rapidDupe(mob/user)
	audible_message("[src] emits a loud pop!")
	var/list/dupes = list()
	var/counter
	var/max = rand(5,10)
	for(counter = 1; counter < max; counter++)
		var/obj/item/weapon/relic/R = new src.type(get_turf(src))
		R.name = name
		R.desc = desc
		R.realName = realName
		R.realProc = realProc
		R.revealed = TRUE
		dupes |= R
		R.throw_at(pick(oview(7,get_turf(src))),10,1)
	counter = 0
	spawn(rand(10,100))
		for(counter = 1; counter <= dupes.len; counter++)
			var/obj/item/weapon/relic/R = dupes[counter]
			qdel(R)
	warn_admins(user, "Rapid duplicator", 0)

/obj/item/weapon/relic/proc/explode(mob/user)
	user << "<span class='danger'>[src] begins to heat up!</span>"
	spawn(rand(35,100))
		if(src.loc == user)
			visible_message("<span class='notice'>The [src]'s top opens, releasing a powerful blast!</span>")
			explosion(user.loc, -1, rand(1,5), rand(1,5), rand(1,5), rand(1,5), flame_range = 2)
			warn_admins(user, "Explosion")
			qdel(src) //Comment this line to produce a light grenade (the bomb that keeps on exploding when used)!!

/obj/item/weapon/relic/proc/teleport(mob/user)
	user << "<span class='notice'>The [src] begins to vibrate!</span>"
	spawn(rand(10,30))
		var/turf/userturf = get_turf(user)
		if(src.loc == user && userturf.z != ZLEVEL_CENTCOM) //Because Nuke Ops bringing this back on their shuttle, then looting the ERT area is 2fun4you!
			visible_message("<span class='notice'>The [src] twists and bends, relocating itself!</span>")
			throwSmoke(userturf)
			do_teleport(user, userturf, 8, asoundin = 'sound/effects/phasein.ogg')
			throwSmoke(get_turf(user))
			warn_admins(user, "Teleport", 0)

//Admin Warning proc for relics
/obj/item/weapon/relic/proc/warn_admins(mob/user, RelicType, priority = 1)
	var/turf/T = get_turf(src)
	var/log_msg = "[RelicType] relic used by [key_name(user)] in ([T.x],[T.y],[T.z])"
	if(priority) //For truly dangerous relics that may need an admin's attention. BWOINK!
		message_admins("[RelicType] relic activated by [key_name_admin(user)](<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>) (<A HREF='?_src_=holder;adminplayerobservefollow=\ref[user]'>FLW</A>) in ([T.x],[T.y],[T.z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>JMP</a>)",0,1)
	log_game(log_msg)
	investigate_log(log_msg, "experimentor")
