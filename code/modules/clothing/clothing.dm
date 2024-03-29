/obj/item/clothing
	name = "clothing"
	resistance_flags = FLAMMABLE
	obj_integrity = 200
	max_integrity = 200
	integrity_failure = 80
	var/damaged_clothes = 0 //similar to machine's BROKEN stat and structure's broken var
	var/flash_protect = 0		//What level of bright light protection item has. 1 = Flashers, Flashes, & Flashbangs | 2 = Welding | -1 = OH GOD WELDING BURNT OUT MY RETINAS
	var/tint = 0				//Sets the item's level of visual impairment tint, normally set to the same as flash_protect
	var/up = 0					//but seperated to allow items to protect but not impair vision, like space helmets
	var/visor_flags = 0			//flags that are added/removed when an item is adjusted up/down
	var/visor_flags_inv = 0		//same as visor_flags, but for flags_inv
	var/visor_flags_cover = 0	//same as above, but for flags_cover
//what to toggle when toggled with weldingvisortoggle()
	var/visor_vars_to_toggle = VISOR_FLASHPROTECT | VISOR_TINT | VISOR_VISIONFLAGS | VISOR_DARKNESSVIEW | VISOR_INVISVIEW
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'
	var/alt_desc = null
	var/toggle_message = null
	var/alt_toggle_message = null
	var/active_sound = null
	var/toggle_cooldown = null
	var/cooldown = 0
	var/obj/item/device/flashlight/F = null
	var/can_flashlight = 0
	var/gang //Is this a gang outfit?
	var/scan_reagents = 0 //Can the wearer see reagents while it's equipped?

	//Var modification - PLEASE be careful with this I know who you are and where you live
	var/list/user_vars_to_edit = list() //VARNAME = VARVALUE eg: "name" = "butts"
	var/list/user_vars_remembered = list() //Auto built by the above + dropped() + equipped()

	var/obj/item/weapon/storage/internal/pocket/pockets = null

/obj/item/clothing/New()
	..()
	if(ispath(pockets))
		pockets = new pockets(src)

/obj/item/clothing/MouseDrop(atom/over_object)
	var/mob/M = usr

	if(pockets && over_object == M)
		return pockets.MouseDrop(over_object)

	if(istype(usr.loc,/obj/mecha)) // stops inventory actions in a mech
		return

	if(!M.restrained() && !M.stat && loc == M && istype(over_object, /obj/screen/inventory/hand))
		var/obj/screen/inventory/hand/H = over_object
		if(!M.temporarilyRemoveItemFromInventory(src))
			return
		if(!M.put_in_hand(src, H.held_index))
			qdel(src)
			return
		add_fingerprint(usr)

/obj/item/clothing/throw_at(atom/target, range, speed, mob/thrower, spin=1, diagonals_first = 0, datum/callback/callback)
	if(pockets)
		pockets.close_all()
	return ..()

/obj/item/clothing/attack_hand(mob/user)
	if(pockets && pockets.priority && ismob(loc))
		//If we already have the pockets open, close them.
		if (user.s_active == pockets)
			pockets.close(user)
		//Close whatever the user has open and show them the pockets.
		else
			if (user.s_active)
				user.s_active.close(user)
			pockets.orient2hud(user)
			pockets.show_to(user)
	else
		return ..()

/obj/item/clothing/attackby(obj/item/W, mob/user, params)
	if(damaged_clothes && istype(W, /obj/item/stack/sheet/cloth))
		var/obj/item/stack/sheet/cloth/C = W
		C.use(1)
		update_clothes_damaged_state(FALSE)
		obj_integrity = max_integrity
		user << "<span class='notice'>You fix the damages on [src] with [C].</span>"
		return 1
	if(pockets)
		var/i = pockets.attackby(W, user, params)
		if(i)
			return i
	return ..()

/obj/item/clothing/AltClick(mob/user)
	if(pockets && pockets.quickdraw && pockets.contents.len && !user.incapacitated())
		var/obj/item/I = pockets.contents[1]
		if(!I)
			return
		pockets.remove_from_storage(I, get_turf(src))

		if(!user.put_in_hands(I))
			user << "<span class='notice'>You fumble for [I] and it falls on the floor.</span>"
			return 1
		user.visible_message("<span class='warning'>[user] draws [I] from [src]!</span>", "<span class='notice'>You draw [I] from [src].</span>")
		return 1
	else
		return ..()


/obj/item/clothing/Destroy()
	if(isliving(loc))
		dropped(loc)
	if(pockets)
		qdel(pockets)
		pockets = null
	user_vars_remembered = null //Oh god somebody put REFERENCES in here? not to worry, we'll clean it up
	return ..()


/obj/item/clothing/dropped(mob/user)
	..()
	if(user_vars_remembered && user_vars_remembered.len)
		for(var/variable in user_vars_remembered)
			if(variable in user.vars)
				if(user.vars[variable] == user_vars_to_edit[variable]) //Is it still what we set it to? (if not we best not change it)
					user.vars[variable] = user_vars_remembered[variable]
		user_vars_remembered = list()


/obj/item/clothing/equipped(mob/user, slot)
	..()

	if(slot_flags & slotdefine2slotbit(slot)) //Was equipped to a valid slot for this item?
		for(var/variable in user_vars_to_edit)
			if(variable in user.vars)
				user_vars_remembered[variable] = user.vars[variable]
				user.vars[variable] = user_vars_to_edit[variable]


/obj/item/clothing/examine(mob/user)
	..()
	if(damaged_clothes)
		user <<  "<span class='warning'>It looks damaged!</span>"

/obj/item/clothing/obj_break(damage_flag)
	if(!damaged_clothes)
		update_clothes_damaged_state(TRUE)

var/list/damaged_clothes_icons = list()

/obj/item/clothing/proc/update_clothes_damaged_state(damaging = TRUE)
	var/index = "\ref[initial(icon)]-[initial(icon_state)]"
	if(damaging)
		damaged_clothes = 1
		var/icon/damaged_clothes_icon = damaged_clothes_icons[index]
		if(!damaged_clothes_icon)
			damaged_clothes_icon = icon(initial(icon), initial(icon_state), , 1)	//we only want to apply damaged effect to the initial icon_state for each object
			damaged_clothes_icon.Blend("#fff", ICON_ADD) 	//fills the icon_state with white (except where it's transparent)
			damaged_clothes_icon.Blend(icon('icons/effects/item_damage.dmi', "itemdamaged"), ICON_MULTIPLY) //adds damage effect and the remaining white areas become transparant
			damaged_clothes_icon = fcopy_rsc(damaged_clothes_icon)
			damaged_clothes_icons[index] = damaged_clothes_icon
		add_overlay(damaged_clothes_icon, 1)
	else
		damaged_clothes = 0
		overlays -= damaged_clothes_icons[index]
		priority_overlays -= damaged_clothes_icons[index]


//Ears: currently only used for headsets and earmuffs
/obj/item/clothing/ears
	name = "ears"
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	slot_flags = SLOT_EARS
	resistance_flags = 0

/obj/item/clothing/ears/earmuffs
	name = "earmuffs"
	desc = "Protects your hearing from loud noises, and quiet ones as well."
	icon_state = "earmuffs"
	item_state = "earmuffs"
	flags = EARBANGPROTECT
	strip_delay = 15
	put_on_delay = 25
	resistance_flags = FLAMMABLE

//Glasses
/obj/item/clothing/glasses
	name = "glasses"
	icon = 'icons/obj/clothing/glasses.dmi'
	w_class = WEIGHT_CLASS_SMALL
	flags_cover = GLASSESCOVERSEYES
	slot_flags = SLOT_EYES
	var/vision_flags = 0
	var/darkness_view = 2//Base human is 2
	var/invis_view = SEE_INVISIBLE_LIVING
	var/invis_override = 0 //Override to allow glasses to set higher than normal see_invis
	var/emagged = 0
	var/list/icon/current = list() //the current hud icons
	var/vision_correction = 0 //does wearing these glasses correct some of our vision defects?
	strip_delay = 20
	put_on_delay = 25
	resistance_flags = 0
/*
SEE_SELF  // can see self, no matter what
SEE_MOBS  // can see all mobs, no matter what
SEE_OBJS  // can see all objs, no matter what
SEE_TURFS // can see all turfs (and areas), no matter what
SEE_PIXELS// if an object is located on an unlit area, but some of its pixels are
          // in a lit area (via pixel_x,y or smooth movement), can see those pixels
BLIND     // can't see anything
*/


//Gloves
/obj/item/clothing/gloves
	name = "gloves"
	gender = PLURAL //Carn: for grammarically correct text-parsing
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/clothing/gloves.dmi'
	siemens_coefficient = 0.50
	body_parts_covered = HANDS
	slot_flags = SLOT_GLOVES
	attack_verb = list("challenged")
	var/transfer_prints = FALSE
	strip_delay = 20
	put_on_delay = 40


/obj/item/clothing/gloves/worn_overlays(isinhands = FALSE)
	. = list()
	if(!isinhands)
		if(damaged_clothes)
			. += image("icon"='icons/effects/item_damage.dmi', "icon_state"="damagedgloves")
		if(blood_DNA)
			. += image("icon"='icons/effects/blood.dmi', "icon_state"="bloodyhands")

/obj/item/clothing/gloves/update_clothes_damaged_state(damaging = TRUE)
	..()
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_gloves()

// Called just before an attack_hand(), in mob/UnarmedAttack()
/obj/item/clothing/gloves/proc/Touch(atom/A, proximity)
	return 0 // return 1 to cancel attack_hand()

//Head
/obj/item/clothing/head
	name = "head"
	icon = 'icons/obj/clothing/hats.dmi'
	body_parts_covered = HEAD
	slot_flags = SLOT_HEAD
	var/blockTracking = 0 //For AI tracking
	var/can_toggle = null


/obj/item/clothing/head/worn_overlays(isinhands = FALSE)
	. = list()
	if(!isinhands)
		if(damaged_clothes)
			. += image("icon"='icons/effects/item_damage.dmi', "icon_state"="damagedhelmet")
		if(blood_DNA)
			. += image("icon"='icons/effects/blood.dmi', "icon_state"="helmetblood")

/obj/item/clothing/head/update_clothes_damaged_state(damaging = TRUE)
	..()
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_head()


//Neck
/obj/item/clothing/neck
	name = "necklace"
	icon = 'icons/obj/clothing/neck.dmi'
	body_parts_covered = NECK
	slot_flags = SLOT_NECK
	strip_delay = 40
	put_on_delay = 40

/obj/item/clothing/neck/worn_overlays(isinhands = FALSE)
	. = list()
	if(!isinhands)
		if(body_parts_covered & HEAD)
			if(damaged_clothes)
				. += image("icon"='icons/effects/item_damage.dmi', "icon_state"="damagedmask")
			if(blood_DNA)
				. += image("icon"='icons/effects/blood.dmi', "icon_state"="maskblood")


//Mask
/obj/item/clothing/mask
	name = "mask"
	icon = 'icons/obj/clothing/masks.dmi'
	body_parts_covered = HEAD
	slot_flags = SLOT_MASK
	strip_delay = 40
	put_on_delay = 40
	var/mask_adjusted = 0
	var/adjusted_flags = null


/obj/item/clothing/mask/worn_overlays(isinhands = FALSE)
	. = list()
	if(!isinhands)
		if(body_parts_covered & HEAD)
			if(damaged_clothes)
				. += image("icon"='icons/effects/item_damage.dmi', "icon_state"="damagedmask")
			if(blood_DNA)
				. += image("icon"='icons/effects/blood.dmi', "icon_state"="maskblood")

/obj/item/clothing/mask/update_clothes_damaged_state(damaging = TRUE)
	..()
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_wear_mask()


//Override this to modify speech like luchador masks.
/obj/item/clothing/mask/proc/speechModification(message)
	return message

//Proc that moves gas/breath masks out of the way, disabling them and allowing pill/food consumption
/obj/item/clothing/mask/proc/adjustmask(mob/living/user)
	if(user && user.incapacitated())
		return
	mask_adjusted = !mask_adjusted
	if(!mask_adjusted)
		src.icon_state = initial(icon_state)
		gas_transfer_coefficient = initial(gas_transfer_coefficient)
		permeability_coefficient = initial(permeability_coefficient)
		flags |= visor_flags
		flags_inv |= visor_flags_inv
		flags_cover |= visor_flags_cover
		user << "<span class='notice'>You push \the [src] back into place.</span>"
		slot_flags = initial(slot_flags)
	else
		icon_state += "_up"
		user << "<span class='notice'>You push \the [src] out of the way.</span>"
		gas_transfer_coefficient = null
		permeability_coefficient = null
		flags &= ~visor_flags
		flags_inv &= ~visor_flags_inv
		flags_cover &= ~visor_flags_cover
		if(adjusted_flags)
			slot_flags = adjusted_flags
	if(user)
		user.wear_mask_update(src, toggle_off = mask_adjusted)
		user.update_action_buttons_icon() //when mask is adjusted out, we update all buttons icon so the user's potential internal tank correctly shows as off.




//Shoes
/obj/item/clothing/shoes
	name = "shoes"
	icon = 'icons/obj/clothing/shoes.dmi'
	desc = "Comfortable-looking shoes."
	gender = PLURAL //Carn: for grammarically correct text-parsing
	var/chained = 0

	body_parts_covered = FEET
	slot_flags = SLOT_FEET

	permeability_coefficient = 0.50
	slowdown = SHOES_SLOWDOWN
	var/blood_state = BLOOD_STATE_NOT_BLOODY
	var/list/bloody_shoes = list(BLOOD_STATE_HUMAN = 0,BLOOD_STATE_XENO = 0, BLOOD_STATE_OIL = 0, BLOOD_STATE_NOT_BLOODY = 0)

/obj/item/clothing/shoes/worn_overlays(isinhands = FALSE)
	. = list()
	if(!isinhands)
		var/bloody = 0
		if(blood_DNA)
			bloody = 1
		else
			bloody = bloody_shoes[BLOOD_STATE_HUMAN]

		if(damaged_clothes)
			. += image("icon"='icons/effects/item_damage.dmi', "icon_state"="damagedshoe")
		if(bloody)
			. += image("icon"='icons/effects/blood.dmi', "icon_state"="shoeblood")

/obj/item/clothing/shoes/update_clothes_damaged_state(damaging = TRUE)
	..()
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_shoes()

/obj/item/clothing/shoes/clean_blood()
	..()
	bloody_shoes = list(BLOOD_STATE_HUMAN = 0,BLOOD_STATE_XENO = 0, BLOOD_STATE_OIL = 0, BLOOD_STATE_NOT_BLOODY = 0)
	blood_state = BLOOD_STATE_NOT_BLOODY
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_shoes()

/obj/item/proc/negates_gravity()
	return 0

//Suit
/obj/item/clothing/suit
	icon = 'icons/obj/clothing/suits.dmi'
	name = "suit"
	var/fire_resist = T0C+100
	allowed = list(/obj/item/weapon/tank/internals/emergency_oxygen)
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0, fire = 0, acid = 0)
	slot_flags = SLOT_OCLOTHING
	var/blood_overlay_type = "suit"
	var/togglename = null


/obj/item/clothing/suit/worn_overlays(isinhands = FALSE)
	. = list()
	if(!isinhands)
		if(damaged_clothes)
			. += image("icon"='icons/effects/item_damage.dmi', "icon_state"="damaged[blood_overlay_type]")
		if(blood_DNA)
			. += image("icon"='icons/effects/blood.dmi', "icon_state"="[blood_overlay_type]blood")

/obj/item/clothing/suit/update_clothes_damaged_state(damaging = TRUE)
	..()
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_wear_suit()

//Spacesuit
//Note: Everything in modules/clothing/spacesuits should have the entire suit grouped together.
//      Meaning the the suit is defined directly after the corrisponding helmet. Just like below!
/obj/item/clothing/head/helmet/space
	name = "space helmet"
	icon_state = "spaceold"
	desc = "A special helmet with solar UV shielding to protect your eyes from harmful rays."
	flags = STOPSPRESSUREDMAGE | THICKMATERIAL
	item_state = "spaceold"
	permeability_coefficient = 0.01
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 50, fire = 80, acid = 70)
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT
	flash_protect = 2
	strip_delay = 50
	put_on_delay = 50
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	resistance_flags = 0

/obj/item/clothing/suit/space
	name = "space suit"
	desc = "A suit that protects against low pressure environments. Has a big 13 on the back."
	icon_state = "spaceold"
	item_state = "s_suit"
	w_class = WEIGHT_CLASS_BULKY
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.02
	flags = STOPSPRESSUREDMAGE | THICKMATERIAL
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/internals)
	slowdown = 1
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 50, fire = 80, acid = 70)
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	cold_protection = CHEST | GROIN | LEGS | FEET | ARMS | HANDS
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	strip_delay = 80
	put_on_delay = 80
	resistance_flags = 0

//Under clothing

/obj/item/clothing/under
	icon = 'icons/obj/clothing/uniforms.dmi'
	name = "under"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	permeability_coefficient = 0.90
	slot_flags = SLOT_ICLOTHING
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0, fire = 0, acid = 0)
	var/fitted = FEMALE_UNIFORM_FULL // For use in alternate clothing styles for women
	var/has_sensor = 1//For the crew computer 2 = unable to change mode
	var/random_sensor = 1
	var/sensor_mode = 0	/* 1 = Report living/dead, 2 = Report detailed damages, 3 = Report location */
	var/can_adjust = 1
	var/adjusted = NORMAL_STYLE
	var/alt_covers_chest = 0 // for adjusted/rolled-down jumpsuits, 0 = exposes chest and arms, 1 = exposes arms only
	var/obj/item/clothing/tie/hastie = null
	var/mutantrace_variation = NO_MUTANTRACE_VARIATION //Are there special sprites for specific situations? Don't use this unless you need to.

/obj/item/clothing/under/worn_overlays(isinhands = FALSE)
	. = list()

	if(!isinhands)

		if(damaged_clothes)
			. += image("icon"='icons/effects/item_damage.dmi', "icon_state"="damageduniform")
		if(blood_DNA)
			. += image("icon"='icons/effects/blood.dmi', "icon_state"="uniformblood")
		if(hastie)
			var/tie_color = hastie.item_color
			if(!tie_color)
				tie_color = hastie.icon_state
			var/image/tI = image("icon"='icons/mob/ties.dmi', "icon_state"="[tie_color]")
			tI.alpha = hastie.alpha
			tI.color = hastie.color
			. += tI

/obj/item/clothing/under/update_clothes_damaged_state(damaging = TRUE)
	..()
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_w_uniform()

/obj/item/clothing/under/New()
	if(random_sensor)
		//make the sensor mode favor higher levels, except coords.
		sensor_mode = pick(0, 1, 1, 2, 2, 2, 3, 3)
	adjusted = NORMAL_STYLE
	..()

/obj/item/clothing/under/equipped(mob/user, slot)
	..()
	if(adjusted)
		adjusted = NORMAL_STYLE
		fitted = initial(fitted)
		if(!alt_covers_chest)
			body_parts_covered |= CHEST

	if(mutantrace_variation && ishuman(user))
		var/mob/living/carbon/human/H = user
		if(DIGITIGRADE in H.dna.species.species_traits)
			adjusted = DIGITIGRADE_STYLE
		H.update_inv_w_uniform()

	if(hastie && slot != slot_hands)
		hastie.on_uniform_equip(src, user)

/obj/item/clothing/under/dropped(mob/user)
	if(hastie)
		hastie.on_uniform_dropped(src, user)
	..()

/obj/item/clothing/under/attackby(obj/item/I, mob/user, params)
	if(!attachTie(I, user))
		..()

/obj/item/clothing/under/proc/attachTie(obj/item/I, mob/user, notifyAttach = 1)
	if(istype(I, /obj/item/clothing/tie))
		var/obj/item/clothing/tie/T = I
		if(hastie)
			if(user)
				user << "<span class='warning'>[src] already has an accessory.</span>"
			return 0
		else
			if(user && !user.drop_item())
				return
			if(!T.attach(src, user))
				return

			if(user && notifyAttach)
				user << "<span class='notice'>You attach [I] to [src].</span>"

			if(ishuman(loc))
				var/mob/living/carbon/human/H = loc
				H.update_inv_w_uniform()

			return 1

/obj/item/clothing/under/proc/removetie(mob/user)
	if(!isliving(user))
		return
	if(!can_use(user))
		return

	if(hastie)
		var/obj/item/clothing/tie/T = hastie
		hastie.detach(src, user)
		if(user.put_in_hands(T))
			user << "<span class='notice'>You detach [T] from [src].</span>"
		else
			user << "<span class='notice'>You detach [T] from [src] and it falls on the floor.</span>"

		if(ishuman(loc))
			var/mob/living/carbon/human/H = loc
			H.update_inv_w_uniform()


/obj/item/clothing/under/examine(mob/user)
	..()
	if(can_adjust)
		if(adjusted == ALT_STYLE)
			user << "Alt-click on [src] to wear it normally."
		else
			user << "Alt-click on [src] to wear it casually."
	switch(sensor_mode)
		if(0)
			user << "Its sensors appear to be disabled."
		if(1)
			user << "Its binary life sensors appear to be enabled."
		if(2)
			user << "Its vital tracker appears to be enabled."
		if(3)
			user << "Its vital tracker and tracking beacon appear to be enabled."
	if(hastie)
		user << "\A [hastie] is attached to it."

/proc/generate_female_clothing(index,t_color,icon,type)
	var/icon/female_clothing_icon	= icon("icon"=icon, "icon_state"=t_color)
	var/icon/female_s				= icon("icon"='icons/mob/uniform.dmi', "icon_state"="[(type == FEMALE_UNIFORM_FULL) ? "female_full" : "female_top"]")
	female_clothing_icon.Blend(female_s, ICON_MULTIPLY)
	female_clothing_icon 			= fcopy_rsc(female_clothing_icon)
	female_clothing_icons[index] = female_clothing_icon

/obj/item/clothing/under/verb/toggle()
	set name = "Adjust Suit Sensors"
	set category = "Object"
	set src in usr
	var/mob/M = usr
	if (istype(M, /mob/dead/))
		return
	if (!can_use(M))
		return
	if(src.has_sensor >= 2)
		usr << "The controls are locked."
		return 0
	if(src.has_sensor <= 0)
		usr << "This suit does not have any sensors."
		return 0

	var/list/modes = list("Off", "Binary vitals", "Exact vitals", "Tracking beacon")
	var/switchMode = input("Select a sensor mode:", "Suit Sensor Mode", modes[sensor_mode + 1]) in modes
	if(get_dist(usr, src) > 1)
		usr << "<span class='warning'>You have moved too far away!</span>"
		return
	sensor_mode = modes.Find(switchMode) - 1

	if (src.loc == usr)
		switch(sensor_mode)
			if(0)
				usr << "<span class='notice'>You disable your suit's remote sensing equipment.</span>"
			if(1)
				usr << "<span class='notice'>Your suit will now only report whether you are alive or dead.</span>"
			if(2)
				usr << "<span class='notice'>Your suit will now only report your exact vital lifesigns.</span>"
			if(3)
				usr << "<span class='notice'>Your suit will now report your exact vital lifesigns as well as your coordinate position.</span>"

	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		if(H.w_uniform == src)
			H.update_suit_sensors()

	..()

/obj/item/clothing/under/AltClick(mob/user)
	if(..())
		return 1

	if(!user.canUseTopic(src, be_close=TRUE))
		user << "<span class='warning'>You can't do that right now!</span>"
		return
	else
		if(hastie)
			removetie(user)
		else
			rolldown()

/obj/item/clothing/under/verb/jumpsuit_adjust()
	set name = "Adjust Jumpsuit Style"
	set category = null
	set src in usr
	rolldown()

/obj/item/clothing/under/proc/rolldown()
	if(!can_use(usr))
		return
	if(!can_adjust)
		usr << "<span class='warning'>You cannot wear this suit any differently!</span>"
		return
	if(toggle_jumpsuit_adjust())
		usr << "<span class='notice'>You adjust the suit to wear it more casually.</span>"
	else
		usr << "<span class='notice'>You adjust the suit back to normal.</span>"
	if(ishuman(usr))
		var/mob/living/carbon/human/H = usr
		H.update_inv_w_uniform()
		H.update_body()

/obj/item/clothing/under/proc/toggle_jumpsuit_adjust()
	if(adjusted == DIGITIGRADE_STYLE)
		return
	adjusted = !adjusted
	if(adjusted)
		if(fitted != FEMALE_UNIFORM_TOP)
			fitted = NO_FEMALE_UNIFORM
		if(!alt_covers_chest) // for the special snowflake suits that expose the chest when adjusted
			body_parts_covered &= ~CHEST
	else
		fitted = initial(fitted)
		if(!alt_covers_chest)
			body_parts_covered |= CHEST
	return adjusted

/obj/item/clothing/proc/weldingvisortoggle(mob/user) //proc to toggle welding visors on helmets, masks, goggles, etc.
	if(!can_use(user))
		return FALSE

	visor_toggling()

	user << "<span class='notice'>You adjust \the [src] [up ? "up" : "down"].</span>"

	if(iscarbon(user))
		var/mob/living/carbon/C = user
		C.head_update(src, forced = 1)
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()
	return TRUE

/obj/item/clothing/proc/visor_toggling() //handles all the actual toggling of flags
	up = !up
	flags ^= visor_flags
	flags_inv ^= visor_flags_inv
	flags_cover ^= initial(flags_cover)
	icon_state = "[initial(icon_state)][up ? "up" : ""]"
	if(visor_vars_to_toggle & VISOR_FLASHPROTECT)
		flash_protect ^= initial(flash_protect)
	if(visor_vars_to_toggle & VISOR_TINT)
		tint ^= initial(tint)


/obj/item/clothing/proc/can_use(mob/user)
	if(user && ismob(user))
		if(!user.incapacitated())
			return 1
	return 0


/obj/item/clothing/obj_destruction(damage_flag)
	if(damage_flag == "bomb" || damage_flag == "melee")
		var/turf/T = get_turf(src)
		spawn(1) //so the shred survives potential turf change from the explosion.
			var/obj/effect/decal/cleanable/shreds/Shreds = new(T)
			Shreds.desc = "The sad remains of what used to be [name]."
		deconstruct(FALSE)
	else
		..()
