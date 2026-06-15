extends Node

var chat_templates: Dictionary = {
	"scratch_ingredient": "Wait, no! Don't use {old_item}... let's scratch that out and try {new_item} instead.",
	"scratch_name": "We aren't making a {old_item} anymore. Change the name to a {new_item}!",
	"empty_line_fill": "Perfect, let's add some {new_item} to that blank line.",
	
	"seal_hello": "Heyaaa!",
	"seal_my_drink?": "Uhmm, is that MY drink?",
	"seal_wrong_ingredient": "Cause idk, I’m pretty sure you don’t normally put {old_item} in there…",
	"seal_right_ingredient": "Cause I think you might´ve forgotten the {old_item}",
	"seal_thx_1": "Yeh, thanks for the drink!",
	"seal_thx_2": "Thanks for the dr..., hmm, this is good! Keep up tha good work!",
	"seal_thx_3": "Thank you fo..., oh, this..., it´s too good, it´s perfect! Ya gotta make me such good drinks all the time!",
	"seal_thx_failed": "Welp, it´s not that good, but don´t you worry, you´ll get there soon enough!",
	
	"confident_my_drink?": "Hey, soooo, who’s this drink for?",
	"confident_wrong_ingredient": "Cause last time I checked I was the only one in here and the {old_item} you just put in there does not go into the drink I ordered!",
	"confident_no_ice": "Because I just saw you put some Ice in there even though I especially ordered a drink without Ice!",
	"confident_right_drink": "yeah, I don´t think you put {new_item} in there yet, so you either do it now or this bar is gonna get a 1-Star rating!",
	
	"nerd_my_drink?": "Excuse me!",
	"nerd_wrong_ingredient": "So, I don’t want to be mean at all, but u know that mixing {old_item} in there leaves you with a weird taste, right?",
	"nerd_no_ice": "Erm, actually I ordered a drink at room temperature, so no extra Ice!}",
	"nerd_right_ingredient": "I´m certain that you did not utilize {new_item} yet, even though it clearly belongs into the drink I ordered!"
	}
