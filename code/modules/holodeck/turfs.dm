
/turf/open/floor/holofloor
	icon_state = "floor"
	thermal_conductivity = 0
	broken_states = list("engine")
	burnt_states = list("engine")
	flags = NONE

/turf/open/floor/holofloor/attackby(obj/item/I, mob/living/user)
	return // HOLOFLOOR DOES NOT GIVE A FUCK

/turf/open/floor/holofloor/plating
	name = "holodeck projector floor"
	icon_state = "engine"

/turf/open/floor/holofloor/plating/burnmix
	name = "burn-mix floor"
	initial_gas_mix = "o2=2500;plasma=5000;TEMP=370"

/turf/open/floor/holofloor/grass
	gender = PLURAL
	name = "lush grass"
	icon_state = "grass"

/turf/open/floor/holofloor/beach
	name = "sand"
	icon = 'icons/misc/beach.dmi'
	icon_state = "sand"

/turf/open/floor/holofloor/beach/coast_t
	name = "coastline"
	icon_state = "sandwater_t"

/turf/open/floor/holofloor/beach/coast_b
	name = "coastline"
	icon_state = "sandwater_b"

/turf/open/floor/holofloor/beach/water
	name = "water"
	icon_state = "water"

/turf/open/floor/holofloor/asteroid
	name = "asteroid"
	icon_state = "asteroid0"
/turf/simulated/floor/wasteland/airless/cave
	var/length = 100

	var/mob_spawn_list = list("Badmutant" = 1, "Casador" = 3, "Rat" = 20)
	var/sanity = 1

/turf/indestructible/riveted
	icon_state = "riveted"

/turf/indestructible/riveted/New()
	..()
	if(smooth)
		smooth_icon(src)
		icon_state = ""

/turf/indestructible/riveted/uranium
	icon = 'icons/turf/walls/uranium_wall.dmi'
	icon_state = "uranium"
	smooth = SMOOTH_TRUE

/turf/indestructible/abductor
	icon_state = "alien1"

/turf/indestructible/fakeglass
	name = "window"
	icon_state = "fakewindows"
	opacity = 0

/turf/indestructible/fakedoor
	name = "Centcom Access"
	icon = 'icons/obj/doors/airlocks/centcom/centcom.dmi'
	icon_state = "fake_door"

/turf/indestructible/rock
	name = "dense rock"
	desc = "An extremely densely-packed rock, most mining tools or explosives would never get through this."
	icon = 'icons/turf/mining.dmi'
	icon_state = "rock"
//Test wall for Fallout 13

/turf/indestructible/repconn //Space Age baby!
	name = "wall"
	desc = "All in all you're just another brick in the wall."
	icon = 'icons/turf/walls.dmi'
	icon_state = "rock_labor"

/turf/indestructible/robco //I'm an automatic man!
	name = "window"
	icon = 'icons/turf/walls.dmi'
	icon_state = "wastelandwindowfull"
	opacity = 0

/turf/indestructible/corvega //Driving paradise!
	name = "locked door"
	//icon = 'icons/obj/doors/wasteland_doors.dmi'
	icon_state = "dirtystorechain"
	density = 1

/turf/indestructible/matrix //The Chosen One from Arroyo!
	name = "matrix"
	desc = "<font color='#157206'>You suddenly realize the truth - there is no spoon.<br>Digital simulation ends here.</font>"
	icon = 'icons/turf/walls.dmi'
	icon_state = "matrix"

/turf/indestructible/tunnel
	name = "tunnel"
	desc = "Just rapid moving wall"
	icon = 'icons/turf/walls.dmi'
	icon_state = "Moving_tunnel"
/turf/simulated/floor/wasteland/mountain
	name = "mountain"
	desc = "It's rocky floor."
	//icon = 'icons/turf/floors2.dmi'
	baseturf = /turf/simulated/floor/wasteland/mountain
	icon_state = "mountain"
	//temperature = 370

/turf/simulated/floor/wasteland/snow/airless
	//temperature = TCMB

/turf/simulated/floor/wasteland/New()
	var/proper_name = name
	..()
	name = proper_name
	//if(prob(20))
		//con_state = "[environment_type][rand(0,12)]"

/turf/simulated/floor/wasteland/burn_tile()
	return

/*/turf/simulated/floor/wasteland/ex_act(severity, target)
	contents_explosion(severity, target)
	switch(severity)
		if(3)
			return
		if(2)
			if (prob(20))
				src.gets_dug()
		if(1)
			src.gets_dug()
	return*/

/turf/simulated/floor/wasteland/singularity_act()
	return

/turf/simulated/floor/wasteland/singularity_pull(S, current_size)
	return

/turf/open/floor/holofloor/asteroid/New()
	icon_state = "asteroid[pick(0,1,2,3,4,5,6,7,8,9,10,11,12)]"
	..()

/turf/open/floor/holofloor/basalt
	name = "basalt"
	icon_state = "basalt0"

/turf/open/floor/holofloor/basalt/New()
	icon_state = "basalt[pick(0,1,2,3,4,5,6,7,8,9,10,11,12)]"
	..()

/turf/open/floor/holofloor/space
	name = "Space"
	icon = 'icons/turf/space.dmi'
	icon_state = "0"

/turf/open/floor/holofloor/space/New()
	icon_state = SPACE_ICON_STATE // so realistic
	..()

/turf/open/floor/holofloor/hyperspace
	name = "hyperspace"
	icon = 'icons/turf/space.dmi'
	icon_state = "speedspace_ns_1"

/turf/open/floor/holofloor/hyperspace/New()
	icon_state = "speedspace_ns_[(x + 5*y + (y%2+1)*7)%15+1]"
	..()

/turf/open/floor/holofloor/hyperspace/ns/New()
	..()
	icon_state = "speedspace_ns_[(x + 5*y + (y%2+1)*7)%15+1]"

/turf/open/floor/holofloor/carpet
	name = "carpet"
	desc = "Electrically inviting."
	icon = 'icons/turf/floors/carpet.dmi'
	icon_state = "carpet"
	floor_tile = /obj/item/stack/tile/carpet
	broken_states = list("damaged")
	smooth = SMOOTH_TRUE
	canSmoothWith = null

/turf/open/floor/holofloor/carpet/New()
	..()
	addtimer(CALLBACK(src, .proc/update_icon), 1)

/turf/open/floor/holofloor/carpet/update_icon()
	if(!..())
		return 0
	if(intact)
		queue_smooth(src)

/turf/open/floor/holofloor/snow
	name = "snow"
	desc = "Looks cold."
	icon = 'icons/turf/snow.dmi'
	icon_state = "snow"
	slowdown = 2

/turf/open/floor/holofloor/snow/cold
	initial_gas_mix = "freon=7500;TEMP=0"

/turf/open/floor/holofloor/asteroid
	name = "asteroid sand"
	icon = 'icons/turf/floors.dmi'
	icon_state = "asteroid"
