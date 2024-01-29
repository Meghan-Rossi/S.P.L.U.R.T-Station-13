/mob/living/carbon/human/examine(mob/user)
//this is very slightly better than it was because you can use it more places. still can't do \his[src] though.
	var/t_He = p_they(TRUE)
	var/t_His = p_their(TRUE)
	var/t_his = p_their()
	var/t_him = p_them()
	var/t_has = p_have()
	var/t_is = p_are()
	var/obscure_name

	if(isliving(user))
		var/mob/living/L = user
		if(HAS_TRAIT(L, TRAIT_PROSOPAGNOSIA))
			obscure_name = TRUE

	. = list("<span class='info'>This is <EM>[!obscure_name ? name : "Unknown"]</EM>!")

	var/vampDesc = ReturnVampExamine(user) // Vamps recognize the names of other vamps.
	var/vassDesc = ReturnVassalExamine(user) // Vassals recognize each other's marks.
	if (vampDesc != "") // If we don't do it this way, we add a blank space to the string...something to do with this -->  . += ""
		. += vampDesc
	if (vassDesc != "")
		. += vassDesc

	var/list/obscured = check_obscured_slots()
	var/skipface = (wear_mask && (wear_mask.flags_inv & HIDEFACE)) || (head && (head.flags_inv & HIDEFACE))

	if(skipface || get_visible_name() == "Unknown")
		. += "You can't make out what species they are."
	else
		. += "[t_He] [t_is] a [spec_trait_examine_font()][dna.custom_species ? dna.custom_species : dna.species.name]</font>!"

	//Underwear
	var/shirt_hidden = undershirt_hidden()
	var/undies_hidden = underwear_hidden()
	var/socks_hidden = socks_hidden()
	if(w_underwear && !undies_hidden)
		. += "[t_He] [t_is] wearing [w_underwear.get_examine_string(user)]."
	if(w_socks && !socks_hidden)
		. += "[t_He] [t_is] wearing [w_socks.get_examine_string(user)]."
	if(w_shirt && !shirt_hidden)
		. += "[t_He] [t_is] wearing [w_shirt.get_examine_string(user)]."
	//Wrist slot because you're epic
	if(wrists && !(ITEM_SLOT_WRISTS in obscured))
		. += "[t_He] [t_is] wearing [wrists.get_examine_string(user)]."
	//End of skyrat changes

	//uniform
	if(w_uniform && !(ITEM_SLOT_ICLOTHING in obscured))
		//accessory
		var/accessory_msg
		if(istype(w_uniform, /obj/item/clothing/under))
			var/obj/item/clothing/under/U = w_uniform
			if(length(U.attached_accessories) && !(U.flags_inv & HIDEACCESSORY))
				var/list/weehoo = list()
				var/dumb_icons = ""
				for(var/obj/item/clothing/accessory/attached_accessory in U.attached_accessories)
					if(!(attached_accessory.flags_inv & HIDEACCESSORY))
						weehoo += "\a [attached_accessory]"
						dumb_icons = "[dumb_icons][icon2html(attached_accessory, user)]"
				if(length(weehoo))
					accessory_msg += " with [dumb_icons]"
					if(length(U.attached_accessories) >= 2)
						accessory_msg += jointext(weehoo, ", ", 1, length(weehoo) - 1)
						accessory_msg += " and [weehoo[length(weehoo)]]"
					else
						accessory_msg += weehoo[1]


		. += "[t_He] [t_is] wearing [w_uniform.get_examine_string(user)][accessory_msg]."
	//head
	if(head && !(head.obj_flags & EXAMINE_SKIP))
		. += "[t_He] [t_is] wearing [head.get_examine_string(user)] on [t_his] head."
	//suit/armor
	if(wear_suit && !(wear_suit.obj_flags & EXAMINE_SKIP))
		. += "[t_He] [t_is] wearing [wear_suit.get_examine_string(user)]."
		//suit/armor storage
		if(s_store && !(ITEM_SLOT_SUITSTORE in obscured))
			. += "[t_He] [t_is] carrying [s_store.get_examine_string(user)] on [t_his] [wear_suit.name]."
	//back
	if(back)
		. += "[t_He] [t_has] [back.get_examine_string(user)] on [t_his] back."

	//Hands
	for(var/obj/item/I in held_items)
		if(!(I.item_flags & ABSTRACT))
			. += "[t_He] [t_is] holding [I.get_examine_string(user)] in [t_his] [get_held_index_name(get_held_index_of_item(I))]."

	//gloves
	if(gloves && !(ITEM_SLOT_GLOVES in obscured))
		. += "[t_He] [t_has] [gloves.get_examine_string(user)] on [t_his] hands."
	else if(length(blood_DNA))
		var/hand_number = get_num_arms(FALSE)
		if(hand_number)
			. += "<span class='warning'>[t_He] [t_has] [hand_number > 1 ? "" : "a"] blood-stained hand[hand_number > 1 ? "s" : ""]!</span>"

	//handcuffed?
	if(handcuffed)
		if(istype(handcuffed, /obj/item/restraints/handcuffs/cable))
			. += "<span class='warning'>[t_He] [t_is] [icon2html(handcuffed, user)] restrained with cable!</span>"
		else
			. += "<span class='warning'>[t_He] [t_is] [icon2html(handcuffed, user)] handcuffed!</span>"

	//belt
	if(belt)
		. += "[t_He] [t_has] [belt.get_examine_string(user)] about [t_his] waist."

	//shoes
	if(shoes && !(ITEM_SLOT_FEET in obscured))
		. += "[t_He] [t_is] wearing [shoes.get_examine_string(user)] on [t_his] feet."

	//mask
	if(wear_mask && !(ITEM_SLOT_MASK in obscured))
		. += "[t_He] [t_has] [wear_mask.get_examine_string(user)] on [t_his] face."

	if(wear_neck && !(ITEM_SLOT_NECK in obscured))
		. += "[t_He] [t_is] wearing [wear_neck.get_examine_string(user)] around [t_his] neck."

	//eyes
	if(!(ITEM_SLOT_EYES in obscured))
		if(glasses)
			. += "[t_He] [t_has] [glasses.get_examine_string(user)] covering [t_his] eyes."
		else if((left_eye_color == BLOODCULT_EYE || right_eye_color == BLOODCULT_EYE) && iscultist(src) && HAS_TRAIT(src, TRAIT_CULT_EYES))
			. += "<span class='warning'><B>[t_His] eyes are glowing an unnatural red!</B></span>"
		else if(HAS_TRAIT(src, TRAIT_HIJACKER))
			var/obj/item/implant/hijack/H = user.getImplant(/obj/item/implant/hijack)
			if (H && !H.stealthmode && H.toggled)
				. += "<b><font color=orange>[t_His] eyes are flickering a bright yellow!</font></b>"

	//ears
	if(ears && !(ITEM_SLOT_EARS_LEFT in obscured)) // Sandstorm edit
		. += "[t_He] [t_has] [ears.get_examine_string(user)] on [t_his] left ear."

	// Sandstorm edit
	if(ears_extra && !(ITEM_SLOT_EARS_RIGHT in obscured))
		. += "[t_He] [t_has] [ears_extra.get_examine_string(user)] on [t_his] right ear."

	//wearing two ear items makes you look like an idiot
	if((istype(ears, /obj/item/radio/headset) && !(ITEM_SLOT_EARS_LEFT in obscured)) && (istype(ears_extra, /obj/item/radio/headset) && !(ITEM_SLOT_EARS_RIGHT in obscured)))
		. += "<span class='warning'>[t_He] looks quite tacky wearing both \an [ears.name] and \an [ears_extra.name] on [t_his] head.</span>"

	//

	//ID
	if(wear_id)
		. += "[t_He] [t_is] wearing [wear_id.get_examine_string(user)]."

	//Status effects
	var/effects_exam = status_effect_examines()
	if(!isnull(effects_exam))
		. += effects_exam

	//Approximate character height based on current sprite scale
	var/dispSize = round(12*get_size(src)) // gets the character's sprite size percent and converts it to the nearest half foot
	if(dispSize % 2) // returns 1 or 0. 1 meaning the height is not exact and the code below will execute, 0 meaning the height is exact and the else will trigger.
		dispSize = dispSize - 1 //makes it even
		dispSize = dispSize / 2 //rounds it out
		. += "[t_He] appears to be around [dispSize] and a half feet tall."
	else
		dispSize = dispSize / 2
		. += "[t_He] appears to be around [dispSize] feet tall."

	//CIT CHANGES START HERE - adds genital details to examine text
	if(LAZYLEN(internal_organs) && (user.client?.prefs.cit_toggles & GENITAL_EXAMINE))
		for(var/obj/item/organ/genital/dicc in internal_organs)
			if(istype(dicc) && dicc.is_exposed())
				. += "[dicc.desc]"
				if((src == user || HAS_TRAIT(user, TRAIT_GFLUID_DETECT)) && ((dicc?.genital_flags & GENITAL_FUID_PRODUCTION) || ((dicc?.linked_organ?.genital_flags & GENITAL_FUID_PRODUCTION) && !dicc?.linked_organ?.is_exposed())))
					var/datum/reagent/cummies = find_reagent_object_from_type(dicc?.get_fluid_id())
					. += "You smell <span style='color:[cummies.color]';>[cummies.name]</span> brewing inside..."
	if(user.client?.prefs.cit_toggles & VORE_EXAMINE)
		var/cursed_stuff = attempt_vr(src,"examine_bellies",args) //vore Code
		if(cursed_stuff)
			. += cursed_stuff
//END OF CIT CHANGES

	//Jitters
	switch(jitteriness)
		if(300 to INFINITY)
			. += "<span class='warning'><B>[t_He] [t_is] convulsing violently!</B></span>"
		if(200 to 300)
			. += "<span class='warning'>[t_He] [t_is] extremely jittery.</span>"
		if(100 to 200)
			. += "<span class='warning'>[t_He] [t_is] twitching ever so slightly.</span>"

	var/appears_dead = 0
	if(stat == DEAD || (HAS_TRAIT(src, TRAIT_FAKEDEATH)))
		appears_dead = 1
		if(suiciding)
			. += "<span class='warning'>[t_He] appear[p_s()] to have committed suicide... there is no hope of recovery.</span>"
		if(hellbound)
			. += "<span class='warning'>[t_His] soul seems to have been ripped out of [t_his] body.  Revival is impossible.</span>"
		if(getorgan(/obj/item/organ/brain) && !key && !get_ghost(FALSE, TRUE))
			. += "<span class='deadsay'>[t_He] [t_is] limp and unresponsive; there are no signs of life and [t_his] soul has departed...</span>"
		else
			. += "<span class='deadsay'>[t_He] [t_is] limp and unresponsive; there are no signs of life...</span>"

	if(get_bodypart(BODY_ZONE_HEAD) && !getorgan(/obj/item/organ/brain))
		. += "<span class='deadsay'>It appears that [t_his] brain is missing...</span>"

	var/temp = getBruteLoss() //no need to calculate each of these twice

	var/list/msg = list()

	if(client && client.prefs) // Skyrat Change
		if(client.prefs.toggles & VERB_CONSENT) // Skyrat Change
			. += "[t_His] player has allowed lewd verbs." // Skyrat Change
		else // Skyrat Change
			. += "[t_His] player has not allowed lewd verbs." // Skyrat Change
		
	//SPLURT edit
	for(var/obj/item/organ/genital/G in internal_organs)
		if(istype(G) && G.is_exposed())
			if(CHECK_BITFIELD(G.genital_flags, GENITAL_CHASTENED))
				. += "[t_He] [t_has] \a chastity cage covering [t_his] [G.name]."
	//
	var/list/missing = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	var/list/disabled = list()
	var/list/writing = list()
	for(var/X in bodyparts)
		var/obj/item/bodypart/BP = X
		if(BP.disabled)
			disabled += BP
		if(BP.writtentext)
			writing += BP
		missing -= BP.body_zone
		for(var/obj/item/I in BP.embedded_objects)
			if(I.isEmbedHarmless())
				msg += "<B>[t_He] [t_has] \a [icon2html(I, user)] [I] stuck to [t_his] [BP.name]!</B>\n"
			else
				msg += "<B>[t_He] [t_has] \a [icon2html(I, user)] [I] embedded in [t_his] [BP.name]!</B>\n"
		for(var/i in BP.wounds)
			var/datum/wound/iter_wound = i
			msg += "[iter_wound.get_examine_description(user)]\n"

	for(var/X in disabled)
		var/obj/item/bodypart/BP = X
		var/damage_text
		if(BP.is_disabled() != BODYPART_DISABLED_WOUND) // skip if it's disabled by a wound (cuz we'll be able to see the bone sticking out!)
			if(!(BP.get_damage(include_stamina = FALSE) >= BP.max_damage)) //we don't care if it's stamcritted
				damage_text = "limp and lifeless"
			else
				damage_text = (BP.brute_dam >= BP.burn_dam) ? BP.heavy_brute_msg : BP.heavy_burn_msg
			msg += "<B>[capitalize(t_his)] [BP.name] is [damage_text]!</B>\n"
	//stores missing limbs
	var/l_limbs_missing = 0
	var/r_limbs_missing = 0
	for(var/t in missing)
		if(t==BODY_ZONE_HEAD)
			msg += "<span class='deadsay'><B>[t_His] [parse_zone(t)] is missing!</B></span>\n"
			continue
		if(t == BODY_ZONE_L_ARM || t == BODY_ZONE_L_LEG)
			l_limbs_missing++
		else if(t == BODY_ZONE_R_ARM || t == BODY_ZONE_R_LEG)
			r_limbs_missing++

		msg += "<B>[capitalize(t_his)] [parse_zone(t)] is missing!</B>\n"

	if(l_limbs_missing >= 2 && r_limbs_missing == 0)
		msg += "[t_He] look[p_s()] all right now.\n"
	else if(l_limbs_missing == 0 && r_limbs_missing >= 2)
		msg += "[t_He] really keeps to the left.\n"
	else if(l_limbs_missing >= 2 && r_limbs_missing >= 2)
		msg += "[t_He] [p_do()]n't seem all there.\n"

	if(!(user == src && src.hal_screwyhud == SCREWYHUD_HEALTHY)) //fake healthy
		if(temp)
			if(temp < 25)
				msg += "[t_He] [t_has] minor bruising.\n"
			else if(temp < 50)
				msg += "[t_He] [t_has] <b>moderate</b> bruising!\n"
			else
				msg += "<B>[t_He] [t_has] severe bruising!</B>\n"

		temp = getFireLoss()
		if(temp)
			if(temp < 25)
				msg += "[t_He] [t_has] minor burns.\n"
			else if (temp < 50)
				msg += "[t_He] [t_has] <b>moderate</b> burns!\n"
			else
				msg += "<B>[t_He] [t_has] severe burns!</B>\n"

		temp = getCloneLoss()
		if(temp)
			if(temp < 25)
				msg += "[t_He] [t_has] minor cellular damage.\n"
			else if(temp < 50)
				msg += "[t_He] [t_has] <b>moderate</b> cellular damage!\n"
			else
				msg += "<b>[t_He] [t_has] severe cellular damage!</b>\n"


	if(fire_stacks > 0)
		msg += "[t_He] [t_is] covered in something flammable.\n"
	if(fire_stacks < 0)
		msg += "[t_He] look[p_s()] a little soaked.\n"


	if(pulledby && pulledby.grab_state)
		msg += "[t_He] [t_is] restrained by [pulledby]'s grip.\n"

	if(nutrition < NUTRITION_LEVEL_STARVING - 50)
		msg += "[t_He] [t_is] severely malnourished.\n"
	else if(nutrition >= NUTRITION_LEVEL_FAT)
		if(user.nutrition < NUTRITION_LEVEL_STARVING - 50)
			msg += "[t_He] [t_is] plump and delicious looking - Like a fat little piggy. A tasty piggy.\n"
		else
			msg += "[t_He] [t_is] quite chubby.\n"
	if(thirst < THIRST_LEVEL_PARCHED - 50)
		msg += "[t_He] [t_is] parched.\n"
	switch(disgust)
		if(DISGUST_LEVEL_GROSS to DISGUST_LEVEL_VERYGROSS)
			msg += "[t_He] look[p_s()] a bit grossed out.\n"
		if(DISGUST_LEVEL_VERYGROSS to DISGUST_LEVEL_DISGUSTED)
			msg += "[t_He] look[p_s()] really grossed out.\n"
		if(DISGUST_LEVEL_DISGUSTED to INFINITY)
			msg += "[t_He] look[p_s()] extremely disgusted.\n"

	if(!HAS_TRAIT(src, TRAIT_ROBOTIC_ORGANISM))
		var/apparent_blood_volume = blood_volume
		if(dna.species.use_skintones && skin_tone == "albino")
			apparent_blood_volume -= 150 // enough to knock you down one tier
		switch(apparent_blood_volume)
			if(BLOOD_VOLUME_OKAY to BLOOD_VOLUME_SAFE)
				msg += "[t_He] [t_has] pale skin.\n"
			if(BLOOD_VOLUME_BAD to BLOOD_VOLUME_OKAY)
				msg += "<b>[t_He] look[p_s()] like pale death.</b>\n"
			if(-INFINITY to BLOOD_VOLUME_BAD)
				msg += "<span class='deadsay'><b>[t_He] resemble[p_s()] a crushed, empty juice pouch.</b></span>\n"

	if(bleedsuppress)
		msg += "[t_He] [t_is] embued with a power that defies bleeding.\n" // only statues and highlander sword can cause this so whatever
	else if(is_bleeding())
		var/list/obj/item/bodypart/bleeding_limbs = list()

		for(var/i in bodyparts)
			var/obj/item/bodypart/BP = i
			if(BP.get_bleed_rate())
				bleeding_limbs += BP

		var/num_bleeds = LAZYLEN(bleeding_limbs)
		var/list/bleed_text
		if(appears_dead)
			bleed_text = list("<span class='deadsay'><B>Blood is visible in [t_his] open")
		else
			bleed_text = list("<B>[t_He] [t_is] bleeding from [t_his]")

		switch(num_bleeds)
			if(1 to 2)
				bleed_text += " [bleeding_limbs[1].name][num_bleeds == 2 ? " and [bleeding_limbs[2].name]" : ""]"
			if(3 to INFINITY)
				for(var/i in 1 to (num_bleeds - 1))
					var/obj/item/bodypart/BP = bleeding_limbs[i]
					bleed_text += " [BP.name],"
				bleed_text += " and [bleeding_limbs[num_bleeds].name]"


		if(appears_dead)
			bleed_text += ", but it has pooled and is not flowing.</span></B>\n"
		else
			if(reagents.has_reagent(/datum/reagent/toxin/heparin))
				bleed_text += " incredibly quickly"

			bleed_text += "!</B>\n"
		msg += bleed_text.Join()

	if(reagents.has_reagent(/datum/reagent/teslium))
		msg += "[t_He] [t_is] emitting a gentle blue glow!\n"

	if(islist(stun_absorption))
		for(var/i in stun_absorption)
			if(stun_absorption[i]["end_time"] > world.time && stun_absorption[i]["examine_message"])
				msg += "[t_He] [t_is][stun_absorption[i]["examine_message"]]\n"

	if(drunkenness && !skipface && !appears_dead) //Drunkenness
		switch(drunkenness)
			if(11 to 21)
				msg += "[t_He] [t_is] slightly flushed.\n"
			if(21.01 to 41) //.01s are used in case drunkenness ends up to be a small decimal
				msg += "[t_He] [t_is] flushed.\n"
			if(41.01 to 51)
				msg += "[t_He] [t_is] quite flushed and [t_his] breath smells of alcohol.\n"
			if(51.01 to 61)
				msg += "[t_He] [t_is] very flushed and [t_his] movements jerky, with breath reeking of alcohol.\n"
			if(61.01 to 91)
				msg += "[t_He] look[p_s()] like a drunken mess.\n"
			if(91.01 to INFINITY)
				msg += "[t_He] [t_is] a shitfaced, slobbering wreck.\n"

	if(reagents.has_reagent(/datum/reagent/fermi/astral))
		if(mind)
			msg += "[t_He] has wild, spacey eyes and they have a strange, abnormal look to them.\n"
		else
			msg += "[t_He] has wild, spacey eyes and they don't look like they're all there.\n"

	for(var/X in writing)
		if(!w_uniform)
			var/obj/item/bodypart/BP = X
			msg += "<span class='notice'>[capitalize(t_He)] has \"[html_encode(BP.writtentext)]\" written on [t_his] [BP.name].</span>\n"
	for(var/obj/item/organ/genital/G in internal_organs)
		if(length(G.writtentext) && istype(G) && G.is_exposed())
			msg += "<span class='notice'>[capitalize(t_He)] has \"[html_encode(G.writtentext)]\" written on [t_his] [G.name].</span>\n"

	if(isliving(user))
		var/mob/living/L = user
		if(src != user && HAS_TRAIT(L, TRAIT_EMPATH) && !appears_dead)
			if (a_intent != INTENT_HELP)
				msg += "[t_He] seem[p_s()] to be on guard.\n"
			if (getOxyLoss() >= 10)
				msg += "[t_He] seem[p_s()] winded.\n"
			if (getToxLoss() >= 10)
				msg += "[t_He] seem[p_s()] sickly.\n"
			var/datum/component/mood/mood = GetComponent(/datum/component/mood)
			if(mood.sanity <= SANITY_DISTURBED)
				msg += "[t_He] seem[p_s()] distressed.\n"
				SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "empath", /datum/mood_event/sad_empath, src)
			if(mood.shown_mood >= 6) //So roundstart people aren't all "happy" and that antags don't show their true happiness.
				msg += "[t_He] seem[p_s()] to have had something nice happen to them recently.\n"
				SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "empathH", /datum/mood_event/happy_empath, src)
			if (HAS_TRAIT(src, TRAIT_BLIND))
				msg += "[t_He] appear[p_s()] to be staring off into space.\n"
			if (HAS_TRAIT(src, TRAIT_DEAF))
				msg += "[t_He] appear[p_s()] to not be responding to noises.\n"

	var/obj/item/organ/vocal_cords/Vc = user.getorganslot(ORGAN_SLOT_VOICE)
	if(Vc)
		if(istype(Vc, /obj/item/organ/vocal_cords/velvet))
			if(client?.prefs.cit_toggles & HYPNO)
				msg += "<span class='velvet'><i>You feel your chords resonate looking at them.</i></span>\n"


	if(!appears_dead)
		if(stat == UNCONSCIOUS)
			msg += "[t_He] [t_is]n't responding to anything around [t_him] and seem[p_s()] to be asleep.\n"
		else
			if(HAS_TRAIT(src, TRAIT_DUMB))
				msg += "[t_He] [t_has] a stupid expression on [t_his] face.\n"
			if(InCritical())
				msg += "[t_He] [t_is] barely conscious.\n"
		if(getorgan(/obj/item/organ/brain))
			if(!key)
				msg += "<span class='deadsay'>[t_He] [t_is] totally catatonic. The stresses of life in deep-space must have been too much for [t_him]. Any recovery is unlikely.</span>\n"
			else if(!client)
				msg += "[t_He] [t_has] a blank, absent-minded stare and [t_has] been completely unresponsive to anything for [round(((world.time - lastclienttime) / (1 MINUTES)), 1)] minutes. [t_He] may snap out of it soon.\n" //SKYRAT CHANGE - ssd indicator

		if(digitalcamo)
			msg += "[t_He] [t_is] moving [t_his] body in an unnatural and blatantly inhuman manner.\n"

	var/scar_severity = 0
	for(var/i in all_scars)
		var/datum/scar/S = i
		if(S.is_visible(user))
			scar_severity += S.severity

	switch(scar_severity)
		if(1 to 2)
			msg += "<span class='smallnoticeital'>[t_He] [t_has] visible scarring, you can look again to take a closer look...</span>\n"
		if(3 to 4)
			msg += "<span class='notice'><i>[t_He] [t_has] several bad scars, you can look again to take a closer look...</i></span>\n"
		if(5 to 6)
			msg += "<span class='notice'><b><i>[t_He] [t_has] significantly disfiguring scarring, you can look again to take a closer look...</i></b></span>\n"
		if(7 to INFINITY)
			msg += "<span class='notice'><b><i>[t_He] [t_is] just absolutely fucked up, you can look again to take a closer look...</i></b></span>\n"

	if (length(msg))
		. += "<span class='warning'>[msg.Join("")]</span>"

	var/trait_exam = common_trait_examine()
	if (!isnull(trait_exam))
		. += trait_exam

	var/traitstring = get_trait_string()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/organ/cyberimp/eyes/hud/CIH = H.getorgan(/obj/item/organ/cyberimp/eyes/hud)
		if(istype(H.glasses, /obj/item/clothing/glasses/hud) || CIH)
			var/perpname = get_face_name(get_id_name(""))
			if(perpname)
				var/datum/data/record/R = find_record("name", perpname, GLOB.data_core.general)
				if(R)
					. += "<span class='deptradio'>Rank:</span> [R.fields["rank"]]\n<a href='?src=[REF(src)];hud=1;photo_front=1'>\[Front photo\]</a><a href='?src=[REF(src)];hud=1;photo_side=1'>\[Side photo\]</a>"
				if(istype(H.glasses, /obj/item/clothing/glasses/hud/health) || istype(CIH, /obj/item/organ/cyberimp/eyes/hud/medical))
					var/cyberimp_detect
					for(var/obj/item/organ/cyberimp/CI in internal_organs)
						if(CI.status == ORGAN_ROBOTIC && !CI.syndicate_implant)
							cyberimp_detect += "[name] is modified with a [CI.name]."
					if(cyberimp_detect)
						. += "Detected cybernetic modifications:"
						. += cyberimp_detect
					if(R)
						var/health_r = R.fields["p_stat"]
						. += "<a href='?src=[REF(src)];hud=m;p_stat=1'>\[[health_r]\]</a>"
						health_r = R.fields["m_stat"]
						. += "<a href='?src=[REF(src)];hud=m;m_stat=1'>\[[health_r]\]</a>"
					R = find_record("name", perpname, GLOB.data_core.medical)
					if(R)
						. += "<a href='?src=[REF(src)];hud=m;evaluation=1'>\[Medical evaluation\]</a>"
					if(traitstring)
						. += "<span class='info'>Detected physiological traits:\n[traitstring]</span>"



				if(istype(H.glasses, /obj/item/clothing/glasses/hud/security) || istype(CIH, /obj/item/organ/cyberimp/eyes/hud/security))
					if(!user.stat && user != src)
					//|| !user.canmove || user.restrained()) Fluff: Sechuds have eye-tracking technology and sets 'arrest' to people that the wearer looks and blinks at.
						var/criminal = "None"

						R = find_record("name", perpname, GLOB.data_core.security)
						if(R)
							criminal = R.fields["criminal"]

						. += jointext(list("<span class='deptradio'>Criminal status:</span> <a href='?src=[REF(src)];hud=s;status=1'>\[[criminal]\]</a>",
							"<span class='deptradio'>Security record:</span> <a href='?src=[REF(src)];hud=s;view=1'>\[View\]</a>",
							"<a href='?src=[REF(src)];hud=s;add_crime=1'>\[Add crime\]</a>",
							"<a href='?src=[REF(src)];hud=s;view_comment=1'>\[View comment log\]</a>",
							"<a href='?src=[REF(src)];hud=s;add_comment=1'>\[Add comment\]</a>"), "")
	else if(isobserver(user) && traitstring)
		. += "<span class='info'><b>Traits:</b> [traitstring]</span>"

	if(LAZYLEN(.) > 2) //Want this to appear after species text
		.[2] += "<hr>"

	SEND_SIGNAL(src, COMSIG_PARENT_EXAMINE, user, .) //This also handles flavor texts now

/mob/living/proc/status_effect_examines(pronoun_replacement) //You can include this in any mob's examine() to show the examine texts of status effects!
	var/list/dat = list()
	if(!pronoun_replacement)
		pronoun_replacement = p_they(TRUE)
	for(var/V in status_effects)
		var/datum/status_effect/E = V
		if(E.examine_text)
			var/new_text = replacetext(E.examine_text, "SUBJECTPRONOUN", pronoun_replacement)
			new_text = replacetext(new_text, "[pronoun_replacement] is", "[pronoun_replacement] [p_are()]") //To make sure something become "They are" or "She is", not "They are" and "She are"
			dat += "[new_text]\n" //dat.Join("\n") doesn't work here, for some reason
	if(dat.len)
		return dat.Join()
