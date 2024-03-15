extends Node3D

@export var sens_Hor: float = .1
@export var sens_Ver: float = .1

@onready var yawTransform = $"."
@onready var pitchTransform = $Node3D
@onready var camera = $Node3D/Camera3D
@onready var distanceCheck = $Node3D/RayCast3D
var camDir: Vector3 = Vector3.ZERO
var basePosition: Vector3

var isAim: bool = false

var camXrot = 0.0
var camYrot = 0.0

func _ready():
	pass

func _process(_delta):
	CameraUpdate(_delta)

func CameraControl(xInput, yInput):
	camXrot += deg_to_rad(-xInput * sens_Hor)
	camYrot += deg_to_rad(-yInput * sens_Ver)
	camYrot = clamp(camYrot, -.9, .9)

func CameraMovement(pos: Vector3):
	position = lerp(position, pos, get_process_delta_time() * (20 if isAim else 5))

func CameraUpdate(_delta):
	yawTransform.rotation.y = lerp(yawTransform.rotation.y, camXrot, _delta * 10)
	pitchTransform.rotation.x = lerp(pitchTransform.rotation.x, camYrot, _delta * 10)
	distanceCheck.target_position = camDir
	
	if distanceCheck.is_colliding():
		var camDist = (distanceCheck.global_position - distanceCheck.get_collision_point()).length()
		camera.position = camDir.normalized() * camDist
	else:
		camera.position = camDir

func SetAiming(aim: bool = false):
	isAim = aim
	var target = Vector3(.2,0.2,.7) if aim else Vector3(.3,0,2.35)
	camDir = lerp(camDir, target, get_process_delta_time() * 2)
