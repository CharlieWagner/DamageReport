extends CharacterBody3D
class_name player_controller

@export var cc: Node3D
@onready var playerMesh = $Character
@onready var playerAnim = $Character/AnimationTree
@onready var scannerCamera = $RenderViewport/Camera3D

var stepStr: float = 0.0

@export var speed = 2

var mouselook: Vector2 = Vector2(0,0)

var isAiming: bool = false
var isAimingf: float = 0.0
var isPushedf: float = 0.0

var fallBlend: float = 0.0

var health: float = 1
var ringBlend: float = 0
var ringBlendTarget: float = 0

@export var CoughSounds: ClipBundle
var hurtBlendTarget: float = 0.0

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Globals.connect("doRespawn",Teleport)
	RenderingServer.global_shader_parameter_set("playerHealth", 1)

func _process(_delta):
	if Globals.currSlide.isGameplay:
		isAiming = Input.is_action_pressed("Aim")
		UpdateHealth()
		AnimUpdate()
		CameraControl()
		RotateCharToCamera()
		UpdateScanner()
		if (position.y < -50):
			Globals.KillPlayer()
		
		ringBlendTarget = max(ringBlendTarget - _delta * .2, 0)
		ringBlend = lerp(ringBlend,ringBlendTarget, _delta * 5)
		$RingAudioSource.volume_db = linear_to_db(ringBlend * .5)
		
	else :
		AnimSafeReset()
	if Input.is_action_just_pressed("Esc"): Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if Input.is_action_just_pressed("Next"): Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	Globals.PlayerPos = position

func _physics_process(_delta):
	if Globals.currSlide.isGameplay:
		MoveByInput(GetMovementVector())
		velocity.y += -9.8 * _delta
		move_and_slide()

func _input(event):
	# grab mouse input
	if event is InputEventMouseMotion :
		mouselook = Vector2(event.relative.x, event.relative.y)

func CameraControl():
	if "CameraControl" in cc:
		var xAxis = (Input.get_axis("cam_left","cam_right") * 2000 * get_process_delta_time())
		xAxis += (mouselook.x * 2)
		var yAxis = (Input.get_axis("cam_up","cam_down") * 2000 * get_process_delta_time())
		yAxis += (mouselook.y * 2)
		cc.CameraControl(xAxis, yAxis)
		cc.CameraMovement(position + Vector3.UP * .5)
		cc.SetAiming(isAiming)
	mouselook = Vector2.ZERO

func MoveByInput(direction = Vector3.ZERO, acceleration = 5):
	var velTarget = direction * speed
	velTarget = velocity.move_toward(velTarget, acceleration * get_physics_process_delta_time())
	var velOffset = velTarget - velocity
	velOffset = velOffset - velOffset.project(Vector3.UP)
	velocity += velOffset

func GetMovementVector():
	var input_dir = Input.get_vector("left","right","up","down")
	input_dir = input_dir.normalized() * clamp(input_dir.length(),0,1)
	var input_vector = Vector3(input_dir.x, 0, input_dir.y)
	input_vector = cc.basis * input_vector
	return input_vector

func RotateCharToCamera():
	var rotSpeed = 7 if isAiming else 3
	var yaw = lerp_angle(playerMesh.global_rotation.y, cc.global_rotation.y, get_process_delta_time() * rotSpeed)
	playerMesh.rotation = Vector3(0,yaw,0) * basis
	#playerMesh.rotation = playerMesh.global_rotation.Slerp(cc.rotation.quaternion,get_process_delta_time() * 5)

func AnimUpdate():
	var delta = get_process_delta_time()
	var vel = velocity.length() / speed
	var velX = (playerMesh.basis.x.dot(velocity)) / speed
	var velY = (-playerMesh.basis.z.dot(velocity)) / speed
	var turn = clamp(playerMesh.basis.z.angle_to(cc.basis.z) * sign(playerMesh.basis.z.dot(cc.basis.x)),-1,1)
	var moveBlend = lerp(playerAnim.get("parameters/LocomotionSpeed/scale"), vel, delta * 3)
	playerAnim.set("parameters/IdleMotionBlend/blend_amount",clamp(moveBlend*3.5,0,1))
	playerAnim.set("parameters/LocomotionSpeed/scale",moveBlend)
	playerAnim.set("parameters/LocomotionBase/blend_position", Vector2(velX, velY))
	playerAnim.set("parameters/TurnBlend/blend_amount",turn)
	var aimBlend = lerp(playerAnim.get("parameters/AimActiveBlend/blend_amount"),1.0 if isAiming else 0.0, delta * 3)
	playerAnim.set("parameters/AimActiveBlend/blend_amount",aimBlend)
	var aimHeight = lerp(float(playerAnim.get("parameters/AimStates/AimTree/AimBlend/blend_amount")),float(cc.camYrot), delta * 3)
	playerAnim.set("parameters/AimStates/AimTree/AimBlend/blend_amount",aimHeight)
	playerAnim.set("parameters/AimStates/conditions/startAim",isAiming)
	playerAnim.set("parameters/AimStates/conditions/stopAim",!isAiming)
	stepStr = max(abs(turn),vel)
	isPushedf = max(isPushedf - delta * 3, 0)
	playerAnim.set("parameters/handUpBlend/blend_amount",isPushedf)
	
	var hurtBlend = lerp(playerAnim.get("parameters/TiredBlend/add_amount"), hurtBlendTarget, delta * .5)
	playerAnim.set("parameters/TiredBlend/add_amount",hurtBlend)
	
	fallBlend = lerp(fallBlend, 0.0 if is_on_floor() else 1.0, delta * 5.0)
	playerAnim.set("parameters/FallBlend/blend_amount",fallBlend)

func AnimSafeReset():
	playerAnim.set("parameters/LocomotionBase/blend_position", Vector2(0,0))

func UpdateScanner():
	scannerCamera.position = position
	scannerCamera.rotation = cc.camera.global_rotation
	isAimingf = lerp(isAimingf, 1.0 if isAiming else 0.0, get_process_delta_time() * 10)
	RenderingServer.global_shader_parameter_set("scanning", isAimingf)
	if Globals.CurrSceneIndex < 4:
		var Pan = (Globals.currObjective - position).normalized().dot(cc.basis.x)
		@warning_ignore("incompatible_ternary")
		Pan = 5 if (Globals.currObjective - position).normalized().dot(cc.basis.z) > 0 else Pan
		RenderingServer.global_shader_parameter_set("targetPan", Pan)
		RenderingServer.global_shader_parameter_set("scanning", isAimingf)
	else:
		RenderingServer.global_shader_parameter_set("targetPan", 5)
	
	if isAiming:
		Globals.TargetPos = position
		Globals.NoiseEvent.emit(3 * get_process_delta_time(), position)

func UpdateHealth():
	var regenRate = 1 - (hurtBlendTarget * .6)
	health = clamp( health + get_process_delta_time() * regenRate, -5, 1)
	RenderingServer.global_shader_parameter_set("playerHealth", health)

func PushAway(dir):
	velocity += dir * .5
	health -= .2
	isPushedf = 1.0
	Globals.NoiseEvent.emit(5, position)

func Teleport(pos: Vector3):
	position = pos

func DoCough():
	playerAnim.set("parameters/Cough/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	CoughSounds.playRandom($CoughAudioSource)
	ringBlendTarget = 2
	health -= 1
	playerAnim.set("parameters/CoughVar/blend_amount", randf_range(0.0,1.0))
