extends RigidBody3D


@export_range(750.0, 3000.0) 	var thrust: float = 1000.0
@export_range(50.0, 250.0) 		var torque: float = 100.0


@onready var explosion_audio: AudioStreamPlayer3D = %ExplosionAudio
@onready var success_audio: AudioStreamPlayer3D = %SuccessAudio
@onready var thruster_audio: AudioStreamPlayer3D = %ThrusterAudio

@onready var booster_particles: GPUParticles3D = %BoosterParticles
@onready var right_booster_particles: GPUParticles3D = %RightBoosterParticles
@onready var left_booster_particles: GPUParticles3D = %LeftBoosterParticles

@onready var explosion_particles: GPUParticles3D = %ExplosionParticles
@onready var success_particles: GPUParticles3D = %SuccessParticles


var is_shutdown = false


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"): get_tree().quit()
	
	if Input.is_action_pressed("rotate_left"): 
		apply_torque(Vector3(0.0, 0.0, delta * torque))
		toggle_thrust(right_booster_particles, true)
	else: toggle_thrust(right_booster_particles, false)
	
	if Input.is_action_pressed("rotate_right"): 
		apply_torque(Vector3(0.0, 0.0, -delta * torque))
		toggle_thrust(left_booster_particles, true)
	else: toggle_thrust(left_booster_particles, false)
	
	if Input.is_action_pressed("boost"): 
		apply_central_force(basis.y * delta * thrust)
		toggle_thrust(booster_particles, true)
	else: toggle_thrust(booster_particles, false)


func toggle_thrust(booster: GPUParticles3D, state: bool) -> void:
	if state:
		if not thruster_audio.playing: thruster_audio.play()
		if not booster.emitting: booster.emitting = true
	else:
		if booster.emitting: booster.emitting = false
		if thruster_audio.playing and not [
			booster_particles,
			right_booster_particles,
			left_booster_particles,
		].any(func (booster: GPUParticles3D): return booster.emitting): thruster_audio.stop()

func stop_fx() -> void:
	if thruster_audio.is_playing: thruster_audio.stop()
	if booster_particles.emitting: booster_particles.emitting = false
	if right_booster_particles.emitting: right_booster_particles.emitting = false
	if left_booster_particles.emitting: left_booster_particles.emitting = false

func completion_sequence() -> void:
	is_shutdown = true
	stop_fx()
	set_process(false)

func crash() -> void:
	completion_sequence()
	explosion_particles.emitting = true
	explosion_audio.play()
	explosion_audio.finished.connect(get_tree().reload_current_scene)

func success(next_level_file: String) -> void:
	completion_sequence()
	success_particles.emitting = true
	success_audio.play()
	success_audio.finished.connect(get_tree().change_scene_to_file.bind(next_level_file))


func _on_body_entered(body: Node) -> void:
	if (is_shutdown): return
	
	var groups = body.get_groups()
	
	if "goal_surface" in groups: success(body.next_level_file)
	elif "safe_surface" not in groups: crash()
