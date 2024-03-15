extends Node3D

@export var slideTrigger: Node3D
@export var slideToEnd: Slide

func _ready():
	slideTrigger.connect("onTrigger", StartLaserSeq)

func StartLaserSeq():
	$LaserMesh.show()
	$AnimationPlayer.play("AimThenFire")

func endSeq():
	Globals.completeSpecific(slideToEnd)
	print("FINISH")
