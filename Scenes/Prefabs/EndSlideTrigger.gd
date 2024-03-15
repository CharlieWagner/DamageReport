extends Area3D
class_name EndSlideTrigger

@export var slideToEnd: Slide
@export var isEndPickup: bool:
	set(value):
		if value: 
			$MeshInstance3D.show()
		else:
			$MeshInstance3D.hide()
		isEndPickup = value

@export var delay: float = -1
signal onTrigger()

func _ready():
	if isEndPickup:
		Globals.currObjective = position
		$MeshInstance3D.show()

func _on_body_entered(body):
	if body is player_controller:
		onTrigger.emit()
		if delay == -1:
			completeSlide()
		else:
			$Timer.wait_time = delay
			$Timer.start()

func completeSlide():
	Globals.RespawnPos = Globals.PlayerPos
	Globals.completeSpecific(slideToEnd)


func _on_timer_timeout():
	completeSlide()
