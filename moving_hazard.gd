extends AnimatableBody3D


@export var destination: Vector3
@export_range(0.5, 5.0) var duration: float = 1.0
@export var size = Vector3(3.0, 3.0, 3.0)


func _ready() -> void:
	move()


func move() -> void:
	var tween = create_tween()
	tween.set_loops()
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "global_position", global_position + destination, duration)
	tween.tween_property(self, "global_position", global_position, duration)
