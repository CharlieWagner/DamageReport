@tool
extends Node3D

enum NoiseType {NEUTRAL, POSITIVE, NEGATIVE}
@export var type: NoiseType = NoiseType.NEUTRAL
@export var strength: float = 1
@export var HitSound: ClipBundle

@export_category("Debug")
@export var mybutton: bool:
	set(_value):
		UpdateShader()

var playerInside: bool = false
var playerBody: Node3D

func _ready():
	#UpdateShader()
	pass

func _process(_delta):
	if playerInside:
		pushPlayerAway()

func UpdateShader():
	var color
	match type:
		NoiseType.NEUTRAL:
			color = Vector3(0,1,0)
		NoiseType.POSITIVE:
			color = Vector3(1,0,0)
		NoiseType.NEGATIVE:
			color = Vector3(0,0,1)
	$Visual.set_instance_shader_parameter("Color", color)
	$Visual.set_instance_shader_parameter("Str", strength)


func _on_body_entered(body):
	if "PushAway" in body:
		playerBody = body
		playerInside = true
		HitSound.playRandom($HitSound as AudioStreamPlayer3D)

func _on_body_exited(body):
	if "PushAway" in body:
		playerInside = false

func pushPlayerAway():
	var dir: Vector3 = position - playerBody.position
	playerBody.PushAway(-dir.normalized())
