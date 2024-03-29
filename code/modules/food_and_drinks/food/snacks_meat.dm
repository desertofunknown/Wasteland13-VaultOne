//Not only meat, actually, but also snacks that are almost meat, such as fish meat or tofu


////////////////////////////////////////////FISH////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/cubancarp
	name = "\improper Cuban carp"
	desc = "A grifftastic sandwich that burns your tongue and then leaves it numb!"
	icon_state = "cubancarp"
	trash = /obj/item/trash/plate
	bonus_reagents = list("nutriment" = 1, "vitamin" = 4)
	bitesize = 3
	filling_color = "#CD853F"
	list_reagents = list("nutriment" = 6, "capsaicin" = 1)

/obj/item/weapon/reagent_containers/food/snacks/carpmeat
	name = "carp fillet"
	desc = "A fillet of spess carp meat."
	icon_state = "fishfillet"
	list_reagents = list("nutriment" = 3, "carpotoxin" = 2, "vitamin" = 2)
	bitesize = 6
	filling_color = "#FA8072"

/obj/item/weapon/reagent_containers/food/snacks/gekkonmeat
	name = "gekkon fillet"
	desc = "A fillet of gekkon meat."
	icon_state = "fishfillet"
	list_reagents = list("nutriment" = 6, "carpotoxin" = 1, "vitamin" = 4)
	bitesize = 6
	filling_color = "#FA8072"

/obj/item/weapon/reagent_containers/food/snacks/moleratmeat
	name = "molerat fillet"
	desc = "A fillet of molerat meat."
	icon_state = "fishfillet"
	list_reagents = list("nutriment" = 3, "carpotoxin" = 3)
	bitesize = 6
	filling_color = "#FA8072"

/obj/item/weapon/reagent_containers/food/snacks/deathmeat
	name = "deathclaw fillet"
	desc = "A fillet of deathclaw meat."
	icon_state = "fishfillet"
	list_reagents = list("nutriment" = 9, "vitamin" = 9)
	bitesize = 6
	filling_color = "#FA8072"

/obj/item/weapon/reagent_containers/food/snacks/carpmeat/New()
	..()
	eatverb = pick("bite","chew","choke down","gnaw","swallow","chomp")

/obj/item/weapon/reagent_containers/food/snacks/carpmeat/imitation
	name = "imitation carp fillet"
	desc = "Almost just like the real thing, kinda."

/obj/item/weapon/reagent_containers/food/snacks/fishfingers
	name = "fish fingers"
	desc = "A finger of fish."
	icon_state = "fishfingers"
	bonus_reagents = list("nutriment" = 1, "vitamin" = 2)
	list_reagents = list("nutriment" = 4)
	bitesize = 1
	filling_color = "#CD853F"

/obj/item/weapon/reagent_containers/food/snacks/fishandchips
	name = "fish and chips"
	desc = "I do say so myself chap."
	icon_state = "fishandchips"
	bonus_reagents = list("nutriment" = 1, "vitamin" = 2)
	list_reagents = list("nutriment" = 6)
	filling_color = "#FA8072"

////////////////////////////////////////////MEATS AND ALIKE////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/tofu
	name = "tofu"
	desc = "We all love tofu."
	icon_state = "tofu"
	list_reagents = list("nutriment" = 2)
	filling_color = "#F0E68C"

/obj/item/weapon/reagent_containers/food/snacks/spiderleg
	name = "spider leg"
	desc = "A still twitching leg of a giant spider... you don't really want to eat this, do you?"
	icon_state = "spiderleg"
	list_reagents = list("nutriment" = 2, "toxin" = 2)
	cooked_type = /obj/item/weapon/reagent_containers/food/snacks/boiledspiderleg
	filling_color = "#000000"

/obj/item/weapon/reagent_containers/food/snacks/cornedbeef
	name = "corned beef and cabbage"
	desc = "Now you can feel like a real tourist vacationing in Ireland."
	icon_state = "cornedbeef"
	trash = /obj/item/trash/plate
	bonus_reagents = list("nutriment" = 1, "vitamin" = 4)
	list_reagents = list("nutriment" = 5)

/obj/item/weapon/reagent_containers/food/snacks/bearsteak
	name = "Filet migrawr"
	desc = "Because eating bear wasn't manly enough."
	icon_state = "bearsteak"
	trash = /obj/item/trash/plate
	bonus_reagents = list("nutriment" = 2, "vitamin" = 6)
	list_reagents = list("nutriment" = 2, "vitamin" = 5, "manlydorf" = 5)

/obj/item/weapon/reagent_containers/food/snacks/faggot
	name = "faggot"
	desc = "A great meal all round. Not a cord of wood."
	icon_state = "faggot"
	list_reagents = list("nutriment" = 4, "vitamin" = 1)
	filling_color = "#800000"

/obj/item/weapon/reagent_containers/food/snacks/sausage
	name = "sausage"
	desc = "A piece of mixed, long meat."
	icon_state = "sausage"
	filling_color = "#CD5C5C"
	bonus_reagents = list("nutriment" = 1, "vitamin" = 1)
	list_reagents = list("nutriment" = 6, "vitamin" = 1)

/obj/item/weapon/reagent_containers/food/snacks/sausage/New()
	..()
	eatverb = pick("bite","chew","nibble","deep throat","gobble","chomp")

/obj/item/weapon/reagent_containers/food/snacks/kebab
	trash = /obj/item/stack/rods
	icon_state = "kebab"
	w_class = WEIGHT_CLASS_NORMAL
	list_reagents = list("nutriment" = 8)

/obj/item/weapon/reagent_containers/food/snacks/kebab/human
	name = "human-kebab"
	desc = "A human meat, on a stick."
	bonus_reagents = list("nutriment" = 1, "vitamin" = 6)

/obj/item/weapon/reagent_containers/food/snacks/kebab/monkey
	name = "meat-kebab"
	desc = "Delicious meat, on a stick."
	bonus_reagents = list("nutriment" = 1, "vitamin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/kebab/tofu
	name = "tofu-kebab"
	desc = "Vegan meat, on a stick."
	bonus_reagents = list("nutriment" = 1)

/obj/item/weapon/reagent_containers/food/snacks/kebab/tail
	name = "lizard-tail kebab"
	desc = "Severed lizard tail on a stick."
	bonus_reagents = list("nutriment" = 1, "vitamin" = 4)

/obj/item/weapon/reagent_containers/food/snacks/rawkhinkali
	name = "raw khinkali"
	desc = "One hundred khinkalis? Do I look like a pig?"
	icon_state = "khinkali"
	list_reagents = list("nutriment" = 1, "vitamin" = 1)
	cooked_type = /obj/item/weapon/reagent_containers/food/snacks/khinkali

/obj/item/weapon/reagent_containers/food/snacks/khinkali
	name = "khinkali"
	desc = "One hundred khinkalis? Do I look like a pig?"
	icon_state = "khinkali"
	list_reagents = list("nutriment" = 4, "vitamin" = 2)
	bitesize = 3
	filling_color = "#F0F0F0"

/obj/item/weapon/reagent_containers/food/snacks/monkeycube
	name = "monkey cube"
	desc = "Just add water!"
	icon_state = "monkeycube"
	bitesize = 12
	list_reagents = list("nutriment" = 2)
	filling_color = "#CD853F"

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/proc/Expand()
	visible_message("<span class='notice'>[src] expands!</span>")
	new /mob/living/carbon/monkey(get_turf(src))
	qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/enchiladas
	name = "enchiladas"
	desc = "Viva La Mexico!"
	icon_state = "enchiladas"
	bonus_reagents = list("nutriment" = 1, "vitamin" = 2)
	bitesize = 4
	filling_color = "#FFA07A"
	list_reagents = list("nutriment" = 8, "capsaicin" = 6)

/obj/item/weapon/reagent_containers/food/snacks/stewedsoymeat
	name = "stewed soy meat"
	desc = "Even non-vegetarians will LOVE this!"
	icon_state = "stewedsoymeat"
	trash = /obj/item/trash/plate
	bonus_reagents = list("nutriment" = 1)
	list_reagents = list("nutriment" = 8)
	filling_color = "#D2691E"

/obj/item/weapon/reagent_containers/food/snacks/stewedsoymeat/New()
	..()
	eatverb = pick("slurp","sip","suck","inhale","drink")

/obj/item/weapon/reagent_containers/food/snacks/boiledspiderleg
	name = "boiled spider leg"
	desc = "A giant spider's leg that's still twitching after being cooked. Gross!"
	icon_state = "spiderlegcooked"
	trash = /obj/item/trash/plate
	bonus_reagents = list("nutriment" = 1, "capsaicin" = 2, "vitamin" = 2)
	list_reagents = list("nutriment" = 3, "capsaicin" = 2)
	filling_color = "#000000"

/obj/item/weapon/reagent_containers/food/snacks/spidereggsham
	name = "green eggs and ham"
	desc = "Would you eat them on a train? Would you eat them on a plane? Would you eat them on a state of the art corporate deathtrap floating through space?"
	icon_state = "spidereggsham"
	trash = /obj/item/trash/plate
	bonus_reagents = list("nutriment" = 1, "vitamin" = 3)
	list_reagents = list("nutriment" = 6)
	bitesize = 4
	filling_color = "#7FFF00"

/obj/item/weapon/reagent_containers/food/snacks/sashimi
	name = "carp sashimi"
	desc = "Celebrate surviving attack from hostile alien lifeforms by hospitalising yourself."
	icon_state = "sashimi"
	bonus_reagents = list("nutriment" = 1, "capsaicin" = 4, "vitamin" = 4)
	list_reagents = list("nutriment" = 6, "capsaicin" = 5)
	filling_color = "#FA8072"

#define LUMP "lump"
#define STAR "star"
#define LIZARD "lizard"
#define CORGI "corgi"

/obj/item/weapon/reagent_containers/food/snacks/nugget
    name = "chicken nugget"
    filling_color = "#B22222"
    bonus_reagents = list("nutriment" = 1, "vitamin" = 1)
    list_reagents = list("nutriment" = 2)

/obj/item/weapon/reagent_containers/food/snacks/nugget/New()
    ..()
    var/shape = pick(LUMP, STAR, LIZARD, CORGI)
    desc = "A 'chicken' nugget vaguely shaped like a [shape]."
    icon_state = "nugget_[shape]"

#undef LUMP
#undef STAR
#undef LIZARD
#undef CORGI