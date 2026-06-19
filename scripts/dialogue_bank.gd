extends Node

var chat_templates: Dictionary = {
	"scratch_ingredient": "Wait, no! Don't use {old_item}... let's scratch that out and try {new_item} instead.",
	"scratch_name": "We aren't making a {old_item} anymore. Change the name to a {new_item}!",
	"empty_line_fill": "Perfect, let's add some {new_item} to that blank line.",
	
	
	#Sarah
	"sarah_1_start": "Ah, hello… tsk… \nSo, I'm guessing you're my new coworker, huh? \nGod dang it, why do we even need one? \nUghhhh! \nAnyways, put this on and do ur job! \nAnd don't even think about asking ME for any help!",
	#break -> silence while ... is showing
	"sarah_2_autoplay_after_one": "Why are you just standing there? \nCan't you see the customers waiting? \nCome on, what do you think you are here for?",
	#wait until player clicks on Sarah (she should be the only thing u can click on rn)
	"sarah_3_clicked_on": "Ughhhh,  What do u want? \nI told you not to ask me for help! \nDamn, it's not even that hard! Every kid knows how to make that drink and you are still standing here, clueless? Pathetic!",
	#short break -> silence
	"sarah_4_autoplay_after_3": "You know what? Cause I'm feeling super nice today I'm actually gonna take the customers orders and write down what to mix in each drink. \nYou can follow instructions, right? \nCause then this should be absolutely no problem for you! \nThere we go, she ain't gonna last a day with this genius tactic!",
	#can u leave a bit longer breaks inbetween each line of 4?
	
	# played at the end of the game (right before or after the winning screen)
	"sarah_5_end": "Uhhhh, so you are pretty good at this, huh? \nDammet, guess I'm gonna have to get used to having you around! \nHoooray, finally boss found someone to “accompany “ me. Huhhhhh \n… \n. . .",
	#make sure that there´s silence when ... is showing
	"sarah_6_end": "Well, at least it doesn't seem like you're the worst person on this planet. \nMight as well cope with, huh?",
	
	
	# Seal
	"seal_hello": "Heyaaa!",
	"seal_my_drink?": "Uhmm, is that my drink?",
	"seal_wrong_ingredient": "Cause idk, \nI'm pretty sure you don't normally put {ingredient} in there…",
	"seal_right_ingredient": "Cause I think you might've forgotten the {ingredient}",
	"seal_thx_1": "Yeh, thanks for the drink!",
	"seal_thx_2": "Thanks for the dr..., hmm, this is good! \nKeep up tha good work!",
	"seal_thx_3": "Thank you fo..., oh, this..., \nit's too good, it's perfect! \nYa gotta make me such good drinks all the time!",
	"seal_thx_bad": "Welp, it's not that good, but don't you worry, \nyou'll get there soon enough!",
	
	# Fish
	"fish_hello": "Hi.",
	"fish_my_drink?": "Mine?",
	"fish_wrong_ingredient": "No {ingredient}!",
	"fish_right_ingredient": "{ingredient}!",
	"fish_thx_1": "Thank…",
	"fish_thx_2": "Thank you…",
	"fish_thx_3": "Thanks, this the best is!",
	"fish_thx_bad": "Eh…",
	
	# Shark
	"shark_hello": "Hello there newbie!",
	"shark_my_drink?": "Soooo, who's this drink for?",
	"shark_wrong_ingredient": "Cause last time I checked I was the only one in here \nand the {ingredient} you just put in there does not go into the drink I ordered!",
	"shark_right_ingredient": "Well, if I would make this drink myself, \nI would definitely use some {ingredient}",
	"shark_thx_1": "Oh, yeah, I mean, you could've tried harder!",
	"shark_thx_2": "Uh, yes, this is fine I guess, \nbut let me just mix it myself next time!",
	"shark_thx_3": "Wait, what?\n This is ALMOST as good as when I do it! Almost!",
	"shark_thx_bad": "Ew, what is this? I'm not drinking this!",
	
	# Axolotl
	"axolotl_hello": "Greetings!",
	"axolotl_my_drink?": "I assume you are making my drink,\n as I just ordered.",
	"axolotl_wrong_ingredient": "So, I don't want to be mean at all, \nbut you know that mixing {ingredient} in there leaves you with a weird taste, right?",
	"axolotl_right_ingredient": "Ummm, actually the drink I ordered has {ingredient} in it, \nso could you please make sure you don't forget that?",
	"axolotl_thx_1": "Ah, thanks for the drink... I see you are missing two ingredients, but that´s no problem",
	"axolotl_thx_2": "Oh, so, this is my drink? It's good, you forgot one ingredient, but I still kinda like it!",
	"axolotl_thx_3": "Is this what I ordered? This… is… AMAZING! I didn't even know that this drink can taste this good! Thank you so much!",
	"axolotl_thx_bad": "Errr, are you sure this is what I ordered? I don't think there's any right ingredient in this! This is unacceptable!"
	}


func _build_customer_key(persona: String, event_name: String) -> String:
	return "%s_%s" % [persona, event_name]


func get_customer_line(persona: String, event_name: String, params: Dictionary = {}) -> String:
	var key: String = _build_customer_key(persona, event_name)
	var text: String = chat_templates.get(key, "")
	if text.is_empty() and event_name == "thx_failed":
		text = chat_templates.get(_build_customer_key(persona, "thx_bad"), "")
	if text.is_empty():
		return ""

	for param_key in params.keys():
		var placeholder: String = "{%s}" % [str(param_key)]
		var value: String = str(params[param_key])
		if param_key == "ingredient":
			value = IngredientNames.get_display_name(value)
		text = text.replace(placeholder, value)

	return text


func has_customer_line(persona: String, event_name: String) -> bool:
	return chat_templates.has(_build_customer_key(persona, event_name))
