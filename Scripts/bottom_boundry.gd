extends Area2D


func _on_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("enemy"):
		get_parent().get_parent().game_over()
