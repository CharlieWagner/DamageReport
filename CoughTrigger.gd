extends Area3D

@export var count: int = 1
var currCount: int = 0
@export var delayMin: float = 1.0
@export var delayMax: float = 1.0
var playerRef: player_controller

@export var HurtTarget: float = -1

var hasTriggered: bool = false

func _on_body_entered(body):
	if body is player_controller && !hasTriggered:
		playerRef = body
		hasTriggered = true
		if HurtTarget != -1:
			playerRef.hurtBlendTarget = HurtTarget
		onCough()

func onCough():
	playerRef.DoCough()
	if currCount < count || count == -1:
		$Timer.wait_time = randf_range(delayMin, delayMax)
		currCount += 1
		$Timer.start()

func _on_timer_timeout():
	onCough()
