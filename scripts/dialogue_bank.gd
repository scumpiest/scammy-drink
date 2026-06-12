extends Node

var chat_templates: Dictionary = {
	"scratch_ingredient": "Wait, no! Don't use {old_item}... let's scratch that out and try {new_item} instead.",
	"scratch_name": "We aren't making a {old_item} anymore. Change the name to a {new_item}!",
	"empty_line_fill": "Perfect, let's add some {new_item} to that blank line.",
	
	"bitchy_or_chill_my_drink?": "Heya, uhmm, is that MY drink?",
	"bitchy_or_chill_wrong_ingredient": "Cause idk, I’m pretty sure you don’t normally put {old_item} in there…",
	"bitchy_or_chill_no_ice": "Cause I actually don’t like my drink Ice cold, you know?",
	"bitchy_or_chill_right_ingredient": "Just saying, but in the other bars they usually put some {new_item} in there!",
	
	"shy_my_drink?": "Oh, are you… working on my drink?",
	"shy_wrong_ingredient": "You know, I don’t know much about drinks but I don’t think it tasted like {old_item} last time I had one…",
	"shy_no_ice": "I just wanted to mention that I would prefer my drink to be just an average temperature… So, no need to put any Ice in there…",
	"shy_right_ingredient": "I don´t know how to say this, but I think I remember this drink having some {new_item} mixed in, but I´m sure it´s gonna taste great no matter what.",
	
	"confident_my_drink?": "Hey, soooo, who’s this drink for?",
	"confident_wrong_ingredient": "Cause last time I checked I was the only one in here and the {old_item} you just put in there does not go into the drink I ordered!",
	"confident_no_ice": "Because I just saw you put some Ice in there even though I especially ordered a drink without Ice!",
	"confident_right_drink": "yeah, I don´t think you put {new item} in there yet, so you either do it now or this bar is gonna get a 1-Star rating!",
	
	"nerd_my_drink?": "Excuse me!",
	"nerd_wrong_ingredient": "So, I don’t want to be mean at all, but u know that mixing {old_item} in there leaves you with a weird taste, right?",
	"nerd_no_ice": "Erm, actually I ordered a drink at room temperature, so no extra Ice!}",
	"nerd_no_ice": "I´m certain that you did not utilize {new_item} yet, even though it clearly belongs into the drink I ordered!"
	}
