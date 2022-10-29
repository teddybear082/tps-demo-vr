extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
#var apiKey = null

# Called when the node enters the scene tree for the first time.
func _ready():
	
#	var f = File.new()
#	f.open("res://swAPIKey.env", File.READ)
#	self.apiKey = f.get_line()
#	f.close()
#	SilentWolf.configure({"api_key": self.apiKey, "game_id": "thriveplatformervr", "game_version": "1.1.0","log_level": 1})
	yield(get_tree().create_timer(4), "timeout")
	$Voiceover.play()
	yield(get_tree().create_timer(4), "timeout")
