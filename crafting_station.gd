extends Control

func _on_water_button_pressed():
	GameManager.update_inventory("water", 1)

func _on_orange_button_pressed():
	GameManager.update_inventory("orange", 1)

func _on_milk_button_pressed():
	GameManager.update_inventory("milk", 1)

func _on_mango_button_pressed():
	GameManager.update_inventory("mango", 1)

func _on_ice_button_pressed():
	GameManager.update_inventory("ice", 1)
