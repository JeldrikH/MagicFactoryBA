extends AnimationPlayer

func _ready() -> void:
	create_idle_animation()
	
func create_idle_animation():
	
	var char_anims = AnimationLibrary.new()
	var idle = Animation.new()
	idle.length = 6
	var parent = $".."
	
	var scale_track_id = idle.add_track(Animation.TYPE_VALUE)
	idle.track_set_path(scale_track_id, "%s:scale" % $"..")
	
	idle.track_insert_key(scale_track_id, 0, parent.scale)
	idle.track_insert_key(scale_track_id, 2, Vector2(parent.scale.x, parent.scale.y * 1.01))
	idle.track_insert_key(scale_track_id, 4, parent.scale)
	
	char_anims.add_animation("Idle", idle)
	add_animation_library("CharacterAnimations", char_anims)
	
